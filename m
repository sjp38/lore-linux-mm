Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A8EB56B014F
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 03:56:57 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so4046616lbj.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 00:56:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=oo5GrsbjTRPF2vC-g8R1XVOhjLAMQg6ik49-fr8D=Q+g@mail.gmail.com>
References: <4FE169B1.7020600@kernel.org>
	<4FE16E80.9000306@gmail.com>
	<4FE18187.3050103@kernel.org>
	<4FE23069.5030702@gmail.com>
	<4FE26470.90401@kernel.org>
	<CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com>
	<4FE27F15.8050102@kernel.org>
	<CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com>
	<4FE2A937.6040701@kernel.org>
	<4FE2FCFB.4040808@jp.fujitsu.com>
	<4FE3C4E4.2050107@kernel.org>
	<CAHGf_=oo5GrsbjTRPF2vC-g8R1XVOhjLAMQg6ik49-fr8D=Q+g@mail.gmail.com>
Date: Fri, 22 Jun 2012 13:26:54 +0530
Message-ID: <CAEtiSasQco=GPCwENUY5ND7uvsMrH0a-uTZ6o9GNwmC5dgsPkA@mail.gmail.com>
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Fri, Jun 22, 2012 at 12:52 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> Let me summary again.
>>
>> The problem:
>>
>> when hotplug offlining happens on zone A, it starts to freed page as MIG=
RATE_ISOLATE type in buddy.
>> (MIGRATE_ISOLATE is very irony type because it's apparently on buddy but=
 we can't allocate them)
>> When the memory shortage happens during hotplug offlining, current task =
starts to reclaim, then wake up kswapd.
>> Kswapd checks watermark, then go sleep BECAUSE current zone_watermark_ok=
_safe doesn't consider
>> MIGRATE_ISOLATE freed page count. Current task continue to reclaim in di=
rect reclaim path without kswapd's help.
>> The problem is that zone->all_unreclaimable is set by only kswapd so tha=
t current task would be looping forever
>> like below.
>>
>> __alloc_pages_slowpath
>> restart:
>> =A0 =A0 =A0 =A0wake_all_kswapd
>> rebalance:
>> =A0 =A0 =A0 =A0__alloc_pages_direct_reclaim
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_try_to_free_pages
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if global_reclaim && !all=
_unreclaimable
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;=
 /* It means we did did_some_progress */
>> =A0 =A0 =A0 =A0skip __alloc_pages_may_oom
>> =A0 =A0 =A0 =A0should_alloc_retry
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto rebalance;
>>
>> If we apply KOSAKI's patch[1] which doesn't depends on kswapd about sett=
ing zone->all_unreclaimable,
>> we can solve this problem by killing some task. But it doesn't wake up k=
swapd, still.
>> It could be a problem still if other subsystem needs GFP_ATOMIC request.
>> So kswapd should consider MIGRATE_ISOLATE when it calculate free pages b=
efore going sleep.
>
> I agree. And I believe we should remove rebalance label and alloc
> retrying should always wake up kswapd.
> because wake_all_kswapd is unreliable, it have no guarantee to success
> to wake up kswapd. then this
> micro optimization is NOT optimization. Just trouble source. Our
> memory reclaim logic has a lot of race
> by design. then any reclaim code shouldn't believe some one else works fi=
ne.
>

I think this is a better approach, since MIGRATE_ISLOATE is really a
temporary phenomenon, it makes sense to just retry allocation.
One issue however, with this approach is that it does not exactly work
for PAGE_ALLOC_COSTLY_ORDER, But well, given the
frequency of such allocation, I think may be it is an acceptable
compromise to handle such request by OOM in case of many
MIGRATE_ISOLATE
pages present.

what do you think ?

>
>> Firstly I tried to solve this problem by this.
>> https://lkml.org/lkml/2012/6/20/30
>> The patch's goal was to NOT increase nr_free and NR_FREE_PAGES when we f=
ree page into MIGRATE_ISOLATED.
>> But it increases little overhead in higher order free page but I think i=
t's not a big deal.
>> More problem is duplicated codes for handling only MIGRATE_ISOLATE freed=
 page.
>>
>> Second approach which is suggested by KOSAKI is what you mentioned.
>> But the concern about second approach is how to make sure matched count =
increase/decrease of nr_isolated_areas.
>> I mean how to make sure nr_isolated_areas would be zero when isolation i=
s done.
>> Of course, we can investigate all of current caller and make sure they d=
on't make mistake
>> now. But it's very error-prone if we consider future's user.
>> So we might need test_set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>>
>> IMHO, ideal solution is that we remove MIGRATE_ISOLATE type totally in b=
uddy.
>> For it, there is no problem to isolate already freed page in buddy alloc=
ator but the concern is how to handle
>> freed page later by do_migrate_range in memory_hotplug.c.
>> We can create custom putback_lru_pages
>>
>> put_page_hotplug(page)
>> {
>> =A0 =A0 =A0 =A0int migratetype =3D get_pageblock_migratetype(page)
>> =A0 =A0 =A0 =A0VM_BUG_ON(migratetype !=3D MIGRATE_ISOLATE);
>> =A0 =A0 =A0 =A0__page_cache_release(page);
>> =A0 =A0 =A0 =A0free_one_page(zone, page, 0, MIGRATE_ISOLATE);
>> }
>>
>> putback_lru_pages_hotplug(&source)
>> {
>> =A0 =A0 =A0 =A0foreach page from source
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_page_hotplug(page)
>> }
>>
>> do_migrate_range()
>> {
>> =A0 =A0 =A0 =A0migrate_pages(&source);
>> =A0 =A0 =A0 =A0putback_lru_pages_hotplug(&source);
>> }
>>
>> I hope this summary can help you, Kame and If I miss something, please l=
et me know it.
>
> I disagree this. Because of, memory hotplug intentionally don't use
> stopmachine. It is because
> we don't stop any system service when memory is being unpluged. That's
> said various subsystem
> try to allocate memory during page migration for memory unplug. IOW,
> we shouldn't do_migrate_page()
> is only one caller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
