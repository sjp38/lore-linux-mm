Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 591176B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:18:46 -0500 (EST)
Received: by qyk7 with SMTP id 7so817690qyk.14
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 22:18:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130052204.GB15564@cmpxchg.org>
References: <cover.1291043273.git.minchan.kim@gmail.com>
	<6e01d81a4b575dcaaacc6b3782c505103e024085.1291043274.git.minchan.kim@gmail.com>
	<20101130052204.GB15564@cmpxchg.org>
Date: Tue, 30 Nov 2010 15:18:41 +0900
Message-ID: <AANLkTikUq60GmqaUNSB8ipxG-+ezu8PYrdokAuAWQs1s@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Hannes,

On Tue, Nov 30, 2010 at 2:22 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Nov 30, 2010 at 12:23:19AM +0900, Minchan Kim wrote:
>> Recently, there are reported problem about thrashing.
>> (http://marc.info/?l=3Drsync&m=3D128885034930933&w=3D2)
>> It happens by backup workloads(ex, nightly rsync).
>> That's because the workload makes just use-once pages
>> and touches pages twice. It promotes the page into
>> active list so that it results in working set page eviction.
>>
>> Some app developer want to support POSIX_FADV_NOREUSE.
>> But other OSes don't support it, either.
>> (http://marc.info/?l=3Dlinux-mm&m=3D128928979512086&w=3D2)
>>
>> By other approach, app developers use POSIX_FADV_DONTNEED.
>> But it has a problem. If kernel meets page is writing
>> during invalidate_mapping_pages, it can't work.
>> It is very hard for application programmer to use it.
>> Because they always have to sync data before calling
>> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
>> be discardable. At last, they can't use deferred write of kernel
>> so that they could see performance loss.
>> (http://insights.oetiker.ch/linux/fadvise.html)
>>
>> In fact, invalidation is very big hint to reclaimer.
>> It means we don't use the page any more. So let's move
>> the writing page into inactive list's head.
>>
>> Why I need the page to head, Dirty/Writeback page would be flushed
>> sooner or later. It can prevent writeout of pageout which is less
>> effective than flusher's writeout.
>>
>> Originally, I reused lru_demote of Peter with some change so added
>> his Signed-off-by.
>>
>> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>>
>> Adnrew. Before applying this series, please drop below two patches.
>> =A0mm-deactivate-invalidated-pages.patch
>> =A0mm-deactivate-invalidated-pages-fix.patch
>>
>> Changelog since v2:
>> =A0- mapped page leaves alone - suggested by Mel
>> =A0- pass part related PG_reclaim in next patch.
>>
>> Changelog since v1:
>> =A0- modify description
>> =A0- correct typo
>> =A0- add some comment
>> ---
>> =A0include/linux/swap.h | =A0 =A01 +
>> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 80 +++++++++++++++++++++++++++=
+++++++++++++++++++++++
>> =A0mm/truncate.c =A0 =A0 =A0 =A0| =A0 16 +++++++--
>> =A03 files changed, 93 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index eba53e7..84375e4 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>
> [...]
>
>> @@ -267,6 +270,63 @@ void add_page_to_unevictable_list(struct page *page=
)
>> =A0}
>>
>> =A0/*
>> + * This function is used by invalidate_mapping_pages.
>> + * If the page can't be invalidated, this function moves the page
>> + * into inative list's head. Because the VM expects the page would
>> + * be writeout by flusher. The flusher's writeout is much effective
>> + * than reclaimer's random writeout.
>
> The wording is a bit confusing, I find. =A0It sounds a bit like the
> flusher's chance is increased by moving it to the inactive list in the
> first place, but the key is that it is moved to the head instead of,
> what one would expect, the tail of the list. =A0How about:
>
> =A0 =A0 =A0 =A0If the page can not be invalidated, it is moved to the
> =A0 =A0 =A0 =A0inactive list to speed up its reclaim. =A0It is moved to t=
he
> =A0 =A0 =A0 =A0head of the list, rather than the tail, to give the flushe=
r
> =A0 =A0 =A0 =A0threads some time to write it out, as this is much more
> =A0 =A0 =A0 =A0effective than the single-page writeout from reclaim.
>

Looks good to me.
I will add your comment instead of my ugly comment.

>> +static void __lru_deactivate(struct page *page, struct zone *zone)
>
> Do you insist on the underscores? :)

Good point.

__lru_deactivate is self-contained.
It is valuable enough using other places.
I will remove underscores.

>
>> +{
>> + =A0 =A0 int lru, file;
>> + =A0 =A0 unsigned long vm_flags;
>> +
>> + =A0 =A0 if (!PageLRU(page) || !PageActive(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 /* Some processes are using the page */
>> + =A0 =A0 if (page_mapped(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 file =3D page_is_file_cache(page);
>> + =A0 =A0 lru =3D page_lru_base_type(page);
>> + =A0 =A0 del_page_from_lru_list(zone, page, lru + LRU_ACTIVE);
>> + =A0 =A0 ClearPageActive(page);
>> + =A0 =A0 ClearPageReferenced(page);
>> + =A0 =A0 add_page_to_lru_list(zone, page, lru);
>> + =A0 =A0 __count_vm_event(PGDEACTIVATE);
>> +
>> + =A0 =A0 update_page_reclaim_stat(zone, page, file, 0);
>> +}
>> +
>> +/*
>> + * This function must be called with preemption disable.
>
> Why is that? =A0Unless I missed something, the only thing that needs
> protection is the per-cpu pagevec reference the only user of this
> function passes in. =A0But this should be the caller's concern and is
> not really a requirement of this function per-se, is it?

Yes. It's unnecessary.
I didn't consider enoughly.
Will fix.

>
>> +static void __pagevec_lru_deactivate(struct pagevec *pvec)
>
> More underscores!

Will fix.

>
>> +{
>> + =A0 =A0 int i;
>> + =A0 =A0 struct zone *zone =3D NULL;
>> +
>> + =A0 =A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D pvec->pages[i];
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *pagezone =3D page_zone(page);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pagezone !=3D zone) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_ir=
q(&zone->lru_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone =3D pagezone;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_lock)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 __lru_deactivate(page, zone);
>> + =A0 =A0 }
>> + =A0 =A0 if (zone)
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&zone->lru_lock);
>> +
>> + =A0 =A0 release_pages(pvec->pages, pvec->nr, pvec->cold);
>> + =A0 =A0 pagevec_reinit(pvec);
>> +}
>> +
>> +/*
>> =A0 * Drain pages out of the cpu's pagevecs.
>> =A0 * Either "cpu" is the current CPU, and preemption has already been
>> =A0 * disabled; or "cpu" is being hot-unplugged, and is already dead.
>> @@ -292,6 +352,26 @@ static void drain_cpu_pagevecs(int cpu)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pagevec_move_tail(pvec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);
>> =A0 =A0 =A0 }
>> +
>> + =A0 =A0 pvec =3D &per_cpu(lru_deactivate_pvecs, cpu);
>> + =A0 =A0 if (pagevec_count(pvec))
>> + =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactivate(pvec);
>> +}
>> +
>> +/*
>> + * Forcefully deactivate a page.
>> + * This function is used for reclaiming the page ASAP when the page
>> + * can't be invalidated by Dirty/Writeback.
>
> How about:
>
> /**
> =A0* lru_deactivate_page - forcefully deactivate a page
> =A0* @page: page to deactivate
> =A0*
> =A0* This function hints the VM that @page is a good reclaim candidate,
> =A0* for example if its invalidation fails due to the page being dirty
> =A0* or under writeback.
> =A0*/
>
>> +void lru_deactivate_page(struct page *page)
>
> I would love that lru_ prefix for most of the API in this file. =A0In
> fact, the file should probably be called lru.c. =A0But for now, can you
> keep the naming consistent and call it deactivate_page?

No matter. I can change it. but deactivate_page will be asymmetric
about that deactivate_page move active page into inactive
forcefully(two step) while activate_page does one step activation.
That's why I name it.

>
>> + =A0 =A0 if (likely(get_page_unless_zero(page))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pagevec *pvec =3D &get_cpu_var(lru_deac=
tivate_pvecs);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!pagevec_add(pvec, page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactivate(pvec)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_var(lru_deactivate_pvecs);
>> + =A0 =A0 }
>> =A0}
>>
>> =A0void lru_add_drain(void)
>
> [...]
>
>> @@ -359,8 +360,15 @@ unsigned long invalidate_mapping_pages(struct addre=
ss_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lock_failed)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D invalidate_inode_page=
(page);
>> -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D invalidate_inode_page(=
page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page was dirty or =
under writeback we cannot
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalidate it now. =A0Mov=
e it to the head of the
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* inactive LRU for using de=
ferred writeback of flusher.
>
> This would also be less confusing if it would say
>
> =A0 =A0 =A0 =A0Move it to the head of the inactive LRU (rather than the t=
ail)
> =A0 =A0 =A0 =A0for using [...]
>
> But I am not sure that this detail is interesting at this point. =A0It
> would be more interesting to name the reasons for why the page is
> moved to the inactive list in the first place:
>
> =A0 =A0 =A0 =A0If the page is dirty or under writeback, we can not invali=
date
> =A0 =A0 =A0 =A0it now. =A0But we assume that attempted invalidation is a =
hint
> =A0 =A0 =A0 =A0that the page is no longer of interest and try to speed up=
 its
> =A0 =A0 =A0 =A0reclaim.
>

Will fix.
I hope listen you guys's opinions about [2/3], too. :)

Thanks, Hannes.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_deactivate=
_page(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D ret;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next > end)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> =A0 =A0 =A0 =A0Hannes
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
