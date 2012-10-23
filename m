Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 601A26B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:29:07 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5988459ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 23:29:06 -0700 (PDT)
Message-ID: <50863920.7070908@gmail.com>
Date: Tue, 23 Oct 2012 14:28:48 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] KSM: numa awareness sysfs knob
References: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
In-Reply-To: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
Content-Type: multipart/alternative;
 boundary="------------080403040708010501010500"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

This is a multi-part message in MIME format.
--------------080403040708010501010500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 09/24/2012 08:56 AM, Petr Holasek wrote:
> Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
> which control merging pages across different numa nodes.
> When it is set to zero only pages from the same node are merged,
> otherwise pages from all nodes can be merged together (default behavior).
>
> Typical use-case could be a lot of KVM guests on NUMA machine
> and cpus from more distant nodes would have significant increase
> of access latency to the merged ksm page. Sysfs knob was choosen
> for higher variability when some users still prefers higher amount
> of saved physical memory regardless of access latency.
>
> Every numa node has its own stable & unstable trees because of faster
> searching and inserting. Changing of merge_nodes value is possible only
> when there are not any ksm shared pages in system.
>
> I've tested this patch on numa machines with 2, 4 and 8 nodes and
> measured speed of memory access inside of KVM guests with memory pinned
> to one of nodes with this benchmark:
>
> http://pholasek.fedorapeople.org/alloc_pg.c
>
> Population standard deviations of access times in percentage of average
> were following:
>
> merge_nodes=1
> 2 nodes 1.4%
> 4 nodes 1.6%
> 8 nodes	1.7%
>
> merge_nodes=0
> 2 nodes	1%
> 4 nodes	0.32%
> 8 nodes	0.018%
>
> RFC: https://lkml.org/lkml/2011/11/30/91
> v1: https://lkml.org/lkml/2012/1/23/46
> v2: https://lkml.org/lkml/2012/6/29/105
> v3: https://lkml.org/lkml/2012/9/14/550
>
> Changelog:
>
> v2: Andrew's objections were reflected:
> 	- value of merge_nodes can't be changed while there are some ksm
> 	pages in system
> 	- merge_nodes sysfs entry appearance depends on CONFIG_NUMA
> 	- more verbose documentation
> 	- added some performance testing results
>
> v3:	- more verbose documentation
> 	- fixed race in merge_nodes store function
> 	- introduced share_all debugging knob proposed by Andrew
> 	- minor cleanups
>
> v4:	- merge_nodes was renamed to merge_across_nodes
> 	- share_all debug knob was dropped
> 	- get_kpfn_nid helper
> 	- fixed page migration behaviour

Thanks for your patch. Several questions ask you:

1) khugepaged default nice value is 19, but ksmd default nice value is 
5, why this big different?
2) why ksm doesn't support pagecache and tmpfs now? What's the bottleneck?
3) ksm kernel doc said that "KSM only merges anonymous(private) pages, 
never pagecache(file) pages".But where judege it should be private?
4) ksm kernel doc said that "To avoid the instability and the resulting 
false negatives to be permanent, KSM re-initializes the unstable tree 
root node to an empty tree, at every KSM pass." But I can't find where 
re-initializes the unstable tree, could you explain me?

Thanks in advance. :-)

Regards,
Chen

>
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> ---
>   Documentation/vm/ksm.txt |   7 +++
>   mm/ksm.c                 | 135 ++++++++++++++++++++++++++++++++++++++++-------
>   2 files changed, 122 insertions(+), 20 deletions(-)
>
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index b392e49..100d58d 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -58,6 +58,13 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
>                      e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
>                      Default: 20 (chosen for demonstration purposes)
>   
> +merge_nodes      - specifies if pages from different numa nodes can be merged.
> +                   When set to 0, ksm merges only pages which physically
> +                   reside in the memory area of same NUMA node. It brings
> +                   lower latency to access to shared page. Value can be
> +                   changed only when there is no ksm shared pages in system.
> +                   Default: 1
> +
>   run              - set 0 to stop ksmd from running but keep merged pages,
>                      set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
>                      set 2 to stop ksmd and unmerge all pages currently merged,
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 47c8853..7c82032 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -36,6 +36,7 @@
>   #include <linux/hash.h>
>   #include <linux/freezer.h>
>   #include <linux/oom.h>
> +#include <linux/numa.h>
>   
>   #include <asm/tlbflush.h>
>   #include "internal.h"
> @@ -140,7 +141,10 @@ struct rmap_item {
>   	unsigned long address;		/* + low bits used for flags below */
>   	unsigned int oldchecksum;	/* when unstable */
>   	union {
> -		struct rb_node node;	/* when node of unstable tree */
> +		struct {
> +			struct rb_node node;	/* when node of unstable tree */
> +			struct rb_root *root;
> +		};
>   		struct {		/* when listed from stable tree */
>   			struct stable_node *head;
>   			struct hlist_node hlist;
> @@ -153,8 +157,8 @@ struct rmap_item {
>   #define STABLE_FLAG	0x200	/* is listed from the stable tree */
>   
>   /* The stable and unstable tree heads */
> -static struct rb_root root_stable_tree = RB_ROOT;
> -static struct rb_root root_unstable_tree = RB_ROOT;
> +static struct rb_root root_unstable_tree[MAX_NUMNODES] = { RB_ROOT, };
> +static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };
>   
>   #define MM_SLOTS_HASH_SHIFT 10
>   #define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
> @@ -189,6 +193,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
>   /* Milliseconds ksmd should sleep between batches */
>   static unsigned int ksm_thread_sleep_millisecs = 20;
>   
> +/* Zeroed when merging across nodes is not allowed */
> +static unsigned int ksm_merge_across_nodes = 1;
> +
>   #define KSM_RUN_STOP	0
>   #define KSM_RUN_MERGE	1
>   #define KSM_RUN_UNMERGE	2
> @@ -447,10 +454,25 @@ out:		page = NULL;
>   	return page;
>   }
>   
> +/*
> + * This helper is used for getting right index into array of tree roots.
> + * When merge_across_nodes knob is set to 1, there are only two rb-trees for
> + * stable and unstable pages from all nodes with roots in index 0. Otherwise,
> + * every node has its own stable and unstable tree.
> + */
> +static inline int get_kpfn_nid(unsigned long kpfn)
> +{
> +	if (ksm_merge_across_nodes)
> +		return 0;
> +	else
> +		return pfn_to_nid(kpfn);
> +}
> +
>   static void remove_node_from_stable_tree(struct stable_node *stable_node)
>   {
>   	struct rmap_item *rmap_item;
>   	struct hlist_node *hlist;
> +	int nid;
>   
>   	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
>   		if (rmap_item->hlist.next)
> @@ -462,7 +484,10 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>   		cond_resched();
>   	}
>   
> -	rb_erase(&stable_node->node, &root_stable_tree);
> +	nid = get_kpfn_nid(stable_node->kpfn);
> +
> +	rb_erase(&stable_node->node,
> +			&root_stable_tree[nid]);
>   	free_stable_node(stable_node);
>   }
>   
> @@ -560,7 +585,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>   		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
>   		BUG_ON(age > 1);
>   		if (!age)
> -			rb_erase(&rmap_item->node, &root_unstable_tree);
> +			rb_erase(&rmap_item->node, rmap_item->root);
>   
>   		ksm_pages_unshared--;
>   		rmap_item->address &= PAGE_MASK;
> @@ -989,8 +1014,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>    */
>   static struct page *stable_tree_search(struct page *page)
>   {
> -	struct rb_node *node = root_stable_tree.rb_node;
> +	struct rb_node *node;
>   	struct stable_node *stable_node;
> +	int nid;
>   
>   	stable_node = page_stable_node(page);
>   	if (stable_node) {			/* ksm page forked */
> @@ -998,6 +1024,9 @@ static struct page *stable_tree_search(struct page *page)
>   		return page;
>   	}
>   
> +	nid = get_kpfn_nid(page_to_pfn(page));
> +	node = root_stable_tree[nid].rb_node;
> +
>   	while (node) {
>   		struct page *tree_page;
>   		int ret;
> @@ -1032,10 +1061,14 @@ static struct page *stable_tree_search(struct page *page)
>    */
>   static struct stable_node *stable_tree_insert(struct page *kpage)
>   {
> -	struct rb_node **new = &root_stable_tree.rb_node;
> +	int nid;
> +	struct rb_node **new = NULL;
>   	struct rb_node *parent = NULL;
>   	struct stable_node *stable_node;
>   
> +	nid = get_kpfn_nid(page_to_nid(kpage));
> +	new = &root_stable_tree[nid].rb_node;
> +
>   	while (*new) {
>   		struct page *tree_page;
>   		int ret;
> @@ -1069,7 +1102,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>   		return NULL;
>   
>   	rb_link_node(&stable_node->node, parent, new);
> -	rb_insert_color(&stable_node->node, &root_stable_tree);
> +	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
>   
>   	INIT_HLIST_HEAD(&stable_node->hlist);
>   
> @@ -1097,10 +1130,16 @@ static
>   struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>   					      struct page *page,
>   					      struct page **tree_pagep)
> -
>   {
> -	struct rb_node **new = &root_unstable_tree.rb_node;
> +	struct rb_node **new = NULL;
> +	struct rb_root *root;
>   	struct rb_node *parent = NULL;
> +	int nid;
> +
> +	nid = get_kpfn_nid(page_to_pfn(page));
> +	root = &root_unstable_tree[nid];
> +
> +	new = &root->rb_node;
>   
>   	while (*new) {
>   		struct rmap_item *tree_rmap_item;
> @@ -1138,8 +1177,9 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>   
>   	rmap_item->address |= UNSTABLE_FLAG;
>   	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
> +	rmap_item->root = root;
>   	rb_link_node(&rmap_item->node, parent, new);
> -	rb_insert_color(&rmap_item->node, &root_unstable_tree);
> +	rb_insert_color(&rmap_item->node, root);
>   
>   	ksm_pages_unshared++;
>   	return NULL;
> @@ -1282,6 +1322,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>   	struct mm_slot *slot;
>   	struct vm_area_struct *vma;
>   	struct rmap_item *rmap_item;
> +	int i;
>   
>   	if (list_empty(&ksm_mm_head.mm_list))
>   		return NULL;
> @@ -1300,7 +1341,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>   		 */
>   		lru_add_drain_all();
>   
> -		root_unstable_tree = RB_ROOT;
> +		for (i = 0; i < MAX_NUMNODES; i++)
> +			root_unstable_tree[i] = RB_ROOT;
>   
>   		spin_lock(&ksm_mmlist_lock);
>   		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
> @@ -1758,7 +1800,12 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
>   	stable_node = page_stable_node(newpage);
>   	if (stable_node) {
>   		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
> -		stable_node->kpfn = page_to_pfn(newpage);
> +
> +		if (ksm_merge_across_nodes ||
> +				page_to_nid(oldpage) == page_to_nid(newpage))
> +			stable_node->kpfn = page_to_pfn(newpage);
> +		else
> +			remove_node_from_stable_tree(stable_node);
>   	}
>   }
>   #endif /* CONFIG_MIGRATION */
> @@ -1768,15 +1815,19 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
>   						 unsigned long end_pfn)
>   {
>   	struct rb_node *node;
> +	int i;
>   
> -	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
> -		struct stable_node *stable_node;
> +	for (i = 0; i < MAX_NUMNODES; i++)
> +		for (node = rb_first(&root_stable_tree[i]); node;
> +				node = rb_next(node)) {
> +			struct stable_node *stable_node;
> +
> +			stable_node = rb_entry(node, struct stable_node, node);
> +			if (stable_node->kpfn >= start_pfn &&
> +			    stable_node->kpfn < end_pfn)
> +				return stable_node;
> +		}
>   
> -		stable_node = rb_entry(node, struct stable_node, node);
> -		if (stable_node->kpfn >= start_pfn &&
> -		    stable_node->kpfn < end_pfn)
> -			return stable_node;
> -	}
>   	return NULL;
>   }
>   
> @@ -1926,6 +1977,47 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
>   }
>   KSM_ATTR(run);
>   
> +#ifdef CONFIG_NUMA
> +static ssize_t merge_across_nodes_show(struct kobject *kobj,
> +				struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%u\n", ksm_merge_across_nodes);
> +}
> +
> +static ssize_t merge_across_nodes_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long knob;
> +
> +	err = kstrtoul(buf, 10, &knob);
> +	if (err)
> +		return err;
> +	if (knob > 1)
> +		return -EINVAL;
> +
> +	mutex_lock(&ksm_thread_mutex);
> +	if (ksm_run & KSM_RUN_MERGE) {
> +		err = -EBUSY;
> +	} else {
> +		if (ksm_merge_across_nodes != knob) {
> +			if (ksm_pages_shared > 0)
> +				err = -EBUSY;
> +			else
> +				ksm_merge_across_nodes = knob;
> +		}
> +	}
> +
> +	if (err)
> +		count = err;
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return count;
> +}
> +KSM_ATTR(merge_across_nodes);
> +#endif
> +
>   static ssize_t pages_shared_show(struct kobject *kobj,
>   				 struct kobj_attribute *attr, char *buf)
>   {
> @@ -1980,6 +2072,9 @@ static struct attribute *ksm_attrs[] = {
>   	&pages_unshared_attr.attr,
>   	&pages_volatile_attr.attr,
>   	&full_scans_attr.attr,
> +#ifdef CONFIG_NUMA
> +	&merge_across_nodes_attr.attr,
> +#endif
>   	NULL,
>   };
>   


--------------080403040708010501010500
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 09/24/2012 08:56 AM, Petr Holasek
      wrote:<br>
    </div>
    <blockquote
      cite="mid:1348448166-1995-1-git-send-email-pholasek@redhat.com"
      type="cite">
      <pre wrap="">Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
which control merging pages across different numa nodes.
When it is set to zero only pages from the same node are merged,
otherwise pages from all nodes can be merged together (default behavior).

Typical use-case could be a lot of KVM guests on NUMA machine
and cpus from more distant nodes would have significant increase
of access latency to the merged ksm page. Sysfs knob was choosen
for higher variability when some users still prefers higher amount
of saved physical memory regardless of access latency.

Every numa node has its own stable &amp; unstable trees because of faster
searching and inserting. Changing of merge_nodes value is possible only
when there are not any ksm shared pages in system.

I've tested this patch on numa machines with 2, 4 and 8 nodes and
measured speed of memory access inside of KVM guests with memory pinned
to one of nodes with this benchmark:

<a class="moz-txt-link-freetext" href="http://pholasek.fedorapeople.org/alloc_pg.c">http://pholasek.fedorapeople.org/alloc_pg.c</a>

Population standard deviations of access times in percentage of average
were following:

merge_nodes=1
2 nodes 1.4%
4 nodes 1.6%
8 nodes	1.7%

merge_nodes=0
2 nodes	1%
4 nodes	0.32%
8 nodes	0.018%

RFC: <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2011/11/30/91">https://lkml.org/lkml/2011/11/30/91</a>
v1: <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2012/1/23/46">https://lkml.org/lkml/2012/1/23/46</a>
v2: <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2012/6/29/105">https://lkml.org/lkml/2012/6/29/105</a>
v3: <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2012/9/14/550">https://lkml.org/lkml/2012/9/14/550</a>

Changelog:

v2: Andrew's objections were reflected:
	- value of merge_nodes can't be changed while there are some ksm
	pages in system
	- merge_nodes sysfs entry appearance depends on CONFIG_NUMA
	- more verbose documentation
	- added some performance testing results

v3:	- more verbose documentation
	- fixed race in merge_nodes store function
	- introduced share_all debugging knob proposed by Andrew
	- minor cleanups

v4:	- merge_nodes was renamed to merge_across_nodes
	- share_all debug knob was dropped
	- get_kpfn_nid helper
	- fixed page migration behaviour</pre>
    </blockquote>
    <br>
    Thanks for your patch. Several questions ask you:<br>
    &nbsp;<br>
    1) khugepaged default nice value is 19, but ksmd default nice value
    is 5, why this big different?<br>
    2) why ksm doesn't support pagecache and tmpfs now? What's the
    bottleneck?<br>
    3) ksm kernel doc said that "KSM only merges anonymous(private)
    pages, never pagecache(file) pages".<span style="color: rgb(34, 34,
      34); font-family: arial, sans-serif; font-size: 14px; font-style:
      normal; font-variant: normal; font-weight: normal; letter-spacing:
      normal; line-height: normal; orphans: 2; text-align: -webkit-auto;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: 2; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255); display: inline !important; float: none; "></span><span
      style="color: rgb(43, 43, 43); font-family: arial, sans-serif;
      font-size: 18px; font-style: normal; font-variant: normal;
      font-weight: bold; letter-spacing: normal; line-height: 27px;
      orphans: 2; text-align: -webkit-auto; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px; background-color: rgb(250, 250,
      250); display: inline !important; float: none; "></span> But where
    judege it should be private?<br>
    4) ksm kernel doc said that "To avoid the instability and the
    resulting false negatives to be permanent, KSM re-initializes the
    unstable tree root node to an empty tree, at every KSM pass." But I
    can't find where re-initializes the unstable tree, could you explain
    me?<br>
    <br>
    Thanks in advance. :-)<br>
    <br>
    Regards,<br>
    Chen<br>
    <br>
    <blockquote
      cite="mid:1348448166-1995-1-git-send-email-pholasek@redhat.com"
      type="cite">
      <pre wrap="">

Signed-off-by: Petr Holasek <a class="moz-txt-link-rfc2396E" href="mailto:pholasek@redhat.com">&lt;pholasek@redhat.com&gt;</a>
---
 Documentation/vm/ksm.txt |   7 +++
 mm/ksm.c                 | 135 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 122 insertions(+), 20 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index b392e49..100d58d 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -58,6 +58,13 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
                    e.g. "echo 20 &gt; /sys/kernel/mm/ksm/sleep_millisecs"
                    Default: 20 (chosen for demonstration purposes)
 
+merge_nodes      - specifies if pages from different numa nodes can be merged.
+                   When set to 0, ksm merges only pages which physically
+                   reside in the memory area of same NUMA node. It brings
+                   lower latency to access to shared page. Value can be
+                   changed only when there is no ksm shared pages in system.
+                   Default: 1
+
 run              - set 0 to stop ksmd from running but keep merged pages,
                    set 1 to run ksmd e.g. "echo 1 &gt; /sys/kernel/mm/ksm/run",
                    set 2 to stop ksmd and unmerge all pages currently merged,
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..7c82032 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -36,6 +36,7 @@
 #include &lt;linux/hash.h&gt;
 #include &lt;linux/freezer.h&gt;
 #include &lt;linux/oom.h&gt;
+#include &lt;linux/numa.h&gt;
 
 #include &lt;asm/tlbflush.h&gt;
 #include "internal.h"
@@ -140,7 +141,10 @@ struct rmap_item {
 	unsigned long address;		/* + low bits used for flags below */
 	unsigned int oldchecksum;	/* when unstable */
 	union {
-		struct rb_node node;	/* when node of unstable tree */
+		struct {
+			struct rb_node node;	/* when node of unstable tree */
+			struct rb_root *root;
+		};
 		struct {		/* when listed from stable tree */
 			struct stable_node *head;
 			struct hlist_node hlist;
@@ -153,8 +157,8 @@ struct rmap_item {
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
 
 /* The stable and unstable tree heads */
-static struct rb_root root_stable_tree = RB_ROOT;
-static struct rb_root root_unstable_tree = RB_ROOT;
+static struct rb_root root_unstable_tree[MAX_NUMNODES] = { RB_ROOT, };
+static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };
 
 #define MM_SLOTS_HASH_SHIFT 10
 #define MM_SLOTS_HASH_HEADS (1 &lt;&lt; MM_SLOTS_HASH_SHIFT)
@@ -189,6 +193,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Zeroed when merging across nodes is not allowed */
+static unsigned int ksm_merge_across_nodes = 1;
+
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
@@ -447,10 +454,25 @@ out:		page = NULL;
 	return page;
 }
 
+/*
+ * This helper is used for getting right index into array of tree roots.
+ * When merge_across_nodes knob is set to 1, there are only two rb-trees for
+ * stable and unstable pages from all nodes with roots in index 0. Otherwise,
+ * every node has its own stable and unstable tree.
+ */
+static inline int get_kpfn_nid(unsigned long kpfn)
+{
+	if (ksm_merge_across_nodes)
+		return 0;
+	else
+		return pfn_to_nid(kpfn);
+}
+
 static void remove_node_from_stable_tree(struct stable_node *stable_node)
 {
 	struct rmap_item *rmap_item;
 	struct hlist_node *hlist;
+	int nid;
 
 	hlist_for_each_entry(rmap_item, hlist, &amp;stable_node-&gt;hlist, hlist) {
 		if (rmap_item-&gt;hlist.next)
@@ -462,7 +484,10 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 		cond_resched();
 	}
 
-	rb_erase(&amp;stable_node-&gt;node, &amp;root_stable_tree);
+	nid = get_kpfn_nid(stable_node-&gt;kpfn);
+
+	rb_erase(&amp;stable_node-&gt;node,
+			&amp;root_stable_tree[nid]);
 	free_stable_node(stable_node);
 }
 
@@ -560,7 +585,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item-&gt;address);
 		BUG_ON(age &gt; 1);
 		if (!age)
-			rb_erase(&amp;rmap_item-&gt;node, &amp;root_unstable_tree);
+			rb_erase(&amp;rmap_item-&gt;node, rmap_item-&gt;root);
 
 		ksm_pages_unshared--;
 		rmap_item-&gt;address &amp;= PAGE_MASK;
@@ -989,8 +1014,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
  */
 static struct page *stable_tree_search(struct page *page)
 {
-	struct rb_node *node = root_stable_tree.rb_node;
+	struct rb_node *node;
 	struct stable_node *stable_node;
+	int nid;
 
 	stable_node = page_stable_node(page);
 	if (stable_node) {			/* ksm page forked */
@@ -998,6 +1024,9 @@ static struct page *stable_tree_search(struct page *page)
 		return page;
 	}
 
+	nid = get_kpfn_nid(page_to_pfn(page));
+	node = root_stable_tree[nid].rb_node;
+
 	while (node) {
 		struct page *tree_page;
 		int ret;
@@ -1032,10 +1061,14 @@ static struct page *stable_tree_search(struct page *page)
  */
 static struct stable_node *stable_tree_insert(struct page *kpage)
 {
-	struct rb_node **new = &amp;root_stable_tree.rb_node;
+	int nid;
+	struct rb_node **new = NULL;
 	struct rb_node *parent = NULL;
 	struct stable_node *stable_node;
 
+	nid = get_kpfn_nid(page_to_nid(kpage));
+	new = &amp;root_stable_tree[nid].rb_node;
+
 	while (*new) {
 		struct page *tree_page;
 		int ret;
@@ -1069,7 +1102,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		return NULL;
 
 	rb_link_node(&amp;stable_node-&gt;node, parent, new);
-	rb_insert_color(&amp;stable_node-&gt;node, &amp;root_stable_tree);
+	rb_insert_color(&amp;stable_node-&gt;node, &amp;root_stable_tree[nid]);
 
 	INIT_HLIST_HEAD(&amp;stable_node-&gt;hlist);
 
@@ -1097,10 +1130,16 @@ static
 struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 					      struct page *page,
 					      struct page **tree_pagep)
-
 {
-	struct rb_node **new = &amp;root_unstable_tree.rb_node;
+	struct rb_node **new = NULL;
+	struct rb_root *root;
 	struct rb_node *parent = NULL;
+	int nid;
+
+	nid = get_kpfn_nid(page_to_pfn(page));
+	root = &amp;root_unstable_tree[nid];
+
+	new = &amp;root-&gt;rb_node;
 
 	while (*new) {
 		struct rmap_item *tree_rmap_item;
@@ -1138,8 +1177,9 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 
 	rmap_item-&gt;address |= UNSTABLE_FLAG;
 	rmap_item-&gt;address |= (ksm_scan.seqnr &amp; SEQNR_MASK);
+	rmap_item-&gt;root = root;
 	rb_link_node(&amp;rmap_item-&gt;node, parent, new);
-	rb_insert_color(&amp;rmap_item-&gt;node, &amp;root_unstable_tree);
+	rb_insert_color(&amp;rmap_item-&gt;node, root);
 
 	ksm_pages_unshared++;
 	return NULL;
@@ -1282,6 +1322,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct mm_slot *slot;
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
+	int i;
 
 	if (list_empty(&amp;ksm_mm_head.mm_list))
 		return NULL;
@@ -1300,7 +1341,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 		 */
 		lru_add_drain_all();
 
-		root_unstable_tree = RB_ROOT;
+		for (i = 0; i &lt; MAX_NUMNODES; i++)
+			root_unstable_tree[i] = RB_ROOT;
 
 		spin_lock(&amp;ksm_mmlist_lock);
 		slot = list_entry(slot-&gt;mm_list.next, struct mm_slot, mm_list);
@@ -1758,7 +1800,12 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
 	stable_node = page_stable_node(newpage);
 	if (stable_node) {
 		VM_BUG_ON(stable_node-&gt;kpfn != page_to_pfn(oldpage));
-		stable_node-&gt;kpfn = page_to_pfn(newpage);
+
+		if (ksm_merge_across_nodes ||
+				page_to_nid(oldpage) == page_to_nid(newpage))
+			stable_node-&gt;kpfn = page_to_pfn(newpage);
+		else
+			remove_node_from_stable_tree(stable_node);
 	}
 }
 #endif /* CONFIG_MIGRATION */
@@ -1768,15 +1815,19 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
 						 unsigned long end_pfn)
 {
 	struct rb_node *node;
+	int i;
 
-	for (node = rb_first(&amp;root_stable_tree); node; node = rb_next(node)) {
-		struct stable_node *stable_node;
+	for (i = 0; i &lt; MAX_NUMNODES; i++)
+		for (node = rb_first(&amp;root_stable_tree[i]); node;
+				node = rb_next(node)) {
+			struct stable_node *stable_node;
+
+			stable_node = rb_entry(node, struct stable_node, node);
+			if (stable_node-&gt;kpfn &gt;= start_pfn &amp;&amp;
+			    stable_node-&gt;kpfn &lt; end_pfn)
+				return stable_node;
+		}
 
-		stable_node = rb_entry(node, struct stable_node, node);
-		if (stable_node-&gt;kpfn &gt;= start_pfn &amp;&amp;
-		    stable_node-&gt;kpfn &lt; end_pfn)
-			return stable_node;
-	}
 	return NULL;
 }
 
@@ -1926,6 +1977,47 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 }
 KSM_ATTR(run);
 
+#ifdef CONFIG_NUMA
+static ssize_t merge_across_nodes_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_merge_across_nodes);
+}
+
+static ssize_t merge_across_nodes_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	unsigned long knob;
+
+	err = kstrtoul(buf, 10, &amp;knob);
+	if (err)
+		return err;
+	if (knob &gt; 1)
+		return -EINVAL;
+
+	mutex_lock(&amp;ksm_thread_mutex);
+	if (ksm_run &amp; KSM_RUN_MERGE) {
+		err = -EBUSY;
+	} else {
+		if (ksm_merge_across_nodes != knob) {
+			if (ksm_pages_shared &gt; 0)
+				err = -EBUSY;
+			else
+				ksm_merge_across_nodes = knob;
+		}
+	}
+
+	if (err)
+		count = err;
+	mutex_unlock(&amp;ksm_thread_mutex);
+
+	return count;
+}
+KSM_ATTR(merge_across_nodes);
+#endif
+
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
 {
@@ -1980,6 +2072,9 @@ static struct attribute *ksm_attrs[] = {
 	&amp;pages_unshared_attr.attr,
 	&amp;pages_volatile_attr.attr,
 	&amp;full_scans_attr.attr,
+#ifdef CONFIG_NUMA
+	&amp;merge_across_nodes_attr.attr,
+#endif
 	NULL,
 };
 
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------080403040708010501010500--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
