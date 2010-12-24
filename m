Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6ED366B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 19:52:45 -0500 (EST)
Received: by iyj17 with SMTP id 17so5799766iyj.14
        for <linux-mm@kvack.org>; Thu, 23 Dec 2010 16:52:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101223083354.GB16046@balbir.in.ibm.com>
References: <20101210142745.29934.29186.stgit@localhost6.localdomain6>
	<20101210143112.29934.22944.stgit@localhost6.localdomain6>
	<AANLkTinaTUUfvK+Nc-Whck21r-OzT+0CFVnS4W_jG5aw@mail.gmail.com>
	<20101223083354.GB16046@balbir.in.ibm.com>
Date: Fri, 24 Dec 2010 09:52:43 +0900
Message-ID: <AANLkTi=CEkNQPxSGn8OB4k8+g66Ax9bj_4JYQTUAaa1B@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v2)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 5:33 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * MinChan Kim <minchan.kim@gmail.com> [2010-12-14 20:02:45]:
>
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_unmap=
ped_pages(zone))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_k=
swapd(zone, order);
>>
>> I think we can put the logic into zone_watermark_okay.
>>
>
> I did some checks and zone_watermark_ok is used in several places for
> a generic check like this -- for example prior to zone_reclaim(), if
> in get_page_from_freelist() we skip zones based on the return value.
> The compaction code uses it as well, the impact would be deeper. The
> compaction code uses it to check whether an allocation will succeed or
> not, I don't want unmapped page control to impact that.

Agree.

>
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We do unmapped page=
 reclaim once here and once
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* below, so that we d=
on't lose out
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_unmapped_pages(p=
riority, zone, &sc);
>>
>> It can make unnecessary stir of lru pages.
>> How about this?
>> zone_watermark_ok returns ZONE_UNMAPPED_PAGE_FULL.
>> wakeup_kswapd(..., please reclaim unmapped page cache).
>> If kswapd is woke up by unmapped page full, kswapd sets up sc with unmap=
 =3D 0.
>> If the kswapd try to reclaim unmapped page, shrink_page_list doesn't
>> rotate non-unmapped pages.
>
> With may_unmap set to 0 and may_writepage set to 0, I don't think this
> should be a major problem, like I said this code is already enabled if
> zone_reclaim_mode !=3D 0 and CONFIG_NUMA is set.

True. It has been already in there.
But it is only NUMA and you are going to take out of NUMA.
That's why I have a concern.

I want to make this usefully in embedded.
Recently ChromOS try to protect mapped page so I think your series hep
the situation.
But frequent shrink unmapped pages makes stir of LRU which victim
mapped page(ie, tail of inactive file) can move into head of inactive
file. After all, LRU ordering makes confused so that NOT-LRU page can
be evicted.

>
>> > +unsigned long reclaim_unmapped_pages(int priority, struct zone *zone,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
>> > +{
>> > + =A0 =A0 =A0 if (unlikely(unmapped_page_control) &&
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (zone_unmapped_file_pages(zone) > zone->=
min_unmapped_pages)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control nsc;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_pages;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc =3D *sc;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.swappiness =3D 0;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.may_writepage =3D 0;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.may_unmap =3D 0;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nsc.nr_reclaimed =3D 0;
>>
>> This logic can be put in zone_reclaim_unmapped_pages.
>>
>
> Now that I refactored the code and called it zone_reclaim_pages, I
> expect the correct sc to be passed to it. This code is reused between
> zone_reclaim() and reclaim_unmapped_pages(). In the former,
> zone_reclaim does the setup.

Thanks.

>
>> If we want really this, how about the new cache lru idea as Kame suggest=
s?
>> For example, add_to_page_cache_lru adds the page into cache lru.
>> page_add_file_rmap moves the page into inactive file.
>> page_remove_rmap moves the page into lru cache, again.
>> We can count the unmapped pages and if the size exceeds limit, we can
>> wake up kswapd.
>> whenever the memory pressure happens, first of all, reclaimer try to
>> reclaim cache lru.
>
> We already have a file LRU and that has active/inactive lists, I don't
> think a special mapped/unmapped list makes sense at this point.

That's for reclaim latency for embedded use case but I think it would
have benefit in desktop, too.
But it can be another patch series so I don't insist on.

Thanks, Balbir.


>
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
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
