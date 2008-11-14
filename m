Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAE4Bbt1024537
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 Nov 2008 13:11:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 87EE145DD7B
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 13:11:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6910D45DD7E
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 13:11:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46207E08002
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 13:11:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC2701DB803E
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 13:11:36 +0900 (JST)
Date: Fri, 14 Nov 2008 13:10:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.28-rc4 mem_cgroup_charge_common panic
Message-Id: <20081114131058.8d538481.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1226602404.29381.6.camel@badari-desktop>
References: <1226353408.8805.12.camel@badari-desktop>
	<20081111101440.f531021d.kamezawa.hiroyu@jp.fujitsu.com>
	<20081111110934.d41fa8db.kamezawa.hiroyu@jp.fujitsu.com>
	<1226527376.4835.8.camel@badari-desktop>
	<20081113111702.9a5b6ce7.kamezawa.hiroyu@jp.fujitsu.com>
	<1226602404.29381.6.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Nov 2008 10:53:24 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:
> I tried mmtom + startpfn fix + this fix + notifier fix. Didn't help.
> I am not using SLUB (using SLAB). Yes. I am testing "real" memory
> remove (not just offline/online), since it executes more code of
> freeing memmap etc.
> 
> Code that is panicing is list_add() in mem_cgroup_add_list().
> I will debug it further.
> 

Considering difference between "real" memory hotplug and logical ones,
I found this. I hope this fixes the bug.
But I myself can't do test this..

Thanks,
-Kame

==
Fixes for memcg/memory hotplug.


While memory hotplug allocate/free memmap, page_cgroup doesn't free
page_cgroup at OFFLINE when page_cgroup is allocated via bootomem.
(Because freeing bootmem requires special care.)

Then, if page_cgroup is allocated by bootmem and memmap is freed/allocated
by memory hotplug, page_cgroup->page == page is no longer true and
we have to update that.

But current MEM_ONLINE handler doesn't check it and update page_cgroup->page
if it's not necessary to allocate page_cgroup.

And I noticed that MEM_ONLINE can be called against "part of section".
So, freeing page_cgroup at CANCEL_ONLINE will cause trouble.
(freeing used page_cgroup)
Don't rollback at CANCEL. 

One more, current memory hotplug notifier is stopped by slub
because it sets NOTIFY_STOP_MASK to return vaule. So, page_cgroup's callback
never be called. (low priority than slub now.)

I think this slub's behavior is not intentional(BUG). and fixes it.


Another way to be considered about page_cgroup allocation:
  - free page_cgroup at OFFLINE even if it's from bootmem
    and remove specieal handler. But it requires more changes.


Signed-off-by: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/page_cgroup.c |   39 +++++++++++++++++++++++++++------------
 mm/slub.c        |    6 ++++--
 2 files changed, 31 insertions(+), 14 deletions(-)

Index: mmotm-2.6.28-Nov10/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Nov10/mm/page_cgroup.c
@@ -104,18 +104,30 @@ int __meminit init_section_page_cgroup(u
 	unsigned long table_size;
 	int nid, index;
 
-	if (section->page_cgroup)
-		return 0;
+	if (!section->page_cgroup) {
 
-	nid = page_to_nid(pfn_to_page(pfn));
-	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
-	if (slab_is_available()) {
-		base = kmalloc_node(table_size, GFP_KERNEL, nid);
-		if (!base)
-			base = vmalloc_node(table_size, nid);
-	} else {
-		base = __alloc_bootmem_node_nopanic(NODE_DATA(nid), table_size,
+		nid = page_to_nid(pfn_to_page(pfn));
+		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
+		if (slab_is_available()) {
+			base = kmalloc_node(table_size, GFP_KERNEL, nid);
+			if (!base)
+				base = vmalloc_node(table_size, nid);
+		} else {
+			base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
+				table_size,
 				PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+		}
+	} else {
+		/*
+ 		 * We don't have to allocate page_cgroup again, but
+		 * address of memmap may be changed. So, we have to initialize
+		 * again.
+		 */
+		base = section->page_cgroup + pfn;
+		table_size = 0;
+		/* check address of memmap is changed or not. */
+		if (base->page == pfn_to_page(pfn))
+			return 0;
 	}
 
 	if (!base) {
@@ -204,19 +216,22 @@ static int page_cgroup_callback(struct n
 		ret = online_page_cgroup(mn->start_pfn,
 				   mn->nr_pages, mn->status_change_nid);
 		break;
-	case MEM_CANCEL_ONLINE:
 	case MEM_OFFLINE:
 		offline_page_cgroup(mn->start_pfn,
 				mn->nr_pages, mn->status_change_nid);
 		break;
 	case MEM_GOING_OFFLINE:
+	case MEM_CANCEL_ONLINE:
 		break;
 	case MEM_ONLINE:
 	case MEM_CANCEL_OFFLINE:
 		break;
 	}
 
-	ret = notifier_from_errno(ret);
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
 
 	return ret;
 }
Index: mmotm-2.6.28-Nov10/mm/slub.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/mm/slub.c
+++ mmotm-2.6.28-Nov10/mm/slub.c
@@ -3220,8 +3220,10 @@ static int slab_memory_callback(struct n
 	case MEM_CANCEL_OFFLINE:
 		break;
 	}
-
-	ret = notifier_from_errno(ret);
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
