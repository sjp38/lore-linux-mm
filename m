Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 869496B006E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 11:30:26 -0500 (EST)
Received: by iaek3 with SMTP id k3so755422iae.14
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 08:30:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111110161331.GG3083@suse.de>
References: <20111110100616.GD3083@suse.de>
	<20111110142202.GE3083@suse.de>
	<CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
	<20111110161331.GG3083@suse.de>
Date: Fri, 11 Nov 2011 01:30:24 +0900
Message-ID: <CAEwNFnCjZ9u-XsoJckQoz9WAs3O2_rRLJXjsDDFE_n+zMSf+Lw@mail.gmail.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP allocations
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 1:13 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Fri, Nov 11, 2011 at 12:12:01AM +0900, Minchan Kim wrote:
>> Hi Mel,
>>
>> You should have Cced with me because __GFP_NORETRY is issued by me.
>>
>
> I don't understand. __GFP_NORETRY has been around a long time ago
> and has loads of users. Do you have particular concerns about the
> behaviour of __GFP_NORETRY?

It seems that I got misunderstood your point.
I thought you mentioned this.

http://www.spinics.net/lists/linux-mm/msg16371.html


>
>> On Thu, Nov 10, 2011 at 11:22 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > On Thu, Nov 10, 2011 at 10:06:16AM +0000, Mel Gorman wrote:
>> >> than stall. It was suggested that __GFP_NORETRY be used instead of
>> >> __GFP_NO_KSWAPD. This would look less like a special case but would
>> >> still cause compaction to run at least once with sync compaction.
>> >>
>> >
>> > This comment is bogus - __GFP_NORETRY would have caught THP allocation=
s
>> > and would not call sync compaction. The issue was that it would also
>> > have caught any hypothetical high-order GFP_THISNODE allocations that
>> > end up calling compaction here
>>
>> In fact, the I support patch concept so I would like to give
>>
>> Acked-by: Minchan Kim <minchan.kim@gmail.com>
>> But it is still doubt about code.
>>
>> __GFP_NORETRY: The VM implementation must not retry indefinitely
>>
>> What could people think if they look at above comment?
>> At least, I can imagine two
>>
>> First, it is related on *latency*.
>
> I never read it to mean that. I always read it to mean "it must
> not retry indefinitely". I expected it was still fine to try direct
> reclaim which is not a latency-sensitive operation.
>
>> Second, "I can handle if VM fails allocation"
>>
>
> Fully agreed.
>
>> I am biased toward latter.
>> Then, __GFP_NO_KSWAPD is okay? It means "let's avoid sync compaction
>> or long latency"?
>
> and do not wake kswapd to swap additional pages.
>
>> It's rather awkward name. Already someone started to use
>> __GFP_NO_KSWAPD as such purpose.
>> See mtd_kmalloc_up_to. He mentioned in comment of function as follows,
>>
>> =C2=A0* the system page size. This attempts to make sure it does not adv=
ersely
>> =C2=A0* impact system performance, so when allocating more than one page=
, we
>> =C2=A0* ask the memory allocator to avoid re-trying, swapping, writing b=
ack
>> =C2=A0* or performing I/O.
>>
>
> I was not aware of this user although their reason for using it
> seems fine. We are not breaking their expectations with this patch but
> it is a slippery slope.
>
>> That thing was what I concerned.
>> In future, new users of __GFP_NO_KSWAPD is coming and we can't prevent
>> them under our sight.
>> So I hope we can change the flag name or fix above code and comment
>> out __GFP_NO_KSWAPD
>>
>
> I can't think of a better name but we can at least improve the comment.
>
>> /*
>> =C2=A0* __GFP_NO_KSWAPD is very VM internal flag so Please don't use it
>> without allowing mm guys
>> =C2=A0*
>> #define __GFP_NO_KSWAPD xxxx
>>
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * High-order a=
llocations do not necessarily loop after
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * direct recla=
im and reclaim/compaction depends on
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * compaction b=
eing called after reclaim so call directly if
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * necessary
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D __allo=
c_pages_direct_compact(gfp_mask, order,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zoneli=
st, high_zoneidx,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodema=
sk,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0alloc_=
flags, preferred_zone,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0migrat=
etype, &did_some_progress,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_m=
igration);
>> >
>> > __GFP_NORETRY is used in a bunch of places and while the most
>> > of them are not high-order, some of them potentially are like in
>> > sound/core/memalloc.c. Using __GFP_NO_KSWAPD as the flag allows
>> > these callers to continue using sync compaction. =C2=A0It could be arg=
ued
>>
>> Okay. If I was biased first, I have opposed this comment because they
>> might think __GFP_NORETRY is very latency sensitive.
>
> As __GFP_NORETRY uses direct reclaim, I do not think users expect it
> to be latency sensitive. If they were latency sensitive, they would
> mask out __GFP_WAIT.

Indeed.

>
>> So they wanted allocation is very fast without any writeback/retrial.
>> In view point, __GFP_NORETRY isn't bad, I think.
>>
>> Having said that, I was biased latter, as I said earlier.
>>
>> > that they would prefer __GFP_NORETRY but the potential side-effects
>> > should be taken should be taken into account and the comment updated
>>
>> Considering side-effect, your patch is okay.
>> But I can't understand you mentioned "the comment updated if that
>> happens" sentence. :(
>>
>
> I meant the comment above sync_migration =3D !(gfp_mask & __GFP_NO_KSWAPD=
) should
> be updated if it changes to __GFP_NORETRY.
>
> I updated the commentary a bit. Does this help?

I am happy with your updated comment but there is a concern.
We are adding additional flags to be considered for all page allocation cal=
lers.
If it isn't, there are too many flags in there.

I really hope this flag makes VM internal so let other do not care about it=
.
Until now, users was happy without such flag and it's only huge page proble=
m.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
