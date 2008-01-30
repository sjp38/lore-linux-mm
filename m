Date: Wed, 30 Jan 2008 12:25:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080108210002.638347207@redhat.com>
References: <20080108205939.323955454@redhat.com> <20080108210002.638347207@redhat.com>
Message-Id: <20080130121152.1AF1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik, Lee

I tested new hackbench on rvr split LRU patch.
   http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c

method of test

(1) $ ./hackbench 150 process 1000
(2) # sync; echo 3 > /proc/sys/vm/drop_caches
    $ dd if=tmp10G of=/dev/null
    $ ./hackbench 150 process 1000

test machine
	CPU: Itanium2 x4 (logical 8cpu)
	MEM: 8GB

A. vanilla 2.6.24-rc8-mm1
	(1) 127.540
	(2) 727.548

B. 2.6.24-rc8-mm1 + split-lru-patch-series
	(1) 92.730
	(2) 758.369

   comment:
    (1) active/inactive anon ratio improve performance significant.
    (2) incorrect page activation reduce performance.


I investigate reason and found reason is [05/19] change.
I tested a bit porton reverted split-lru-patch-series again.

C. 2.6.24-rc8-mm1 + split-lru-patch-series + my-revert-patch
 	(1) 83.014
	(2) 717.009


Of course, We need reintroduce this portion after new page LRU
(aka LRU for used only page).
but now is too early.

I hope this patch series merge to -mm ASAP.
therefore, I hope remove any corner case regression.

Thanks!


- kosaki



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |   26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c       2008-01-29 15:59:17.000000000 +0900
+++ b/mm/vmscan.c       2008-01-30 11:53:42.000000000 +0900
@@ -247,6 +247,27 @@
        return ret;
 }

+/* Called without lock on whether page is mapped, so answer is unstable */
+static inline int page_mapping_inuse(struct page *page)
+{
+       struct address_space *mapping;
+
+       /* Page is in somebody's page tables. */
+       if (page_mapped(page))
+               return 1;
+
+       /* Be more reluctant to reclaim swapcache than pagecache */
+       if (PageSwapCache(page))
+               return 1;
+
+       mapping = page_mapping(page);
+       if (!mapping)
+               return 0;
+
+       /* File is mmap'd by somebody? */
+       return mapping_mapped(mapping);
+}
+
 static inline int is_page_cache_freeable(struct page *page)
 {
        return page_count(page) - !!PagePrivate(page) == 2;
@@ -515,7 +536,8 @@

                referenced = page_referenced(page, 1, sc->mem_cgroup);
                /* In active use or really unfreeable?  Activate it. */
-               if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
+               if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
+                                       referenced && page_mapping_inuse(page))
                        goto activate_locked;

 #ifdef CONFIG_SWAP
@@ -550,6 +572,8 @@
                }

                if (PageDirty(page)) {
+                       if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
+                               goto keep_locked;
                        if (!may_enter_fs) {
                                sc->nr_io_pages++;
                                goto keep_locked;





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
