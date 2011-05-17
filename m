Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0194D6B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 02:26:21 -0400 (EDT)
Received: by qyk2 with SMTP id 2so2284818qyk.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 23:26:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110517055204.GB24069@localhost>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTinv=_38E3Eyu88Ra4-x5vPEq7CDkw@mail.gmail.com>
	<20110517055204.GB24069@localhost>
Date: Tue, 17 May 2011 15:26:17 +0900
Message-ID: <BANLkTikX1He9usRMMeV_ePvKROkw8D=M7A@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@mit.edu>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 17, 2011 at 2:52 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Mon, May 16, 2011 at 07:40:42AM +0900, Minchan Kim wrote:
>> On Mon, May 16, 2011 at 12:27 AM, Wu Fengguang <fengguang.wu@intel.com> =
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
>>
>> I don't mean we have to disable RA.
>> As I said, the point is that we can use __GFP_NORETRY alloc fail as
>> _sign_ of memory pressure.
>
> I see.
>
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
>>
>> If it is, RA thrashing could be better sign than failure of __GFP_NORETR=
Y.
>> If we can do it easily, I don't object it. :)
>
> Yeah, the RA thrashing is much better sign because it not only happens
> long before normal __GFP_NORETRY failures, but also offers hint on how
> tight memory pressure it is. We can then shrink the readahead window
> adaptively to the available page cache memory :)
>
>> >
>> > - shrink readahead window on readahead thrashing
>> > =C2=A0(current readahead heuristic can somehow do this, and I have pat=
ches
>> > =C2=A0to further improve it)
>>
>> Good to hear. :)
>> I don't want RA steals high order page in memory pressure.
>
> More often than not it won't be RA's fault :) =C2=A0When you see RA page
> allocations stealing high order pages, it may actually be reflecting
> some more general order-0 steal order-N problem..

Agree.
As I said to Andy, it's a general problem but RA has a possibility to
reduce it while others don't have a any solution. :(

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
