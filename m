Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E40158D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:20:36 -0500 (EST)
Received: by iwc10 with SMTP id 10so3251551iwc.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:18:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTikfbqjk18JM8pTh+F6QR69m+QxQzdw6CQGOuZjH@mail.gmail.com>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<5677f3262774f4ddc24044065b7cbd6443ac5e16.1297940291.git.minchan.kim@gmail.com>
	<20110218005020.d202acd2.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikfbqjk18JM8pTh+F6QR69m+QxQzdw6CQGOuZjH@mail.gmail.com>
Date: Fri, 18 Feb 2011 13:18:37 +0900
Message-ID: <AANLkTik+Kw0N8b=ny+NxjBAh577P3=GZmatRkTV1ZD7s@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] deactivate invalidated pages
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

2011/2/18 Minchan Kim <minchan.kim@gmail.com>:
> On Fri, Feb 18, 2011 at 12:50 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Fri, 18 Feb 2011 00:08:19 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>>> Recently, there are reported problem about thrashing.
>>> (http://marc.info/?l=3Drsync&m=3D128885034930933&w=3D2)
>>> It happens by backup workloads(ex, nightly rsync).
>>> That's because the workload makes just use-once pages
>>> and touches pages twice. It promotes the page into
>>> active list so that it results in working set page eviction.
>>>
>>> Some app developer want to support POSIX_FADV_NOREUSE.
>>> But other OSes don't support it, either.
>>> (http://marc.info/?l=3Dlinux-mm&m=3D128928979512086&w=3D2)
>>>
>>> By other approach, app developers use POSIX_FADV_DONTNEED.
>>> But it has a problem. If kernel meets page is writing
>>> during invalidate_mapping_pages, it can't work.
>>> It makes for application programmer to use it since they always
>>> have to sync data before calling fadivse(..POSIX_FADV_DONTNEED) to
>>> make sure the pages could be discardable. At last, they can't use
>>> deferred write of kernel so that they could see performance loss.
>>> (http://insights.oetiker.ch/linux/fadvise.html)
>>>
>>> In fact, invalidation is very big hint to reclaimer.
>>> It means we don't use the page any more. So let's move
>>> the writing page into inactive list's head if we can't truncate
>>> it right now.
>>>
>>> Why I move page to head of lru on this patch, Dirty/Writeback page
>>> would be flushed sooner or later. It can prevent writeout of pageout
>>> which is less effective than flusher's writeout.
>>>
>>> Originally, I reused lru_demote of Peter with some change so added
>>> his Signed-off-by.
>>>
>>> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
>>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>>> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>>> Acked-by: Rik van Riel <riel@redhat.com>
>>> Acked-by: Mel Gorman <mel@csn.ul.ie>
>>> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Nick Piggin <npiggin@kernel.dk>
>>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>>
>>
>> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> One question is ....it seems there is no flush() code for percpu pagevec
>> in this patch. Is it safe against cpu hot plug ?
>>
>> And from memory hot unplug point of view, I'm grad if pagevec for this
>> is flushed at the same time as when we clear other per-cpu lru pagevecs.
>> (And compaction will be affected by the page_count() magic by pagevec
>> =A0which is flushed only when FADVISE is called.)
>>
>> Could you add add-on patches for flushing and hooks ?
>
> Isn't it enough in my patch? If I miss your point, Could you elaborate pl=
ease?
>
> =A0* Drain pages out of the cpu's pagevecs.
> =A0* Either "cpu" is the current CPU, and preemption has already been
> =A0* disabled; or "cpu" is being hot-unplugged, and is already dead.
> @@ -372,6 +427,29 @@ static void drain_cpu_pagevecs(int cpu)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pagevec_move_tail(pvec);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);
> =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 pvec =3D &per_cpu(lru_deactivate_pvecs, cpu);
> + =A0 =A0 =A0 if (pagevec_count(pvec))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ____pagevec_lru_deactivate(pvec);
> +}
>

I'm sorry that I missed this line. It seems I was wrong.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
