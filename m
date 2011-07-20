Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A27D06B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 02:30:06 -0400 (EDT)
Received: by qyk32 with SMTP id 32so3066744qyk.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 23:30:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311142253.15392.361.camel@sli10-conroe>
References: <1311130413.15392.326.camel@sli10-conroe>
	<CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
	<1311142253.15392.361.camel@sli10-conroe>
Date: Wed, 20 Jul 2011 15:30:05 +0900
Message-ID: <CAEwNFnD3iCMBpZK95Ks+Z7DYbrzbZbSTLf3t6WXDQdeHrE6bLQ@mail.gmail.com>
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, Andrew Morton <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, Jul 20, 2011 at 3:10 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Wed, 2011-07-20 at 13:53 +0800, Minchan Kim wrote:
>> On Wed, Jul 20, 2011 at 11:53 AM, Shaohua Li <shaohua.li@intel.com> wrot=
e:
>> > per-task block plug can reduce block queue lock contention and increas=
e request
>> > merge. Currently page reclaim doesn't support it. I originally thought=
 page
>> > reclaim doesn't need it, because kswapd thread count is limited and fi=
le cache
>> > write is done at flusher mostly.
>> > When I test a workload with heavy swap in a 4-node machine, each CPU i=
s doing
>> > direct page reclaim and swap. This causes block queue lock contention.=
 In my
>> > test, without below patch, the CPU utilization is about 2% ~ 7%. With =
the
>> > patch, the CPU utilization is about 1% ~ 3%. Disk throughput isn't cha=
nged.
>>
>> Why doesn't it enhance through?
> throughput? The disk isn't that fast. We already can make it run in full

Yes. Sorry for the typo.

> speed, CPU isn't bottleneck here.

But you try to optimize CPU. so your experiment is not good.

>
>> It means merge is rare?
> Merge is still there even without my patch, but maybe not be able to
> make the request size biggest in cocurrent I/O.
>
>> > This should improve normal kswapd write and file cache write too (incr=
ease
>> > request merge for example), but might not be so obvious as I explain a=
bove.
>>
>> CPU utilization enhance on =C2=A04-node machine with heavy swap?
>> I think it isn't common situation.
>>
>> And I don't want to add new stack usage if it doesn't have a benefit.
>> As you know, direct reclaim path has a stack overflow.
>> These days, Mel, Dave and Christoph try to remove write path in
>> reclaim for solving stack usage and enhance write performance.
> it will use a little stack, yes. When I said the benefit isn't so
> obvious, it doesn't mean it has no benefit. For example, if kswapd and
> other threads write the same disk, this can still reduce lock contention
> and increase request merge. Part reason I didn't see obvious affect for
> file cache is my disk is slow.

If it begin swapping, I think the the performance would be less important,
But your patch is so simple that it would be mergable(Maybe Andrew
would merge regardless of my comment) but impact is a little in your
experiment.

I suggest you test it with fast disk like SSD and show the benefit to
us certainly. (I think you intel guy have a good SSD, apparently :D )

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
