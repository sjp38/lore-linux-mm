Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EE3A86B024D
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 00:12:00 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2957907iwn.14
        for <linux-mm@kvack.org>; Sun, 25 Jul 2010 21:11:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100726032755.GB7668@localhost>
References: <20100723094515.GD5043@localhost>
	<20100723105719.GE5300@csn.ul.ie>
	<20100725192955.40D5.A69D9226@jp.fujitsu.com>
	<20100725120345.GA1817@barrios-desktop>
	<20100726032755.GB7668@localhost>
Date: Mon, 26 Jul 2010 13:11:59 +0900
Message-ID: <AANLkTinL-K-Ky1NFWQPvH5XASj9MnZJicFtqDYhdje6R@mail.gmail.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
	writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 12:27 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Sun, Jul 25, 2010 at 08:03:45PM +0800, Minchan Kim wrote:
>> On Sun, Jul 25, 2010 at 07:43:20PM +0900, KOSAKI Motohiro wrote:
>> > Hi
>> >
>> > sorry for the delay.
>> >
>> > > Will you be picking it up or should I? The changelog should be more =
or less
>> > > the same as yours and consider it
>> > >
>> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > >
>> > > It'd be nice if the original tester is still knocking around and wil=
ling
>> > > to confirm the patch resolves his/her problem. I am running this pat=
ch on
>> > > my desktop at the moment and it does feel a little smoother but it m=
ight be
>> > > my imagination. I had trouble with odd stalls that I never pinned do=
wn and
>> > > was attributing to the machine being commonly heavily loaded but I h=
aven't
>> > > noticed them today.
>> > >
>> > > It also needs an Acked-by or Reviewed-by from Kosaki Motohiro as it =
alters
>> > > logic he introduced in commit [78dc583: vmscan: low order lumpy recl=
aim also
>> > > should use PAGEOUT_IO_SYNC]
>> >
>> > My reviewing doesn't found any bug. however I think original thread ha=
ve too many guess
>> > and we need to know reproduce way and confirm it.
>> >
>> > At least, we need three confirms.
>> > =A0o original issue is still there?
>> > =A0o DEF_PRIORITY/3 is best value?
>>
>> I agree. Wu, how do you determine DEF_PRIORITY/3 of LRU?
>> I guess system has 512M and 22M writeback pages.
>> So you may determine it for skipping max 32M writeback pages.
>> Is right?
>
> For 512M mem, DEF_PRIORITY/3 means 32M dirty _or_ writeback pages.
> Because shrink_inactive_list() first calls
> shrink_page_list(PAGEOUT_IO_ASYNC) then optionally
> shrink_page_list(PAGEOUT_IO_SYNC), so dirty pages will first be
> converted to writeback pages and then optionally be waited on.
>
> The dirty/writeback pages may go up to 512M*20% =3D 100M. So 32M looks
> a reasonable value.

Why do you think it's a reasonable value?
I mean why isn't it good 12.5% or 3.125%? Why do you select 6.25%?
I am not against you. Just out of curiosity and requires more explanation.
It might be thing _only I_ don't know. :(

>
>> And I have a question of your below comment.
>>
>> "As the default dirty throttle ratio is 20%, sync write&wait
>> will hardly be triggered by pure dirty pages"
>>
>> I am not sure exactly what you mean but at least DEF_PRIOIRTY/3 seems to=
 be
>> related to dirty_ratio. It always can be changed by admin.
>> Then do we have to determine magic value(DEF_PRIORITY/3) =A0proportional=
 to dirty_ratio?
>
> Yes DEF_PRIORITY/3 is already proportional to the _default_
> dirty_ratio. We could do explicit comparison with dirty_ratio
> just in case dirty_ratio get changed by user. It's mainly a question
> of whether deserving to add such overheads and complexity. I'd prefer
> to keep the current simple form :)

What I suggest is that couldn't we use recent_writeback/recent_scanned rati=
o?
I think scan_control's new filed and counting wouldn't be a big
overhead and complexity.
I am not sure which ratio is best. but at least, it would make the
logic scalable and sense to me. :)

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
