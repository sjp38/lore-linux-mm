Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 743BE6B00A2
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 20:23:45 -0500 (EST)
Received: by iahk25 with SMTP id k25so10397188iah.14
        for <linux-mm@kvack.org>; Sun, 11 Dec 2011 17:23:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EE55684.30204@tao.ma>
References: <1323614784-2924-1-git-send-email-tm@tao.ma>
	<CAEwNFnCXJuH53ks=qPdHkm_hrcm+Nsh7f5APQx6BgQEQBKC_yQ@mail.gmail.com>
	<4EE55684.30204@tao.ma>
Date: Mon, 12 Dec 2011 10:23:44 +0900
Message-ID: <CAEwNFnAApCLfnd3AgyEeao4dPT9nwY4CKWDJrXQ9pwiAQcj85Q@mail.gmail.com>
Subject: Re: [PATCH V2] vmscan/trace: Add 'active' and 'file' info to trace_mm_vmscan_lru_isolate.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 12, 2011 at 10:19 AM, Tao Ma <tm@tao.ma> wrote:
> On 12/12/2011 08:59 AM, Minchan Kim wrote:
>> Hi Tao,
>>
>> On Sun, Dec 11, 2011 at 11:46 PM, Tao Ma <tm@tao.ma> wrote:
>>> From: Tao Ma <boyu.mt@taobao.com>
>>>
>>> In trace_mm_vmscan_lru_isolate, we don't output 'active' and 'file'
>>> information to the trace event and it is a bit inconvenient for the
>>> user to get the real information(like pasted below).
>>> mm_vmscan_lru_isolate: isolate_mode=3D2 order=3D0 nr_requested=3D32 nr_=
scanned=3D32
>>> nr_taken=3D32 contig_taken=3D0 contig_dirty=3D0 contig_failed=3D0
>>>
>>> So this patch adds these 2 info to the trace event and it now looks lik=
e:
>>> mm_vmscan_lru_isolate: isolate_mode=3D2 order=3D0 nr_requested=3D32 nr_=
scanned=3D32
>>> nr_taken=3D32 contig_taken=3D0 contig_dirty=3D0 contig_failed=3D0 activ=
e=3D1 file=3D0
>>>
>>> Cc: Mel Gorman <mel@csn.ul.ie>
>>> Cc: Rik van Riel <riel@redhat.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Christoph Hellwig <hch@infradead.org>
>>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Signed-off-by: Tao Ma <boyu.mt@taobao.com>
>>> ---
>>> =C2=A0include/trace/events/vmscan.h | =C2=A0 25 +++++++++++++++++------=
--
>>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 =C2=A02 +-
>>> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | =C2=A0 =C2=A06 +++---
>>> =C2=A03 files changed, 21 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmsca=
n.h
>>> index edc4b3d..82bc49c 100644
>>> --- a/include/trace/events/vmscan.h
>>> +++ b/include/trace/events/vmscan.h
>>> @@ -266,9 +266,10 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template=
,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_taken,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_dirty,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_failed,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t isola=
te_mode),
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t isola=
te_mode,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int active, int file=
),
>>>
>>> - =C2=A0 =C2=A0 =C2=A0 TP_ARGS(order, nr_requested, nr_scanned, nr_take=
n, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
>>> + =C2=A0 =C2=A0 =C2=A0 TP_ARGS(order, nr_requested, nr_scanned, nr_take=
n, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, f=
ile),
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0TP_STRUCT__entry(
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__field(int, ord=
er)
>>> @@ -279,6 +280,8 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__field(unsigned=
 long, nr_lumpy_dirty)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__field(unsigned=
 long, nr_lumpy_failed)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__field(isolate_=
mode_t, isolate_mode)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __field(int, active)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __field(int, file)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0),
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0TP_fast_assign(
>>> @@ -290,9 +293,11 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template=
,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->nr_lump=
y_dirty =3D nr_lumpy_dirty;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->nr_lump=
y_failed =3D nr_lumpy_failed;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->isolate=
_mode =3D isolate_mode;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __entry->active =3D =
active;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __entry->file =3D fi=
le;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0),
>>>
>>> - =C2=A0 =C2=A0 =C2=A0 TP_printk("isolate_mode=3D%d order=3D%d nr_reque=
sted=3D%lu nr_scanned=3D%lu nr_taken=3D%lu contig_taken=3D%lu contig_dirty=
=3D%lu contig_failed=3D%lu",
>>> + =C2=A0 =C2=A0 =C2=A0 TP_printk("isolate_mode=3D%d order=3D%d nr_reque=
sted=3D%lu nr_scanned=3D%lu nr_taken=3D%lu contig_taken=3D%lu contig_dirty=
=3D%lu contig_failed=3D%lu active=3D%d file=3D%d",
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->isolate=
_mode,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->order,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->nr_requ=
ested,
>>> @@ -300,7 +305,9 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->nr_take=
n,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->nr_lump=
y_taken,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__entry->nr_lump=
y_dirty,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __entry->nr_lumpy_fa=
iled)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __entry->nr_lumpy_fa=
iled,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __entry->active,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __entry->file)
>>> =C2=A0);
>>>
>>> =C2=A0DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolat=
e,
>>> @@ -312,9 +319,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vm=
scan_lru_isolate,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_taken,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_dirty,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_failed,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t isola=
te_mode),
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t isola=
te_mode,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int active, int file=
),
>>>
>>> - =C2=A0 =C2=A0 =C2=A0 TP_ARGS(order, nr_requested, nr_scanned, nr_take=
n, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
>>> + =C2=A0 =C2=A0 =C2=A0 TP_ARGS(order, nr_requested, nr_scanned, nr_take=
n, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, f=
ile)
>>>
>>> =C2=A0);
>>>
>>> @@ -327,9 +335,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vm=
scan_memcg_isolate,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_taken,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_dirty,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr=
_lumpy_failed,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t isola=
te_mode),
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t isola=
te_mode,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int active, int file=
),
>>>
>>> - =C2=A0 =C2=A0 =C2=A0 TP_ARGS(order, nr_requested, nr_scanned, nr_take=
n, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
>>> + =C2=A0 =C2=A0 =C2=A0 TP_ARGS(order, nr_requested, nr_scanned, nr_take=
n, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, f=
ile)
>>>
>>> =C2=A0);
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 6aff93c..246fbce 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -1249,7 +1249,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned l=
ong nr_to_scan,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*scanned =3D scan;
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0trace_mm_vmscan_memcg_isolate(0, nr_to_scan,=
 scan, nr_taken,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0, 0, 0, mode);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0, 0, 0, mode, act=
ive, file);
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return nr_taken;
>>> =C2=A0}
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index f54a05b..97955ca 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1103,7 +1103,7 @@ int __isolate_lru_page(struct page *page, isolate=
_mode_t mode, int file)
>>> =C2=A0static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head=
 *src, struct list_head *dst,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long *s=
canned, int order, isolate_mode_t mode,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int file)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int active, int file=
)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_taken =3D 0;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_lumpy_taken =3D 0;
>>> @@ -1221,7 +1221,7 @@ static unsigned long isolate_lru_pages(unsigned l=
ong nr_to_scan,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0nr_to_scan, scan,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0nr_taken,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mode);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mode, active, file);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return nr_taken;
>>> =C2=A0}
>>>
>>> @@ -1237,7 +1237,7 @@ static unsigned long isolate_pages_global(unsigne=
d long nr,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (file)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lru +=3D LRU_FIL=
E;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return isolate_lru_pages(nr, &z->lru[lru].li=
st, dst, scanned, order,
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 m=
ode, file);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mode, active, file);
>>
>> I guess you want to count exact scanning number of which lru list.
>> But It's impossible now since we do lumpy reclaim so that trace's
>> result is mixed by active/inactive list scanning.
>> And I don't like adding new argument for just trace although it's trivia=
l.
> yeah, I know we do lumpy reclaim, but it has no hint about whether it is
> a file or anon lru. So I think we at least need a 'file=3D[0/1]' in this
> trace event.
>>
>> I think 'mode' is more proper rather than =C2=A0specific 'active'.
>> The 'mode' can achieve your goal without passing new argument "active".
> sorry, but how can we find the real relationship between 'mode' and
> 'active'? I am not quite familiar with this field. So if you can
> explicit describe it, I am fine to drop this field.


mode is following as,

/* Isolate inactive pages */
#define ISOLATE_INACTIVE        ((__force fmode_t)0x1)
/* Isolate active pages */
#define ISOLATE_ACTIVE          ((__force fmode_t)0x2)
/* Isolate clean file */
#define ISOLATE_CLEAN           ((__force fmode_t)0x4)
/* Isolate unmapped file */
#define ISOLATE_UNMAPPED        ((__force fmode_t)0x8)

For example,

If mode is 0x1, it means we are isolating inactive.
If mode is 0x2, it means we are isolating active.
If mode is 0x4|0x2, it mean we are isolating clear pages in active list.
If mode is 0x8|0x2, it mean we are isolate unmapped page in active list.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
