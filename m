Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2FF6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 03:51:48 -0400 (EDT)
Date: Tue, 7 Jun 2011 09:51:31 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-ID: <20110607075131.GB22234@cmpxchg.org>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
 <20110529231948.e1439ce5.akpm@linux-foundation.org>
 <20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
 <20110606125421.GB30184@cmpxchg.org>
 <20110606144519.1e2e7d86.akpm@linux-foundation.org>
 <20110607095708.6097689a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607095708.6097689a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>

On Tue, Jun 07, 2011 at 09:57:08AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 6 Jun 2011 14:45:19 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Hopefully he can test this one for us as well, thanks.
> > 
> 
> A  patch with better description (of mine) is here.
> Anyway, I felt I needed a fix for ARM special case.

It's a different issue that warrants a separate patch, I think.

> fix-init-page_cgroup-for-sparsemem-taking-care-of-broken-page-flags.patch
> Even with SPARSEMEM, there are some magical memmap.
> 
> If a Node is not aligned to SECTION, memmap of pfn which is out of
> Node's range is not initialized. And page->flags contains 0.
> 
> If Node(0) doesn't exist, NODE_DATA(pfn_to_nid(pfn)) causes error.
> 
> In another case, for example, ARM frees memmap which is never be used
> even under SPARSEMEM. In that case, page->flags will contain broken
> value.
> 
> This patch does a strict check on nid which is obtained by
> pfn_to_page() and use proper NID for page_cgroup allocation.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/page_cgroup.c |   36 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 35 insertions(+), 1 deletion(-)
> 
> Index: linux-3.0-rc1/mm/page_cgroup.c
> ===================================================================
> --- linux-3.0-rc1.orig/mm/page_cgroup.c
> +++ linux-3.0-rc1/mm/page_cgroup.c
> @@ -168,6 +168,7 @@ static int __meminit init_section_page_c
>  	struct mem_section *section;
>  	unsigned long table_size;
>  	unsigned long nr;
> +	unsigned long tmp;
>  	int nid, index;
>  
>  	nr = pfn_to_section_nr(pfn);
> @@ -175,8 +176,41 @@ static int __meminit init_section_page_c
>  
>  	if (section->page_cgroup)
>  		return 0;
> +	/*
> +	 * check Node-ID. Because we get 'pfn' which is obtained by calculation,
> +	 * the pfn may "not exist" or "alreay freed". Even if pfn_valid() returns
> +	 * true, page->flags may contain broken value and pfn_to_nid() returns
> +	 * bad value.
> +	 * (See CONFIG_ARCH_HAS_HOLES_MEMORYMODEL and ARM's free_memmap())
> +	 * So, we need to do careful check, here.
> +	 */
> +	for (tmp = pfn;
> +	     tmp < pfn + PAGES_PER_SECTION;
> +	     tmp += MAX_ORDER_NR_PAGES, nid = -1) {
> +		struct page *page;
> +
> +		if (!pfn_valid(tmp))
> +			continue;
> +
> +		page = pfn_to_page(tmp);
> +		nid = page_to_nid(page);
>  
> -	nid = page_to_nid(pfn_to_page(pfn));
> +		/*
> +		 * If 'page' isn't initialized or freed, it may contains broken
> +		 * information.
> +		 */
> +		if (!node_state(nid, N_NORMAL_MEMORY))
> +			continue;
> +		if (page_to_pfn(pfn_to_page(tmp)) != tmp)
> +			continue;

This looks quite elaborate just to figure out the node id.

Here is what I wrote before I went with the sparsemem model fix (with
a modified changelog, because it also fixed the off-node range
problem).

It just iterates nodes in the first place, so the node id is never a
question.  The memory hotplug callback still relies on pfn_to_nid()
but ARM, at least as of now, does not support hotplug anyway.

What do you think?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] page_cgroup: do not rely on memmap outside of node ranges

On ARM, memmap for present sections may partially be released.

As a consequence of this, a PFN walker like the page_cgroup array
allocator may not rely on the struct page that corresponds to a
pfn_present() PFN before it has been validated with something like
memmap_valid_within().

However, since this code only requires the node ID from the PFN range,
this patch changes it from a pure PFN walker to a PFN in nodes walker.
The node ID information is then inherently available through the node
that is currently being walked.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_cgroup.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 74ccff6..46b6814 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -162,13 +162,13 @@ static void free_page_cgroup(void *addr)
 }
 #endif
 
-static int __meminit init_section_page_cgroup(unsigned long pfn)
+static int __meminit init_section_page_cgroup(int nid, unsigned long pfn)
 {
 	struct page_cgroup *base, *pc;
 	struct mem_section *section;
 	unsigned long table_size;
 	unsigned long nr;
-	int nid, index;
+	int index;
 
 	nr = pfn_to_section_nr(pfn);
 	section = __nr_to_section(nr);
@@ -176,7 +176,6 @@ static int __meminit init_section_page_cgroup(unsigned long pfn)
 	if (section->page_cgroup)
 		return 0;
 
-	nid = page_to_nid(pfn_to_page(pfn));
 	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 	base = alloc_page_cgroup(table_size, nid);
 
@@ -222,13 +221,16 @@ int __meminit online_page_cgroup(unsigned long start_pfn,
 	unsigned long start, end, pfn;
 	int fail = 0;
 
+	if (nid < 0)
+		nid = pfn_to_nid(start_pfn);
+
 	start = start_pfn & ~(PAGES_PER_SECTION - 1);
 	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
 		if (!pfn_present(pfn))
 			continue;
-		fail = init_section_page_cgroup(pfn);
+		fail = init_section_page_cgroup(nid, pfn);
 	}
 	if (!fail)
 		return 0;
@@ -283,23 +285,30 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
 
 void __init page_cgroup_init(void)
 {
-	unsigned long pfn;
-	int fail = 0;
+	pg_data_t *pgdat;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
-		if (!pfn_present(pfn))
-			continue;
-		fail = init_section_page_cgroup(pfn);
-	}
-	if (fail) {
-		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
-		panic("Out of memory");
-	} else {
-		hotplug_memory_notifier(page_cgroup_callback, 0);
+	for_each_online_pgdat(pgdat) {
+		unsigned long start;
+		unsigned long end;
+		unsigned long pfn;
+
+		start = pgdat->node_start_pfn & ~(PAGES_PER_SECTION - 1);
+		end = ALIGN(pgdat->node_start_pfn + pgdat->node_spanned_pages,
+			    PAGES_PER_SECTION);
+		for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
+			if (!pfn_present(pfn))
+				continue;
+			if (!init_section_page_cgroup(pgdat->node_id, pfn))
+				continue;
+			printk(KERN_CRIT
+			       "try 'cgroup_disable=memory' boot option\n");
+			panic("Out of memory");
+		}
 	}
+	hotplug_memory_notifier(page_cgroup_callback, 0);
 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
 	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you don't"
 	" want memory cgroups\n");
-- 
1.7.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
