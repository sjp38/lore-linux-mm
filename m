Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 723736B0012
	for <linux-mm@kvack.org>; Sat, 14 May 2011 21:38:03 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2607963qwa.14
        for <linux-mm@kvack.org>; Sat, 14 May 2011 18:38:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110514174333.GW6008@one.firstfloor.org>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com>
	<m2fwokj0oz.fsf@firstfloor.org>
	<BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
Date: Sun, 15 May 2011 10:37:58 +0900
Message-ID: <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

On Sun, May 15, 2011 at 2:43 AM, Andi Kleen <andi@firstfloor.org> wrote:
> Copying back linux-mm.
>
>> Recently, we added following patch.
>> https://lkml.org/lkml/2011/4/26/129
>> If it's a culprit, the patch should solve the problem.
>
> It would be probably better to not do the allocations at all under
> memory pressure. =C2=A0Even if the RA allocation doesn't go into reclaim

Fair enough.
I think we can do it easily now.
If page_cache_alloc_readahead(ie, GFP_NORETRY) is fail, we can adjust
RA window size or turn off a while. The point is that we can use the
fail of __do_page_cache_readahead as sign of memory pressure.
Wu, What do you think?

> it may still "steal" allocations recently freed and needed by other
> actors.

This problem is general thing as well as RA.
But it would be not a big problem in order-0 pages.
If it's a really problem, it might sign we have to increase SWAP_CLUSTER_MA=
X.

The concern I thought is order-0 allocation happens with other
higher-order reclaims in parallel.
order-0 allocation can steal other's high order pages.
For it, I sent a patch but I didn't have enough time to dig in.
https://lkml.org/lkml/2011/5/2/93
I have a plan to do.

>
> -Andi
> --
> ak@linux.intel.com -- Speaking for myself only.
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
