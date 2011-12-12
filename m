Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id B2C7A6B00A1
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 20:19:16 -0500 (EST)
Message-ID: <4EE55684.30204@tao.ma>
Date: Mon, 12 Dec 2011 09:19:00 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [PATCH V2] vmscan/trace: Add 'active' and 'file' info to trace_mm_vmscan_lru_isolate.
References: <1323614784-2924-1-git-send-email-tm@tao.ma> <CAEwNFnCXJuH53ks=qPdHkm_hrcm+Nsh7f5APQx6BgQEQBKC_yQ@mail.gmail.com>
In-Reply-To: <CAEwNFnCXJuH53ks=qPdHkm_hrcm+Nsh7f5APQx6BgQEQBKC_yQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/12/2011 08:59 AM, Minchan Kim wrote:
> Hi Tao,
> 
> On Sun, Dec 11, 2011 at 11:46 PM, Tao Ma <tm@tao.ma> wrote:
>> From: Tao Ma <boyu.mt@taobao.com>
>>
>> In trace_mm_vmscan_lru_isolate, we don't output 'active' and 'file'
>> information to the trace event and it is a bit inconvenient for the
>> user to get the real information(like pasted below).
>> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
>> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>>
>> So this patch adds these 2 info to the trace event and it now looks like:
>> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
>> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 active=1 file=0
>>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Christoph Hellwig <hch@infradead.org>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Tao Ma <boyu.mt@taobao.com>
>> ---
>>  include/trace/events/vmscan.h |   25 +++++++++++++++++--------
>>  mm/memcontrol.c               |    2 +-
>>  mm/vmscan.c                   |    6 +++---
>>  3 files changed, 21 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
>> index edc4b3d..82bc49c 100644
>> --- a/include/trace/events/vmscan.h
>> +++ b/include/trace/events/vmscan.h
>> @@ -266,9 +266,10 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
>>                unsigned long nr_lumpy_taken,
>>                unsigned long nr_lumpy_dirty,
>>                unsigned long nr_lumpy_failed,
>> -               isolate_mode_t isolate_mode),
>> +               isolate_mode_t isolate_mode,
>> +               int active, int file),
>>
>> -       TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
>> +       TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, file),
>>
>>        TP_STRUCT__entry(
>>                __field(int, order)
>> @@ -279,6 +280,8 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
>>                __field(unsigned long, nr_lumpy_dirty)
>>                __field(unsigned long, nr_lumpy_failed)
>>                __field(isolate_mode_t, isolate_mode)
>> +               __field(int, active)
>> +               __field(int, file)
>>        ),
>>
>>        TP_fast_assign(
>> @@ -290,9 +293,11 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
>>                __entry->nr_lumpy_dirty = nr_lumpy_dirty;
>>                __entry->nr_lumpy_failed = nr_lumpy_failed;
>>                __entry->isolate_mode = isolate_mode;
>> +               __entry->active = active;
>> +               __entry->file = file;
>>        ),
>>
>> -       TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu",
>> +       TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu active=%d file=%d",
>>                __entry->isolate_mode,
>>                __entry->order,
>>                __entry->nr_requested,
>> @@ -300,7 +305,9 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
>>                __entry->nr_taken,
>>                __entry->nr_lumpy_taken,
>>                __entry->nr_lumpy_dirty,
>> -               __entry->nr_lumpy_failed)
>> +               __entry->nr_lumpy_failed,
>> +               __entry->active,
>> +               __entry->file)
>>  );
>>
>>  DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
>> @@ -312,9 +319,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
>>                unsigned long nr_lumpy_taken,
>>                unsigned long nr_lumpy_dirty,
>>                unsigned long nr_lumpy_failed,
>> -               isolate_mode_t isolate_mode),
>> +               isolate_mode_t isolate_mode,
>> +               int active, int file),
>>
>> -       TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
>> +       TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, file)
>>
>>  );
>>
>> @@ -327,9 +335,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
>>                unsigned long nr_lumpy_taken,
>>                unsigned long nr_lumpy_dirty,
>>                unsigned long nr_lumpy_failed,
>> -               isolate_mode_t isolate_mode),
>> +               isolate_mode_t isolate_mode,
>> +               int active, int file),
>>
>> -       TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
>> +       TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, file)
>>
>>  );
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 6aff93c..246fbce 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1249,7 +1249,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>>        *scanned = scan;
>>
>>        trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
>> -                                     0, 0, 0, mode);
>> +                                     0, 0, 0, mode, active, file);
>>
>>        return nr_taken;
>>  }
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index f54a05b..97955ca 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1103,7 +1103,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
>>  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>                struct list_head *src, struct list_head *dst,
>>                unsigned long *scanned, int order, isolate_mode_t mode,
>> -               int file)
>> +               int active, int file)
>>  {
>>        unsigned long nr_taken = 0;
>>        unsigned long nr_lumpy_taken = 0;
>> @@ -1221,7 +1221,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>                        nr_to_scan, scan,
>>                        nr_taken,
>>                        nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
>> -                       mode);
>> +                       mode, active, file);
>>        return nr_taken;
>>  }
>>
>> @@ -1237,7 +1237,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
>>        if (file)
>>                lru += LRU_FILE;
>>        return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
>> -                                                               mode, file);
>> +                                                       mode, active, file);
> 
> I guess you want to count exact scanning number of which lru list.
> But It's impossible now since we do lumpy reclaim so that trace's
> result is mixed by active/inactive list scanning.
> And I don't like adding new argument for just trace although it's trivial.
yeah, I know we do lumpy reclaim, but it has no hint about whether it is
a file or anon lru. So I think we at least need a 'file=[0/1]' in this
trace event.
> 
> I think 'mode' is more proper rather than  specific 'active'.
> The 'mode' can achieve your goal without passing new argument "active".
sorry, but how can we find the real relationship between 'mode' and
'active'? I am not quite familiar with this field. So if you can
explicit describe it, I am fine to drop this field.

Thanks
Tao
> 
> In addition to, current mmotm has various modes.
> So sometime we can get more specific result rather than vauge 'active'.
> 
> 
> /* Isolate inactive pages */
> #define ISOLATE_INACTIVE        ((__force fmode_t)0x1)
> /* Isolate active pages */
> #define ISOLATE_ACTIVE          ((__force fmode_t)0x2)
> /* Isolate clean file */
> #define ISOLATE_CLEAN           ((__force fmode_t)0x4)
> /* Isolate unmapped file */
> #define ISOLATE_UNMAPPED        ((__force fmode_t)0x8)
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
