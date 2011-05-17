Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AA3A36B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 02:35:52 -0400 (EDT)
Received: by qwa26 with SMTP id 26so115565qwa.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 23:35:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110517060001.GC24069@localhost>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
Date: Tue, 17 May 2011 15:35:50 +0900
Message-ID: <BANLkTin9hDuY1qyyz3p=M_r5RpHupu7Y2w@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Lutomirski <luto@mit.edu>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 17, 2011 at 3:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Sun, May 15, 2011 at 12:12:36PM -0400, Andrew Lutomirski wrote:
>> On Sun, May 15, 2011 at 11:27 AM, Wu Fengguang <fengguang.wu@intel.com> =
wrote:
>> > On Sun, May 15, 2011 at 09:37:58AM +0800, Minchan Kim wrote:
>> >> On Sun, May 15, 2011 at 2:43 AM, Andi Kleen <andi@firstfloor.org> wro=
te:
>> >> > Copying back linux-mm.
>> >> >
>> >> >> Recently, we added following patch.
>> >> >> https://lkml.org/lkml/2011/4/26/129
>> >> >> If it's a culprit, the patch should solve the problem.
>> >> >
>> >> > It would be probably better to not do the allocations at all under
>> >> > memory pressure. =C2=A0Even if the RA allocation doesn't go into re=
claim
>> >>
>> >> Fair enough.
>> >> I think we can do it easily now.
>> >> If page_cache_alloc_readahead(ie, GFP_NORETRY) is fail, we can adjust
>> >> RA window size or turn off a while. The point is that we can use the
>> >> fail of __do_page_cache_readahead as sign of memory pressure.
>> >> Wu, What do you think?
>> >
>> > No, disabling readahead can hardly help.
>> >
>> > The sequential readahead memory consumption can be estimated by
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 * (number of =
concurrent read streams) * (readahead window size)
>> >
>> > And you can double that when there are two level of readaheads.
>> >
>> > Since there are hardly any concurrent read streams in Andy's case,
>> > the readahead memory consumption will be ignorable.
>> >
>> > Typically readahead thrashing will happen long before excessive
>> > GFP_NORETRY failures, so the reasonable solutions are to
>> >
>> > - shrink readahead window on readahead thrashing
>> > =C2=A0(current readahead heuristic can somehow do this, and I have pat=
ches
>> > =C2=A0to further improve it)
>> >
>> > - prevent abnormal GFP_NORETRY failures
>> > =C2=A0(when there are many reclaimable pages)
>> >
>> >
>> > Andy's OOM memory dump (incorrect_oom_kill.txt.xz) shows that there ar=
e
>> >
>> > - 8MB =C2=A0 active+inactive file pages
>> > - 160MB active+inactive anon pages
>> > - 1GB =C2=A0 shmem pages
>> > - 1.4GB unevictable pages
>> >
>> > Hmm, why are there so many unevictable pages? =C2=A0How come the shmem
>> > pages become unevictable when there are plenty of swap space?
>>
>> That was probably because one of my testcases creates a 1.4GB file on
>> ramfs. =C2=A0(I can provoke the problem without doing evil things like
>> that, but the test script is rather reliable at killing my system and
>> it works fine on my other machines.)
>
> Ah I didn't read your first email.. I'm now running
>
> ./test_mempressure.sh 1500 1400 1
>
> with mem=3D2G and no swap, but cannot reproduce OOM.
>
> What's your kconfig?
>
>> If you want, I can try to generate a trace that isn't polluted with
>> the evil ramfs file.
>
> No, thanks. However it would be valuable if you can retry with this
> patch _alone_ (without the "if (need_resched()) return false;" change,
> as I don't see how it helps your case).

Yes. I was curious about that. The experiment would be very valuable.

In case of James, he met the problem again without need_resched.
https://lkml.org/lkml/2011/5/12/547.

But I am not sure what's exact meaning of 'livelock' he mentioned.
I expect he met softlockup, again.

Still I think the possibility that skip cond_resched spared in
vmscan.c is _very_ low. How come such softlockup happens?
So I am really curious about what's going on under my sight.

>
> @@ -2286,7 +2290,7 @@ static bool sleeping_prematurely(pg_data_t
> *pgdat, int order, long remaining,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0* must be balanced
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> =C2=A0 =C2=A0 =C2=A0 if (order)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return pgdat_balanced(=
pgdat, balanced, classzone_idx);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return !pgdat_balanced=
(pgdat, balanced, classzone_idx);
> =C2=A0 =C2=A0 =C2=A0 else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return !all_zones_ok;
> =C2=A0}
>
> Thanks,
> Fengguang
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
