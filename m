Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C17CF6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 01:12:48 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w9so159367931oia.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 22:12:48 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i83si11235901ioa.48.2016.06.07.22.12.46
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 22:12:47 -0700 (PDT)
Date: Wed, 8 Jun 2016 14:13:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Message-ID: <20160608051352.GA28155@bbox>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox>
 <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

On Wed, Jun 08, 2016 at 09:48:30AM +0800, Ganesh Mahendran wrote:
> Hi, Minchan:
> 
> 2016-06-08 8:16 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > Hello Ganesh,
> >
> > On Tue, Jun 07, 2016 at 04:56:44PM +0800, Ganesh Mahendran wrote:
> >> Currently zsmalloc is widely used in android device.
> >> Sometimes, we want to see how frequently zs_compact is
> >> triggered or how may pages freed by zs_compact(), or which
> >> zsmalloc pool is compacted.
> >>
> >> Most of the time, user can get the brief information from
> >> trace_mm_shrink_slab_[start | end], but in some senario,
> >> they do not use zsmalloc shrinker, but trigger compaction manually.
> >> So add some trace events in zs_compact is convenient. Also we
> >> can add some zsmalloc specific information(pool name, total compact
> >> pages, etc) in zsmalloc trace.
> >
> > Sorry, I cannot understand what's the problem now and what you want to
> > solve. Could you elaborate it a bit?
> >
> > Thanks.
> 
> We have backported the zs_compact() to our product(kernel 3.18).
> It is usefull for a longtime running device.
> But there is not a convenient way to get the detailed information
> of zs_comapct() which is usefull for  performance optimization.
> Information about how much time zs_compact used, which pool is
> compacted, how many page freed, etc.

You can know how many pages are freed by object compaction via mm_stat
each /sys/block/zram-id/mm_stat. And you can use function_graph to know
how much time zs_compact used.


> With these information, we will know what is going on in zs_comapct.
> And draw the relation between free mem and zs_comapct.
> 
> >
> >>
> >> This patch add two trace events for zs_compact(), below the trace log:
> >> -----------------------------
> >> root@land:/ # cat /d/tracing/trace
> >>          kswapd0-125   [007] ...1   174.176979: zsmalloc_compact_start: pool zram0
> >>          kswapd0-125   [007] ...1   174.181967: zsmalloc_compact_end: pool zram0: 608 pages compacted(total 1794)
> >>          kswapd0-125   [000] ...1   184.134475: zsmalloc_compact_start: pool zram0
> >>          kswapd0-125   [000] ...1   184.135010: zsmalloc_compact_end: pool zram0: 62 pages compacted(total 1856)
> >>          kswapd0-125   [003] ...1   226.927221: zsmalloc_compact_start: pool zram0
> >>          kswapd0-125   [003] ...1   226.928575: zsmalloc_compact_end: pool zram0: 250 pages compacted(total 2106)
> >> -----------------------------
> >>
> >> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> >> ---
> >>  include/trace/events/zsmalloc.h | 56 +++++++++++++++++++++++++++++++++++++++++
> >>  mm/zsmalloc.c                   | 10 ++++++++
> >>  2 files changed, 66 insertions(+)
> >>  create mode 100644 include/trace/events/zsmalloc.h
> >>
> >> diff --git a/include/trace/events/zsmalloc.h b/include/trace/events/zsmalloc.h
> >> new file mode 100644
> >> index 0000000..3b6f14e
> >> --- /dev/null
> >> +++ b/include/trace/events/zsmalloc.h
> >> @@ -0,0 +1,56 @@
> >> +#undef TRACE_SYSTEM
> >> +#define TRACE_SYSTEM zsmalloc
> >> +
> >> +#if !defined(_TRACE_ZSMALLOC_H) || defined(TRACE_HEADER_MULTI_READ)
> >> +#define _TRACE_ZSMALLOC_H
> >> +
> >> +#include <linux/types.h>
> >> +#include <linux/tracepoint.h>
> >> +
> >> +TRACE_EVENT(zsmalloc_compact_start,
> >> +
> >> +     TP_PROTO(const char *pool_name),
> >> +
> >> +     TP_ARGS(pool_name),
> >> +
> >> +     TP_STRUCT__entry(
> >> +             __field(const char *, pool_name)
> >> +     ),
> >> +
> >> +     TP_fast_assign(
> >> +             __entry->pool_name = pool_name;
> >> +     ),
> >> +
> >> +     TP_printk("pool %s",
> >> +               __entry->pool_name)
> >> +);
> >> +
> >> +TRACE_EVENT(zsmalloc_compact_end,
> >> +
> >> +     TP_PROTO(const char *pool_name, unsigned long pages_compacted,
> >> +                     unsigned long pages_total_compacted),
> >> +
> >> +     TP_ARGS(pool_name, pages_compacted, pages_total_compacted),
> >> +
> >> +     TP_STRUCT__entry(
> >> +             __field(const char *, pool_name)
> >> +             __field(unsigned long, pages_compacted)
> >> +             __field(unsigned long, pages_total_compacted)
> >> +     ),
> >> +
> >> +     TP_fast_assign(
> >> +             __entry->pool_name = pool_name;
> >> +             __entry->pages_compacted = pages_compacted;
> >> +             __entry->pages_total_compacted = pages_total_compacted;
> >> +     ),
> >> +
> >> +     TP_printk("pool %s: %ld pages compacted(total %ld)",
> >> +               __entry->pool_name,
> >> +               __entry->pages_compacted,
> >> +               __entry->pages_total_compacted)
> >> +);
> >> +
> >> +#endif /* _TRACE_ZSMALLOC_H */
> >> +
> >> +/* This part must be outside protection */
> >> +#include <trace/define_trace.h>
> >> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >> index 213d0e1..441b9f7 100644
> >> --- a/mm/zsmalloc.c
> >> +++ b/mm/zsmalloc.c
> >> @@ -30,6 +30,8 @@
> >>
> >>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> >>
> >> +#define CREATE_TRACE_POINTS
> >> +
> >>  #include <linux/module.h>
> >>  #include <linux/kernel.h>
> >>  #include <linux/sched.h>
> >> @@ -52,6 +54,7 @@
> >>  #include <linux/mount.h>
> >>  #include <linux/compaction.h>
> >>  #include <linux/pagemap.h>
> >> +#include <trace/events/zsmalloc.h>
> >>
> >>  #define ZSPAGE_MAGIC 0x58
> >>
> >> @@ -2330,6 +2333,9 @@ unsigned long zs_compact(struct zs_pool *pool)
> >>  {
> >>       int i;
> >>       struct size_class *class;
> >> +     unsigned long pages_compacted_before = pool->stats.pages_compacted;
> >> +
> >> +     trace_zsmalloc_compact_start(pool->name);
> >>
> >>       for (i = zs_size_classes - 1; i >= 0; i--) {
> >>               class = pool->size_class[i];
> >> @@ -2340,6 +2346,10 @@ unsigned long zs_compact(struct zs_pool *pool)
> >>               __zs_compact(pool, class);
> >>       }
> >>
> >> +     trace_zsmalloc_compact_end(pool->name,
> >> +             pool->stats.pages_compacted - pages_compacted_before,
> >> +             pool->stats.pages_compacted);
> >> +
> >>       return pool->stats.pages_compacted;
> >>  }
> >>  EXPORT_SYMBOL_GPL(zs_compact);
> >> --
> >> 1.9.1
> >>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
