Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2A0A6B0022
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:40:44 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2834967qyk.14
        for <linux-mm@kvack.org>; Sun, 15 May 2011 15:40:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110515152747.GA25905@localhost>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com>
	<m2fwokj0oz.fsf@firstfloor.org>
	<BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
Date: Mon, 16 May 2011 07:40:42 +0900
Message-ID: <BANLkTinv=_38E3Eyu88Ra4-x5vPEq7CDkw@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@mit.edu>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 16, 2011 at 12:27 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Sun, May 15, 2011 at 09:37:58AM +0800, Minchan Kim wrote:
>> On Sun, May 15, 2011 at 2:43 AM, Andi Kleen <andi@firstfloor.org> wrote:
>> > Copying back linux-mm.
>> >
>> >> Recently, we added following patch.
>> >> https://lkml.org/lkml/2011/4/26/129
>> >> If it's a culprit, the patch should solve the problem.
>> >
>> > It would be probably better to not do the allocations at all under
>> > memory pressure. =C2=A0Even if the RA allocation doesn't go into recla=
im
>>
>> Fair enough.
>> I think we can do it easily now.
>> If page_cache_alloc_readahead(ie, GFP_NORETRY) is fail, we can adjust
>> RA window size or turn off a while. The point is that we can use the
>> fail of __do_page_cache_readahead as sign of memory pressure.
>> Wu, What do you think?
>
> No, disabling readahead can hardly help.

I don't mean we have to disable RA.
As I said, the point is that we can use __GFP_NORETRY alloc fail as
_sign_ of memory pressure.

>
> The sequential readahead memory consumption can be estimated by
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 * (number of con=
current read streams) * (readahead window size)
>
> And you can double that when there are two level of readaheads.
>
> Since there are hardly any concurrent read streams in Andy's case,
> the readahead memory consumption will be ignorable.
>
> Typically readahead thrashing will happen long before excessive
> GFP_NORETRY failures, so the reasonable solutions are to

If it is, RA thrashing could be better sign than failure of __GFP_NORETRY.
If we can do it easily, I don't object it. :)

>
> - shrink readahead window on readahead thrashing
> =C2=A0(current readahead heuristic can somehow do this, and I have patche=
s
> =C2=A0to further improve it)

Good to hear. :)
I don't want RA steals high order page in memory pressure.
My patch and shrinking RA window helps this case.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
