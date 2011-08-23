Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 16C306B016F
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 06:01:17 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 23 Aug 2011 12:01:00 +0200
In-Reply-To: <20110823034042.GC7332@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com> <1312811193.10488.33.camel@twins>
	 <20110808141128.GA22080@localhost> <1312814501.10488.41.camel@twins>
	 <20110808230535.GC7176@localhost> <1313154259.6576.42.camel@twins>
	 <20110812142020.GB17781@localhost> <1314027488.24275.74.camel@twins>
	 <20110823034042.GC7332@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314093660.8002.24.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-08-23 at 11:40 +0800, Wu Fengguang wrote:
> - not a factor at all for updating balanced_rate (whether or not we do (2=
))
>   well, in this concept: the balanced_rate formula inherently does not
>   derive the balanced_rate_(i+1) from balanced_rate_i. Rather it's
>   based on the ratelimit executed for the past 200ms:
>=20
>           balanced_rate_(i+1) =3D task_ratelimit_200ms * bw_ratio

Ok, this is where it all goes funny..

So if you want completely separated feedback loops I would expect
something like:

	balance_rate_(i+1) =3D balance_rate_(i) * bw_ratio   ; every 200ms

The former is a complete feedback loop, expressing the new value in the
old value (*) with bw_ratio as feedback parameter; if we throttled too
much, the dirty_rate will have dropped and the bw_ratio will be <1
causing the balance_rate to drop increasing the dirty_rate, and vice
versa.

(*) which is the form I expected and why I thought your primary feedback
loop looked like: rate_(i+1) =3D rate_(i) * pos_ratio * bw_ratio

With the above balance_rate is an independent variable that tracks the
write bandwidth. Now possibly you'd want a low-pass filter on that since
your bw_ratio is a bit funny in the head, but that's another story.

Then when you use the balance_rate to actually throttle tasks you apply
your secondary control steering the dirty page count, yielding:

	task_rate =3D balance_rate * pos_ratio

>   and task_ratelimit_200ms happen to can be estimated from
>=20
>           task_ratelimit_200ms ~=3D balanced_rate_i * pos_ratio

>   We may alternatively record every task_ratelimit executed in the
>   past 200ms and average them all to get task_ratelimit_200ms. In this
>   way we take the "superfluous" pos_ratio out of sight :)=20

Right, so I'm not at all sure that makes sense, its not immediately
evident that <task_ratelimit> ~=3D balance_rate * pos_ratio. Nor is it
clear to me why your primary feedback loop uses task_ratelimit_200ms at
all.=20

>   There is fundamentally no dependency between balanced_rate_(i+1) and
>   balanced_rate_i/task_ratelimit_200ms: the balanced_rate estimation
>   only asks for _whatever_ CONSTANT task ratelimit to be executed for
>   200ms, then it get the balanced rate from the dirty_rate feedback.

How can there not be a relation between balance_rate_(i+1) and
balance_rate_(i) ?=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
