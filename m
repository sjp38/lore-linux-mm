Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ABA616B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:16:32 -0400 (EDT)
Received: by iwn34 with SMTP id 34so182073iwn.12
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 08:16:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091027145435.GG8900@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091019161815.GA11487@think>
	 <20091020104839.GC11778@csn.ul.ie>
	 <200910262206.13146.elendil@planet.nl>
	 <20091027145435.GG8900@csn.ul.ie>
Date: Wed, 28 Oct 2009 00:16:30 +0900
Message-ID: <2f11576a0910270816s3e1b268ah91b5f2d0cc0d562e@mail.gmail.com>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Chris Mason <chris.mason@oracle.com>, David Rientjes <rientjes@google.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/10/27 Mel Gorman <mel@csn.ul.ie>:
> On Mon, Oct 26, 2009 at 10:06:09PM +0100, Frans Pop wrote:
>> On Tuesday 20 October 2009, Mel Gorman wrote:
>> > I've attached a patch below that should allow us to cheat. When it's
>> > applied, it outputs who called congestion_wait(), how long the timeout
>> > was and how long it waited for. By comparing before and after sleep
>> > times, we should be able to see which of the callers has significantly
>> > changed and if it's something easily addressable.
>>
>> The results from this look fairly interesting (although I may be a bad
>> judge as I don't really know what I'm looking at ;-).
>>
>> I've tested with two kernels:
>> 1) 2.6.31.1: 1 test run
>> 2) 2.6.31.1 + congestion_wait() reverts: 2 test runs
>>
>> The 1st kernel had the expected "freeze" while reading commits in gitk;
>> reading commits with the 2nd kernel was more fluent.
>> I did 2 runs with the 2nd kernel as the first run had a fairly long musi=
c
>> skip and more SKB errors than expected. The second run was fairly normal
>> with no music skips at all even though it had a few SKB errors.
>>
>> Data for the tests:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1st kernel =
=A0 =A0 =A02nd kernel 1 =A0 =A02nd kernel 2
>> end reading commits =A0 =A0 =A0 =A0 =A0 1:15 =A0 =A0 =A0 =A0 =A0 =A01:00=
 =A0 =A0 =A0 =A0 =A0 =A00:55
>> =A0 "freeze" =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0yes =A0 =A0 =A0 =A0 =
=A0 =A0 no =A0 =A0 =A0 =A0 =A0 =A0 =A0no
>> branch data shown =A0 =A0 =A0 =A0 =A0 =A0 1:55 =A0 =A0 =A0 =A0 =A0 =A01:=
15 =A0 =A0 =A0 =A0 =A0 =A01:10
>> system quiet =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02:25 =A0 =A0 =A0 =A0 =A0=
 =A01:50 =A0 =A0 =A0 =A0 =A0 =A01:45
>> # SKB allocation errors =A0 =A0 =A0 =A0 =A0 =A0 =A0 10 =A0 =A0 =A0 =A0 =
=A0 =A0 =A053 =A0 =A0 =A0 =A0 =A0 =A0 =A05
>>
>> Note that the test is substantially faster with the 2nd kernel and that =
the
>> SKB errors don't really affect the duration of the test.
>>
>
> Ok. I think that despite expectations, the writeback changes have
> changed the timing significantly enough to be worth examining closer.
>
>>
>> - without the revert 'background_writeout' is called a lot less frequent=
ly,
>> =A0 but when it's called it gets long delays
>> - without the revert you have 'wb_kupdate', which is relatively expensiv=
e
>> - with the revert 'shrink_list' is relatively expensive, although not
>> =A0 really in absolute terms
>>
>
> Lets look at the callers that waited in congestion_wait() for at least
> 25 jiffies.
>
> 2.6.31.1-async-sync-congestion-wait i.e. vanilla kernel
> generated with: cat kern.log_1_test | awk -F ] '{print $2}' | sort -k 5 -=
n | uniq -c
> =A0 =A0 24 =A0background_writeout =A0congestion_wait sync=3D0 delay 25 ti=
meout 25
> =A0 =A0203 =A0kswapd =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0=
 delay 25 timeout 25
> =A0 =A0 =A05 =A0shrink_list =A0 =A0 =A0 =A0 =A0congestion_wait sync=3D0 d=
elay 25 timeout 25
> =A0 =A0155 =A0try_to_free_pages =A0 =A0congestion_wait sync=3D0 delay 25 =
timeout 25
> =A0 =A0145 =A0wb_kupdate =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0 del=
ay 25 timeout 25
> =A0 =A0 =A02 =A0kswapd =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait sync=
=3D0 delay 26 timeout 25
> =A0 =A0 =A08 =A0wb_kupdate =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0 d=
elay 26 timeout 25
> =A0 =A0 =A01 =A0try_to_free_pages =A0 =A0congestion_wait sync=3D0 delay 5=
4 timeout 25
>
> 2.6.31.1-write-congestion-wait i.e. kernel with patch reverted
> generated with: cat kern.log_2.1_test | awk -F ] '{print $2}' | sort -k 5=
 -n | uniq -c
> =A0 =A0 =A02 =A0background_writeout =A0congestion_wait rw=3D1 delay 25 ti=
meout 25
> =A0 =A0188 =A0kswapd =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait rw=3D1 d=
elay 25 timeout 25
> =A0 =A0 14 =A0shrink_list =A0 =A0 =A0 =A0 =A0congestion_wait rw=3D1 delay=
 25 timeout 25
> =A0 =A0181 =A0try_to_free_pages =A0 =A0congestion_wait rw=3D1 delay 25 ti=
meout 25
> =A0 =A0 =A05 =A0kswapd =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait rw=3D1=
 delay 26 timeout 25
> =A0 =A0 10 =A0try_to_free_pages =A0 =A0congestion_wait rw=3D1 delay 26 ti=
meout 25
> =A0 =A0 =A03 =A0try_to_free_pages =A0 =A0congestion_wait rw=3D1 delay 27 =
timeout 25
> =A0 =A0 =A01 =A0kswapd =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait rw=3D1=
 delay 29 timeout 25
> =A0 =A0 =A01 =A0__alloc_pages_nodemask congestion_wait rw=3D1 delay 30 ti=
meout 5
> =A0 =A0 =A01 =A0try_to_free_pages =A0 =A0congestion_wait rw=3D1 delay 31 =
timeout 25
> =A0 =A0 =A01 =A0try_to_free_pages =A0 =A0congestion_wait rw=3D1 delay 35 =
timeout 25
> =A0 =A0 =A01 =A0kswapd =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait rw=3D1=
 delay 51 timeout 25
> =A0 =A0 =A01 =A0try_to_free_pages =A0 =A0congestion_wait rw=3D1 delay 56 =
timeout 25
>
> So, wb_kupdate and background_writeout are the big movers in terms of wai=
ting,
> not the direct reclaimers which is what we were expecting. Of those big
> movers, wb_kupdate is the most interested because compare the following
>
> $ cat kern.log_2.1_test | awk -F ] '{print $2}' | sort -k 5 -n | uniq -c =
| grep wb_kup
> [ no output ]
> $ $ cat kern.log_1_test | awk -F ] '{print $2}' | sort -k 5 -n | uniq -c =
| grep wb_kup
> =A0 =A0 =A01 =A0wb_kupdate =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0 d=
elay 15 timeout 25
> =A0 =A0 =A01 =A0wb_kupdate =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0 d=
elay 23 timeout 25
> =A0 =A0145 =A0wb_kupdate =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0 del=
ay 25 timeout 25
> =A0 =A0 =A08 =A0wb_kupdate =A0 =A0 =A0 =A0 =A0 congestion_wait sync=3D0 d=
elay 26 timeout 25
>
> The vanilla kernel is not waiting in wb_kupdate at all.
>
> Jens, before the congestion_wait() changes, wb_kupdate was waiting on
> congestion and afterwards it's not. Furthermore, look at the number of pa=
ges
> that are queued for writeback in the two page allocation failure reports.
>
> without-revert: writeback:65653
> with-revert: =A0 =A0writeback:21713
>
> So, after the move to async/sync, a lot more pages are getting queued
> for writeback - more than three times the number of pages are queued for
> writeback with the vanilla kernel. This amount of congestion might be why
> direct reclaimers and kswapd's timings have changed so much.
>
> Chris Mason hinted at this but I didn't quite "get it" at the time but is=
 it
> possible that writeback_inodes() is converting what is expected to be asy=
nc
> IO into sync IO? One way of checking this is if Frans could test the patc=
h
> below that makes wb_kupdate wait on sync instead of async.
>
> If this makes a difference, I think the three main areas of trouble we
> are now seeing are
>
> =A0 =A0 =A0 =A01. page allocator regressions - mostly fixed hopefully
> =A0 =A0 =A0 =A02. page writeback change in timing - theory yet to be conf=
irmed
> =A0 =A0 =A0 =A03. drivers using more atomics - iwlagn specific, being dea=
lt with
>
> Of course, the big problem is if the changes are due to major timing
> differences in page writeback, then mainline is a totally different
> shape of problem as pdflush has been replaced there.
>
> =3D=3D=3D=3D
> Have wb_kupdate wait on sync IO congestion instead of async
>
> wb_kupdate is expected to only have queued up pages for async IO.
> However, something screwy is happening because it never appears to go to
> sleep. Frans, can you test with this patch instead of the revert please?
> Preferably, keep the verbose-congestion_wait patch applied so we can
> still get an idea who is going to sleep and for how long when calling
> congestion_wait. thanks
>
> Not-signed-off-hacket-job: Mel Gorman <mel@csn.ul.ie>
> ---
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 81627eb..cb646dd 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -787,7 +787,7 @@ static void wb_kupdate(unsigned long arg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0writeback_inodes(&wbc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (wbc.nr_to_write > 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (wbc.encountered_conges=
tion || wbc.more_io)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_=
wait(BLK_RW_ASYNC, HZ/10);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_=
wait(BLK_RW_SYNC, HZ/10);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break; =A0=
/* All the old data is written */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}

Hmm, This doesn't looks correct to me.

BLK_RW_ASYNC mean async write.
BLK_RW_SYNC  mean read and sync-write.

wb_kupdate use WB_SYNC_NONE. it's async write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
