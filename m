Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 13E9E6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 10:12:03 -0500 (EST)
Received: by iaek3 with SMTP id k3so613629iae.14
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 07:12:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111110142202.GE3083@suse.de>
References: <20111110100616.GD3083@suse.de>
	<20111110142202.GE3083@suse.de>
Date: Fri, 11 Nov 2011 00:12:01 +0900
Message-ID: <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP allocations
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Mel,

You should have Cced with me because __GFP_NORETRY is issued by me.

On Thu, Nov 10, 2011 at 11:22 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Nov 10, 2011 at 10:06:16AM +0000, Mel Gorman wrote:
>> than stall. It was suggested that __GFP_NORETRY be used instead of
>> __GFP_NO_KSWAPD. This would look less like a special case but would
>> still cause compaction to run at least once with sync compaction.
>>
>
> This comment is bogus - __GFP_NORETRY would have caught THP allocations
> and would not call sync compaction. The issue was that it would also
> have caught any hypothetical high-order GFP_THISNODE allocations that
> end up calling compaction here

In fact, the I support patch concept so I would like to give

Acked-by: Minchan Kim <minchan.kim@gmail.com>
But it is still doubt about code.

__GFP_NORETRY: The VM implementation must not retry indefinitely

What could people think if they look at above comment?
At least, I can imagine two

First, it is related on *latency*.
Second, "I can handle if VM fails allocation"

I am biased toward latter.
Then, __GFP_NO_KSWAPD is okay? It means "let's avoid sync compaction
or long latency"?
It's rather awkward name. Already someone started to use
__GFP_NO_KSWAPD as such purpose.
See mtd_kmalloc_up_to. He mentioned in comment of function as follows,

 * the system page size. This attempts to make sure it does not adversely
 * impact system performance, so when allocating more than one page, we
 * ask the memory allocator to avoid re-trying, swapping, writing back
 * or performing I/O.

That thing was what I concerned.
In future, new users of __GFP_NO_KSWAPD is coming and we can't prevent
them under our sight.
So I hope we can change the flag name or fix above code and comment
out __GFP_NO_KSWAPD

/*
 * __GFP_NO_KSWAPD is very VM internal flag so Please don't use it
without allowing mm guys
 *
#define __GFP_NO_KSWAPD xxxx

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * High-order allo=
cations do not necessarily loop after
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * direct reclaim =
and reclaim/compaction depends on
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * compaction bein=
g called after reclaim so call directly if
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * necessary
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D __alloc_p=
ages_direct_compact(gfp_mask, order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zonelist,=
 high_zoneidx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodemask,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0alloc_fla=
gs, preferred_zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0migratety=
pe, &did_some_progress,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_migr=
ation);
>
> __GFP_NORETRY is used in a bunch of places and while the most
> of them are not high-order, some of them potentially are like in
> sound/core/memalloc.c. Using __GFP_NO_KSWAPD as the flag allows
> these callers to continue using sync compaction. =C2=A0It could be argued

Okay. If I was biased first, I have opposed this comment because they
might think __GFP_NORETRY is very latency sensitive.
So they wanted allocation is very fast without any writeback/retrial.
In view point, __GFP_NORETRY isn't bad, I think.

Having said that, I was biased latter, as I said earlier.

> that they would prefer __GFP_NORETRY but the potential side-effects
> should be taken should be taken into account and the comment updated

Considering side-effect, your patch is okay.
But I can't understand you mentioned "the comment updated if that
happens" sentence. :(

> if that happens.
>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
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
