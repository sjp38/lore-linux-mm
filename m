Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E3E956B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 20:53:50 -0400 (EDT)
Date: Tue, 14 Sep 2010 08:53:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/4] writeback: integrated background work
Message-ID: <20100914005341.GA5377@localhost>
References: <20100913123110.372291929@intel.com>
 <20100913130149.849935145@intel.com>
 <AANLkTi=JuBKdqbGrukVwfVfgs1gixdRd3t77ZGEUL9wj@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=JuBKdqbGrukVwfVfgs1gixdRd3t77ZGEUL9wj@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 14, 2010 at 06:46:01AM +0800, Minchan Kim wrote:
> Hi Wu,
> 
> On Mon, Sep 13, 2010 at 9:31 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Check background work whenever the flusher thread wakes up. A The page
> > reclaim code may lower the soft dirty limit immediately before sending
> > some work to the flusher thread.
> 
> I looked over this series. First impression is the approach is good. :)

Thanks :)

> But let me have a question.
> I can't find things about soft dirty limit.
> Maybe it's a thing based on your another patch series.

Yes, it's in the series "[RFC] soft and dynamic dirty throttling
limits", in particular the patch "[PATCH 15/17] mm: lower soft dirty
limits on memory pressure". https://patchwork.kernel.org/patch/173232/

> But at least, could you explain it in this series if it is really
> related to this series?

The above patch with URL has a chunk:

@@ -745,6 +745,16 @@  static unsigned long shrink_page_list(st
                }
 
                if (PageDirty(page)) {
+
+                       if (file && scanning_global_lru(sc)) {
+                               int dp = VM_DIRTY_PRESSURE >>
+                                       (DEF_PRIORITY + 1 - sc->priority);
+                               if (vm_dirty_pressure > dp) {
+                                       vm_dirty_pressure = dp;
+                                       vm_dirty_pressure_node = numa_node_id();
+                               }
+                       }
+

which lowers the soft dirty limits. It could explicitly check and
start background work, however doesn't do so because this patchset
will take care of it, by adding this chunk immediately after the above
code:

@@ -756,6 +756,19 @@ static unsigned long shrink_page_list(st
                                }
                        }

+                       if (page_is_file_cache(page) && mapping &&
+                           sync_writeback == PAGEOUT_IO_ASYNC) {
+                               if (!bdi_start_inode_writeback(
+                                       mapping->backing_dev_info,
+                                       mapping->host, page_index(page))) {
+                                       SetPageReclaim(page);
+                                       goto keep_locked;
+                               } else if (!current_is_kswapd() &&
+                                          printk_ratelimit()) {
+                                       printk(KERN_INFO "cannot pageout\n");
+                               }
+                       }
+                       

The bdi_start_inode_writeback() will wake up the flusher thread, which
will then check for background writeback (behavior added by this patch).

> >
> > This is also the prerequisite of next patch.
> 
> I can't understand why is the prerequisite of next patch.
> Please specify it.

Because the next patch breaks out of the background work (to serve
other works first). The code in this patch will resume the background
work when other works are done.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
