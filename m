Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1364C6B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 21:31:12 -0500 (EST)
Date: Mon, 22 Nov 2010 18:26:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Pass priority to shrink_slab
Message-Id: <20101122182627.11677116.akpm@linux-foundation.org>
In-Reply-To: <AANLkTik6XxhGn=ASmyhxbq6wuCGtUaiW6s8rZBTQUu8_@mail.gmail.com>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
	<20101119142552.df0e351c.akpm@linux-foundation.org>
	<AANLkTi=EnNqEDoWn6OiR04TaTBskNEZx4z8MOAYH8nK1@mail.gmail.com>
	<20101122150642.eec5f776.akpm@linux-foundation.org>
	<AANLkTik6XxhGn=ASmyhxbq6wuCGtUaiW6s8rZBTQUu8_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Ying Han <yinghan@google.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 18:09:33 -0800 Michel Lespinasse <walken@google.com> wrote:

> On Mon, Nov 22, 2010 at 3:06 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Fri, 19 Nov 2010 19:23:22 -0800
> > Ying Han <yinghan@google.com> wrote:
> >> Yes, and it would be much easier later to add a small feature (like this
> >> one) w/o
> >> touching so many files of the shrinkers. I am thinking if we can extend the
> >> scan_control
> >> from page reclaim and pass it down to the shrinker ?
> >
> > Yes, that might work. __All callers of shrink_slab() already have a
> > scan_control on the stack, so passing all that extra info to the
> > shrinkers (along with some extra fields if needed) is pretty cheap, and
> > I don't see a great downside to exposing unneeded fields to the
> > shrinkers, given they're already on the stack somewhere.
> 
> The only downside I can see is that it makes struct scan_control
> public - it'll need to be declared in a public header file so that all
> shrinkers can access it.

We've done worse things ;) Put it in scan_control.h and it will only be
exposed to code which has a legitimate need for it.

> Maybe one way to mitigate this would be if we can make the shrinker
> api take a *const* struct scan_control pointer as an argument, so that
> it'll be clear that we expect the shrinkers to only read the
> information in that struct.

Well, we might want callees to update fields in there, say "number of
bytes I managed to reclaim" or such.  We do that with
writeback_control.pages_skipped and it is comfortable enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
