Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 81C926B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 02:07:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 62B753EE0AE
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:07:34 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CCF845DEA6
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:07:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2709D45DE9E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:07:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 188CD1DB8038
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:07:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C1B911DB8037
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:07:33 +0900 (JST)
Date: Wed, 20 Jul 2011 15:00:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] memcg: add vmscan_stat
Message-Id: <20110720150024.56ee9714.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAL1qeaHfP4p_ahuLRF5jfRa0Ttsj=PdS0bxiZVJiXeSi+Z3L3w@mail.gmail.com>
References: <20110711193036.5a03858d.kamezawa.hiroyu@jp.fujitsu.com>
	<CAL1qeaFQ2gPYm1LfUMOBm8G0q9UyoeRdYGwCQ9oF42AU8O6q9Q@mail.gmail.com>
	<20110714090221.1ead26d5.kamezawa.hiroyu@jp.fujitsu.com>
	<CAL1qeaEoH_o4YfwnT5jsz3tyd=ZiGtUqMHQy7BMfLznjKvSZ_g@mail.gmail.com>
	<CAL1qeaHfP4p_ahuLRF5jfRa0Ttsj=PdS0bxiZVJiXeSi+Z3L3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Bresticker <abrestic@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Fri, 15 Jul 2011 13:28:08 -0700
Andrew Bresticker <abrestic@google.com> wrote:

> And this one tracks the number of pages unmapped:

Hmm, maybe seems nice to add. I'll include this one when I post next version.

Thanks,
-Kame

> --
> 
> From: Andrew Bresticker <abrestic@google.com>
> Date: Fri, 15 Jul 2011 11:46:40 -0700
> Subject: [PATCH] vmscan: Track pages unmapped during page reclaim.
> 
> Record the number of pages unmapped during page reclaim in
> memory.vmscan_stat.  Counters are broken down by type and
> context like the other stats in memory.vmscan_stat.
> 
> Sample output:
> $ mkdir /dev/cgroup/memory/1
> $ echo 512m > /dev/cgroup/memory/1
> $ echo $$ > /dev/cgroup/memory/1
> $ pft -m 512m
> $ cat /dev/cgroup/memory/1/memory.vmscan_stat
> ...
> unmapped_pages_by_limit 67
> unmapped_anon_pages_by_limit 0
> unmapped_file_pages_by_limit 67
> ...
> unmapped_pages_by_limit_under_hierarchy 67
> unmapped_anon_pages_by_limit_under_hierarchy 0
> unmapped_file_pages_by_limit_under_hierarchy 67
> 
> Signed-off-by: Andrew Bresticker <abrestic@google.com>
> ---
>  include/linux/memcontrol.h |    1 +
>  mm/memcontrol.c            |   12 ++++++++++++
>  mm/vmscan.c                |    8 ++++++--
>  3 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4be907e..8d65b55 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -47,6 +47,7 @@ struct memcg_scanrecord {
>   unsigned long nr_rotated[2]; /* the number of rotated pages */
>   unsigned long nr_freed[2]; /* the number of freed pages */
>   unsigned long nr_written[2]; /* the number of pages written back */
> + unsigned long nr_unmapped[2]; /* the number of pages unmapped */
>   unsigned long elapsed; /* nsec of time elapsed while scanning */
>  };
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5ec2aa3..6b4fbbd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -224,6 +224,9 @@ enum {
>   WRITTEN,
>   WRITTEN_ANON,
>   WRITTEN_FILE,
> + UNMAPPED,
> + UNMAPPED_ANON,
> + UNMAPPED_FILE,
>   ELAPSED,
>   NR_SCANSTATS,
>  };
> @@ -247,6 +250,9 @@ const char *scanstat_string[NR_SCANSTATS] = {
>   "written_pages",
>   "written_anon_pages",
>   "written_file_pages",
> + "unmapped_pages",
> + "unmapped_anon_pages",
> + "unmapped_file_pages",
>   "elapsed_ns",
>  };
>  #define SCANSTAT_WORD_LIMIT    "_by_limit"
> @@ -1692,6 +1698,10 @@ static void __mem_cgroup_record_scanstat(unsigned
> long *stats,
>   stats[WRITTEN_ANON] += rec->nr_written[0];
>   stats[WRITTEN_FILE] += rec->nr_written[1];
> 
> + stats[UNMAPPED] += rec->nr_unmapped[0] + rec->nr_unmapped[1];
> + stats[UNMAPPED_ANON] += rec->nr_unmapped[0];
> + stats[UNMAPPED_FILE] += rec->nr_unmapped[1];
> +
>          stats[ELAPSED] += rec->elapsed;
>  }
> 
> @@ -1806,6 +1816,8 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
>                  rec.nr_freed[1] = 0;
>   rec.nr_written[0] = 0;
>   rec.nr_written[1] = 0;
> + rec.nr_unmapped[0] = 0;
> + rec.nr_unmapped[1] = 0;
>                  rec.elapsed = 0;
>   /* we use swappiness of local cgroup */
>   if (check_soft) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f73b96e..2d2bc99 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -728,6 +728,7 @@ static unsigned long shrink_page_list(struct list_head
> *page_list,
>   unsigned long nr_congested = 0;
>   unsigned long nr_reclaimed = 0;
>   unsigned long nr_written = 0;
> + unsigned long nr_unmapped = 0;
> 
>   cond_resched();
> 
> @@ -819,7 +820,8 @@ static unsigned long shrink_page_list(struct list_head
> *page_list,
>   case SWAP_MLOCK:
>   goto cull_mlocked;
>   case SWAP_SUCCESS:
> - ; /* try to free the page below */
> + /* try to free the page below */
> + nr_unmapped++;
>   }
>   }
> 
> @@ -960,8 +962,10 @@ keep_lumpy:
>   free_page_list(&free_pages);
> 
>   list_splice(&ret_pages, page_list);
> - if (!scanning_global_lru(sc))
> + if (!scanning_global_lru(sc)) {
>   sc->memcg_record->nr_written[file] += nr_written;
> + sc->memcg_record->nr_unmapped[file] += nr_unmapped;
> + }
>   count_vm_events(PGACTIVATE, pgactivate);
>   return nr_reclaimed;
>  }
> -- 
> 1.7.3.1
> 
> Thanks,
> Andrew
> 
> On Fri, Jul 15, 2011 at 11:34 AM, Andrew Bresticker <abrestic@google.com>wrote:
> 
> > I've extended your patch to track write-back during page reclaim:
> > ---
> >
> > From: Andrew Bresticker <abrestic@google.com>
> > Date: Thu, 14 Jul 2011 17:56:48 -0700
> > Subject: [PATCH] vmscan: Track number of pages written back during page
> > reclaim.
> >
> > This tracks pages written out during page reclaim in memory.vmscan_stat
> > and breaks it down by file vs. anon and context (like "scanned_pages",
> > "rotated_pages", etc.).
> >
> > Example output:
> > $ mkdir /dev/cgroup/memory/1
> > $ echo 8m > /dev/cgroup/memory/1/memory.limit_in_bytes
> > $ echo $$ > /dev/cgroup/memory/1/tasks
> > $ dd if=/dev/urandom of=file_20g bs=4096 count=524288
> > $ cat /dev/cgroup/memory/1/memory.vmscan_stat
> > ...
> > written_pages_by_limit 36
> > written_anon_pages_by_limit 0
> > written_file_pages_by_limit 36
> > ...
> > written_pages_by_limit_under_hierarchy 28
> > written_anon_pages_by_limit_under_hierarchy 0
> > written_file_pages_by_limit_under_hierarchy 28
> >
> > Signed-off-by: Andrew Bresticker <abrestic@google.com>
> > ---
> >  include/linux/memcontrol.h |    1 +
> >  mm/memcontrol.c            |   12 ++++++++++++
> >  mm/vmscan.c                |   10 +++++++---
> >  3 files changed, 20 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 4b49edf..4be907e 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -46,6 +46,7 @@ struct memcg_scanrecord {
> >   unsigned long nr_scanned[2]; /* the number of scanned pages */
> >   unsigned long nr_rotated[2]; /* the number of rotated pages */
> >   unsigned long nr_freed[2]; /* the number of freed pages */
> > + unsigned long nr_written[2]; /* the number of pages written back */
> >   unsigned long elapsed; /* nsec of time elapsed while scanning */
> >  };
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 9bb6e93..5ec2aa3 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -221,6 +221,9 @@ enum {
> >   FREED,
> >   FREED_ANON,
> >   FREED_FILE,
> > + WRITTEN,
> > + WRITTEN_ANON,
> > + WRITTEN_FILE,
> >   ELAPSED,
> >   NR_SCANSTATS,
> >  };
> > @@ -241,6 +244,9 @@ const char *scanstat_string[NR_SCANSTATS] = {
> >   "freed_pages",
> >   "freed_anon_pages",
> >   "freed_file_pages",
> > + "written_pages",
> > + "written_anon_pages",
> > + "written_file_pages",
> >   "elapsed_ns",
> >  };
> >  #define SCANSTAT_WORD_LIMIT    "_by_limit"
> > @@ -1682,6 +1688,10 @@ static void __mem_cgroup_record_scanstat(unsigned
> > long *stats,
> >          stats[FREED_ANON] += rec->nr_freed[0];
> >          stats[FREED_FILE] += rec->nr_freed[1];
> >
> > + stats[WRITTEN] += rec->nr_written[0] + rec->nr_written[1];
> > + stats[WRITTEN_ANON] += rec->nr_written[0];
> > + stats[WRITTEN_FILE] += rec->nr_written[1];
> > +
> >          stats[ELAPSED] += rec->elapsed;
> >  }
> >
> > @@ -1794,6 +1804,8 @@ static int mem_cgroup_hierarchical_reclaim(struct
> > mem_cgroup *root_mem,
> >                  rec.nr_rotated[1] = 0;
> >                  rec.nr_freed[0] = 0;
> >                  rec.nr_freed[1] = 0;
> > + rec.nr_written[0] = 0;
> > + rec.nr_written[1] = 0;
> >                  rec.elapsed = 0;
> >   /* we use swappiness of local cgroup */
> >   if (check_soft) {
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 8fb1abd..f73b96e 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -719,7 +719,7 @@ static noinline_for_stack void free_page_list(struct
> > list_head *free_pages)
> >   */
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> >        struct zone *zone,
> > -      struct scan_control *sc)
> > +      struct scan_control *sc, int file)
> >  {
> >   LIST_HEAD(ret_pages);
> >   LIST_HEAD(free_pages);
> > @@ -727,6 +727,7 @@ static unsigned long shrink_page_list(struct list_head
> > *page_list,
> >   unsigned long nr_dirty = 0;
> >   unsigned long nr_congested = 0;
> >   unsigned long nr_reclaimed = 0;
> > + unsigned long nr_written = 0;
> >
> >   cond_resched();
> >
> > @@ -840,6 +841,7 @@ static unsigned long shrink_page_list(struct list_head
> > *page_list,
> >   case PAGE_ACTIVATE:
> >   goto activate_locked;
> >   case PAGE_SUCCESS:
> > + nr_written++;
> >   if (PageWriteback(page))
> >   goto keep_lumpy;
> >   if (PageDirty(page))
> > @@ -958,6 +960,8 @@ keep_lumpy:
> >   free_page_list(&free_pages);
> >
> >   list_splice(&ret_pages, page_list);
> > + if (!scanning_global_lru(sc))
> > + sc->memcg_record->nr_written[file] += nr_written;
> >   count_vm_events(PGACTIVATE, pgactivate);
> >   return nr_reclaimed;
> >  }
> > @@ -1463,7 +1467,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct
> > zone *zone,
> >
> >   spin_unlock_irq(&zone->lru_lock);
> >
> > - nr_reclaimed = shrink_page_list(&page_list, zone, sc);
> > + nr_reclaimed = shrink_page_list(&page_list, zone, sc, file);
> >
> >   if (!scanning_global_lru(sc))
> >   sc->memcg_record->nr_freed[file] += nr_reclaimed;
> > @@ -1471,7 +1475,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct
> > zone *zone,
> >   /* Check if we should syncronously wait for writeback */
> >   if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
> >   set_reclaim_mode(priority, sc, true);
> > - nr_reclaimed += shrink_page_list(&page_list, zone, sc);
> > + nr_reclaimed += shrink_page_list(&page_list, zone, sc, file);
> >   }
> >
> >   local_irq_disable();
> > --
> > 1.7.3.1
> >
> > Thanks,
> > Andrew
> >
> > On Wed, Jul 13, 2011 at 5:02 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> >> On Tue, 12 Jul 2011 16:02:02 -0700
> >> Andrew Bresticker <abrestic@google.com> wrote:
> >>
> >> > On Mon, Jul 11, 2011 at 3:30 AM, KAMEZAWA Hiroyuki <
> >> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >
> >> > >
> >> > > This patch is onto mmotm-0710... got bigger than expected ;(
> >> > > ==
> >> > > [PATCH] add memory.vmscan_stat
> >> > >
> >> > > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim
> >> in..."
> >> > > says it adds scanning stats to memory.stat file. But it doesn't
> >> because
> >> > > we considered we needed to make a concensus for such new APIs.
> >> > >
> >> > > This patch is a trial to add memory.scan_stat. This shows
> >> > >  - the number of scanned pages(total, anon, file)
> >> > >  - the number of rotated pages(total, anon, file)
> >> > >  - the number of freed pages(total, anon, file)
> >> > >  - the number of elaplsed time (including sleep/pause time)
> >> > >
> >> > >  for both of direct/soft reclaim.
> >> > >
> >> > > The biggest difference with oringinal Ying's one is that this file
> >> > > can be reset by some write, as
> >> > >
> >> > >  # echo 0 ...../memory.scan_stat
> >> > >
> >> > > Example of output is here. This is a result after make -j 6 kernel
> >> > > under 300M limit.
> >> > >
> >> > > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> >> > > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat
> >> > > scanned_pages_by_limit 9471864
> >> > > scanned_anon_pages_by_limit 6640629
> >> > > scanned_file_pages_by_limit 2831235
> >> > > rotated_pages_by_limit 4243974
> >> > > rotated_anon_pages_by_limit 3971968
> >> > > rotated_file_pages_by_limit 272006
> >> > > freed_pages_by_limit 2318492
> >> > > freed_anon_pages_by_limit 962052
> >> > > freed_file_pages_by_limit 1356440
> >> > > elapsed_ns_by_limit 351386416101
> >> > > scanned_pages_by_system 0
> >> > > scanned_anon_pages_by_system 0
> >> > > scanned_file_pages_by_system 0
> >> > > rotated_pages_by_system 0
> >> > > rotated_anon_pages_by_system 0
> >> > > rotated_file_pages_by_system 0
> >> > > freed_pages_by_system 0
> >> > > freed_anon_pages_by_system 0
> >> > > freed_file_pages_by_system 0
> >> > > elapsed_ns_by_system 0
> >> > > scanned_pages_by_limit_under_hierarchy 9471864
> >> > > scanned_anon_pages_by_limit_under_hierarchy 6640629
> >> > > scanned_file_pages_by_limit_under_hierarchy 2831235
> >> > > rotated_pages_by_limit_under_hierarchy 4243974
> >> > > rotated_anon_pages_by_limit_under_hierarchy 3971968
> >> > > rotated_file_pages_by_limit_under_hierarchy 272006
> >> > > freed_pages_by_limit_under_hierarchy 2318492
> >> > > freed_anon_pages_by_limit_under_hierarchy 962052
> >> > > freed_file_pages_by_limit_under_hierarchy 1356440
> >> > > elapsed_ns_by_limit_under_hierarchy 351386416101
> >> > > scanned_pages_by_system_under_hierarchy 0
> >> > > scanned_anon_pages_by_system_under_hierarchy 0
> >> > > scanned_file_pages_by_system_under_hierarchy 0
> >> > > rotated_pages_by_system_under_hierarchy 0
> >> > > rotated_anon_pages_by_system_under_hierarchy 0
> >> > > rotated_file_pages_by_system_under_hierarchy 0
> >> > > freed_pages_by_system_under_hierarchy 0
> >> > > freed_anon_pages_by_system_under_hierarchy 0
> >> > > freed_file_pages_by_system_under_hierarchy 0
> >> > > elapsed_ns_by_system_under_hierarchy 0
> >> > >
> >> > >
> >> > > total_xxxx is for hierarchy management.
> >> > >
> >> > > This will be useful for further memcg developments and need to be
> >> > > developped before we do some complicated rework on LRU/softlimit
> >> > > management.
> >> > >
> >> > > This patch adds a new struct memcg_scanrecord into scan_control
> >> struct.
> >> > > sc->nr_scanned at el is not designed for exporting information. For
> >> > > example,
> >> > > nr_scanned is reset frequentrly and incremented +2 at scanning mapped
> >> > > pages.
> >> > >
> >> > > For avoiding complexity, I added a new param in scan_control which is
> >> for
> >> > > exporting scanning score.
> >> > >
> >> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > >
> >> > > Changelog:
> >> > >  - renamed as vmscan_stat
> >> > >  - handle file/anon
> >> > >  - added "rotated"
> >> > >  - changed names of param in vmscan_stat.
> >> > > ---
> >> > >  Documentation/cgroups/memory.txt |   85 +++++++++++++++++++
> >> > >  include/linux/memcontrol.h       |   19 ++++
> >> > >  include/linux/swap.h             |    6 -
> >> > >  mm/memcontrol.c                  |  172
> >> > > +++++++++++++++++++++++++++++++++++++--
> >> > >  mm/vmscan.c                      |   39 +++++++-
> >> > >  5 files changed, 303 insertions(+), 18 deletions(-)
> >> > >
> >> > > Index: mmotm-0710/Documentation/cgroups/memory.txt
> >> > > ===================================================================
> >> > > --- mmotm-0710.orig/Documentation/cgroups/memory.txt
> >> > > +++ mmotm-0710/Documentation/cgroups/memory.txt
> >> > > @@ -380,7 +380,7 @@ will be charged as a new owner of it.
> >> > >
> >> > >  5.2 stat file
> >> > >
> >> > > -memory.stat file includes following statistics
> >> > > +5.2.1 memory.stat file includes following statistics
> >> > >
> >> > >  # per-memory cgroup local status
> >> > >  cache          - # of bytes of page cache memory.
> >> > > @@ -438,6 +438,89 @@ Note:
> >> > >         file_mapped is accounted only when the memory cgroup is owner
> >> of
> >> > > page
> >> > >         cache.)
> >> > >
> >> > > +5.2.2 memory.vmscan_stat
> >> > > +
> >> > > +memory.vmscan_stat includes statistics information for memory
> >> scanning and
> >> > > +freeing, reclaiming. The statistics shows memory scanning information
> >> > > since
> >> > > +memory cgroup creation and can be reset to 0 by writing 0 as
> >> > > +
> >> > > + #echo 0 > ../memory.vmscan_stat
> >> > > +
> >> > > +This file contains following statistics.
> >> > > +
> >> > > +[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
> >> > > +[param]_elapsed_ns_by_[reason]_[under_hierarchy]
> >> > > +
> >> > > +For example,
> >> > > +
> >> > > +  scanned_file_pages_by_limit indicates the number of scanned
> >> > > +  file pages at vmscan.
> >> > > +
> >> > > +Now, 3 parameters are supported
> >> > > +
> >> > > +  scanned - the number of pages scanned by vmscan
> >> > > +  rotated - the number of pages activated at vmscan
> >> > > +  freed   - the number of pages freed by vmscan
> >> > > +
> >> > > +If "rotated" is high against scanned/freed, the memcg seems busy.
> >> > > +
> >> > > +Now, 2 reason are supported
> >> > > +
> >> > > +  limit - the memory cgroup's limit
> >> > > +  system - global memory pressure + softlimit
> >> > > +           (global memory pressure not under softlimit is not handled
> >> now)
> >> > > +
> >> > > +When under_hierarchy is added in the tail, the number indicates the
> >> > > +total memcg scan of its children and itself.
> >> > > +
> >> > > +elapsed_ns is a elapsed time in nanosecond. This may include sleep
> >> time
> >> > > +and not indicates CPU usage. So, please take this as just showing
> >> > > +latency.
> >> > > +
> >> > > +Here is an example.
> >> > > +
> >> > > +# cat /cgroup/memory/A/memory.vmscan_stat
> >> > > +scanned_pages_by_limit 9471864
> >> > > +scanned_anon_pages_by_limit 6640629
> >> > > +scanned_file_pages_by_limit 2831235
> >> > > +rotated_pages_by_limit 4243974
> >> > > +rotated_anon_pages_by_limit 3971968
> >> > > +rotated_file_pages_by_limit 272006
> >> > > +freed_pages_by_limit 2318492
> >> > > +freed_anon_pages_by_limit 962052
> >> > > +freed_file_pages_by_limit 1356440
> >> > > +elapsed_ns_by_limit 351386416101
> >> > > +scanned_pages_by_system 0
> >> > > +scanned_anon_pages_by_system 0
> >> > > +scanned_file_pages_by_system 0
> >> > > +rotated_pages_by_system 0
> >> > > +rotated_anon_pages_by_system 0
> >> > > +rotated_file_pages_by_system 0
> >> > > +freed_pages_by_system 0
> >> > > +freed_anon_pages_by_system 0
> >> > > +freed_file_pages_by_system 0
> >> > > +elapsed_ns_by_system 0
> >> > > +scanned_pages_by_limit_under_hierarchy 9471864
> >> > > +scanned_anon_pages_by_limit_under_hierarchy 6640629
> >> > > +scanned_file_pages_by_limit_under_hierarchy 2831235
> >> > > +rotated_pages_by_limit_under_hierarchy 4243974
> >> > > +rotated_anon_pages_by_limit_under_hierarchy 3971968
> >> > > +rotated_file_pages_by_limit_under_hierarchy 272006
> >> > > +freed_pages_by_limit_under_hierarchy 2318492
> >> > > +freed_anon_pages_by_limit_under_hierarchy 962052
> >> > > +freed_file_pages_by_limit_under_hierarchy 1356440
> >> > > +elapsed_ns_by_limit_under_hierarchy 351386416101
> >> > > +scanned_pages_by_system_under_hierarchy 0
> >> > > +scanned_anon_pages_by_system_under_hierarchy 0
> >> > > +scanned_file_pages_by_system_under_hierarchy 0
> >> > > +rotated_pages_by_system_under_hierarchy 0
> >> > > +rotated_anon_pages_by_system_under_hierarchy 0
> >> > > +rotated_file_pages_by_system_under_hierarchy 0
> >> > > +freed_pages_by_system_under_hierarchy 0
> >> > > +freed_anon_pages_by_system_under_hierarchy 0
> >> > > +freed_file_pages_by_system_under_hierarchy 0
> >> > > +elapsed_ns_by_system_under_hierarchy 0
> >> > > +
> >> > >  5.3 swappiness
> >> > >
> >> > >  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of
> >> groups
> >> > > only.
> >> > > Index: mmotm-0710/include/linux/memcontrol.h
> >> > > ===================================================================
> >> > > --- mmotm-0710.orig/include/linux/memcontrol.h
> >> > > +++ mmotm-0710/include/linux/memcontrol.h
> >> > > @@ -39,6 +39,16 @@ extern unsigned long mem_cgroup_isolate_
> >> > >                                        struct mem_cgroup *mem_cont,
> >> > >                                        int active, int file);
> >> > >
> >> > > +struct memcg_scanrecord {
> >> > > +       struct mem_cgroup *mem; /* scanend memory cgroup */
> >> > > +       struct mem_cgroup *root; /* scan target hierarchy root */
> >> > > +       int context;            /* scanning context (see memcontrol.c)
> >> */
> >> > > +       unsigned long nr_scanned[2]; /* the number of scanned pages */
> >> > > +       unsigned long nr_rotated[2]; /* the number of rotated pages */
> >> > > +       unsigned long nr_freed[2]; /* the number of freed pages */
> >> > > +       unsigned long elapsed; /* nsec of time elapsed while scanning
> >> */
> >> > > +};
> >> > > +
> >> > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >> > >  /*
> >> > >  * All "charge" functions with gfp_mask should use GFP_KERNEL or
> >> > > @@ -117,6 +127,15 @@ mem_cgroup_get_reclaim_stat_from_page(st
> >> > >  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >> > >                                        struct task_struct *p);
> >> > >
> >> > > +extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup
> >> *mem,
> >> > > +                                                 gfp_t gfp_mask, bool
> >> > > noswap,
> >> > > +                                                 struct
> >> memcg_scanrecord
> >> > > *rec);
> >> > > +extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup
> >> *mem,
> >> > > +                                               gfp_t gfp_mask, bool
> >> > > noswap,
> >> > > +                                               struct zone *zone,
> >> > > +                                               struct
> >> memcg_scanrecord
> >> > > *rec,
> >> > > +                                               unsigned long
> >> *nr_scanned);
> >> > > +
> >> > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >> > >  extern int do_swap_account;
> >> > >  #endif
> >> > > Index: mmotm-0710/include/linux/swap.h
> >> > > ===================================================================
> >> > > --- mmotm-0710.orig/include/linux/swap.h
> >> > > +++ mmotm-0710/include/linux/swap.h
> >> > > @@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st
> >> > >  /* linux/mm/vmscan.c */
> >> > >  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int
> >> > > order,
> >> > >                                        gfp_t gfp_mask, nodemask_t
> >> *mask);
> >> > > -extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup
> >> *mem,
> >> > > -                                                 gfp_t gfp_mask, bool
> >> > > noswap);
> >> > > -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup
> >> *mem,
> >> > > -                                               gfp_t gfp_mask, bool
> >> > > noswap,
> >> > > -                                               struct zone *zone,
> >> > > -                                               unsigned long
> >> *nr_scanned);
> >> > >  extern int __isolate_lru_page(struct page *page, int mode, int file);
> >> > >  extern unsigned long shrink_all_memory(unsigned long nr_pages);
> >> > >  extern int vm_swappiness;
> >> > > Index: mmotm-0710/mm/memcontrol.c
> >> > > ===================================================================
> >> > > --- mmotm-0710.orig/mm/memcontrol.c
> >> > > +++ mmotm-0710/mm/memcontrol.c
> >> > > @@ -204,6 +204,50 @@ struct mem_cgroup_eventfd_list {
> >> > >  static void mem_cgroup_threshold(struct mem_cgroup *mem);
> >> > >  static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
> >> > >
> >> > > +enum {
> >> > > +       SCAN_BY_LIMIT,
> >> > > +       SCAN_BY_SYSTEM,
> >> > > +       NR_SCAN_CONTEXT,
> >> > > +       SCAN_BY_SHRINK, /* not recorded now */
> >> > > +};
> >> > > +
> >> > > +enum {
> >> > > +       SCAN,
> >> > > +       SCAN_ANON,
> >> > > +       SCAN_FILE,
> >> > > +       ROTATE,
> >> > > +       ROTATE_ANON,
> >> > > +       ROTATE_FILE,
> >> > > +       FREED,
> >> > > +       FREED_ANON,
> >> > > +       FREED_FILE,
> >> > > +       ELAPSED,
> >> > > +       NR_SCANSTATS,
> >> > > +};
> >> > > +
> >> > > +struct scanstat {
> >> > > +       spinlock_t      lock;
> >> > > +       unsigned long   stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
> >> > > +       unsigned long   rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
> >> > > +};
> >> > >
> >> >
> >> > I'm working on a similar effort with Ying here at Google and so far
> >> we've
> >> > been using per-cpu counters for these statistics instead of spin-lock
> >> > protected counters.  Clearly the spin-lock protected counters have less
> >> > memory overhead and make reading the stat file faster, but our concern
> >> is
> >> > that this method is inconsistent with the other memory stat files such
> >> > /proc/vmstat and /dev/cgroup/memory/.../memory.stat.  Is there any
> >> > particular reason you chose to use spin-lock protected counters instead
> >> of
> >> > per-cpu counters?
> >> >
> >>
> >> In my experience, if we do "batch" enouch, it works always better than
> >> percpu-counter. percpu counter is effective when batching is difficult.
> >> This patch's implementation does enough batching and it's much coarse
> >> grained than percpu counter. Then, this patch is better than percpu.
> >>
> >>
> >> > I've also modified your patch to use per-cpu counters instead of
> >> spin-lock
> >> > protected counters.  I tested it by doing streaming I/O from a ramdisk:
> >> >
> >> > $ mke2fs /dev/ram1
> >> > $ mkdir /tmp/swapram
> >> > $ mkdir /tmp/swapram/ram1
> >> > $ mount -t ext2 /dev/ram1 /tmp/swapram/ram1
> >> > $ dd if=/dev/urandom of=/tmp/swapram/ram1/file_16m bs=4096 count=4096
> >> > $ mkdir /dev/cgroup/memory/1
> >> > $ echo 8m > /dev/cgroup/memory/1
> >> > $ ./ramdisk_load.sh 7
> >> > $ echo $$ > /dev/cgroup/memory/1/tasks
> >> > $ time for ((z=0; z<=2000; z++)); do cat /tmp/swapram/ram1/file_16m >
> >> > /dev/zero; done
> >> >
> >> > Where ramdisk_load.sh is:
> >> > for ((i=0; i<=$1; i++))
> >> > do
> >> >   echo $$ >/dev/cgroup/memory/1/tasks
> >> >   for ((z=0; z<=2000; z++)); do cat /tmp/swapram/ram1/file_16m >
> >> /dev/zero;
> >> > done &
> >> > done
> >> >
> >> > Surprisingly, the per-cpu counters perform worse than the spin-lock
> >> > protected counters.  Over 10 runs of the test above, the per-cpu
> >> counters
> >> > were 1.60% slower in both real time and sys time.  I'm wondering if you
> >> have
> >> > any insight as to why this is.  I can provide my diff against your patch
> >> if
> >> > necessary.
> >> >
> >>
> >> The percpu counte works effectively only when we use +1/-1 at each change
> >> of
> >> counters. It uses "batch" to merge the per-cpu value to the counter.
> >> I think you use default "batch" value but the scan/rotate/free/elapsed
> >> value
> >> is always larger than "batch" and you just added memory overhead and "if"
> >> to pure spinlock counters.
> >>
> >> Determining this "batch" threshold for percpu counter is difficult.
> >>
> >> Thanks,
> >> -Kame
> >>
> >>
> >>
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
