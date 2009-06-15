Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 08EAD6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 03:01:06 -0400 (EDT)
Date: Mon, 15 Jun 2009 09:09:14 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615070914.GC31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615064447.GA18390@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 08:44:47AM +0200, Nick Piggin wrote:
> > 
> > So IMHO it's OK for .31 as long as we agree on the user interfaces,
> > ie. /proc/sys/vm/memory_failure_early_kill and the hwpoison uevent.
> > 
> > It comes a long way through numerous reviews, and I believe all the
> > important issues and concerns have been addressed. Nick, Rik, Hugh,
> > Ingo, ... what are your opinions? Is the uevent good enough to meet
> > your request to "die hard" or "die gracefully" or whatever on memory
> > failure events?
> 
> Uevent? As in, send a message to userspace? I don't think this
> would be ideal for a fail-stop/failover situation.

Agreed.

For failover you typically want a application level heartbeat anyways
to guard against user space software problems and if there's a kill then it
would catch it. Also again in you want to check against all corruptions you
have to do it in the low level handler or better watch corrected
events too to predict failures (but the later is quite hard to do generally). 
To some extent the first is already implemented on x86, e.g. set
the tolerance level to 0 will give more aggressive panics.

> I can't see a good reason to rush to merge it.

The low level x86 code for MCA recovery is in, just this high level
part is missing to kill the correct process. I think it would be good to merge 
a core now.  The basic code seems to be also as well tested as we can do it 
right now and exposing it to more users would be good. It's undoubtedly not 
perfect yet, but that's not a requirement for merge.

There's a lot of fancy stuff that could be done in addition,
but that's not really needed right now and for a lot of the fancy
ideas (I have enough on my own :) it's dubious they are actually
worth it.

> IMO the userspace-visible changes have maybe not been considered
> too thoroughly, which is what I'd be most worried about. I probably
> missed seeing documentation of exact semantics and situations
> where admins should tune things one way or the other.

There's only a single tunable anyways, early kill vs late kill.

For KVM you need early kill, for the others it remains to be seen.

> I hope it is going to be merged with an easy-to-use fault injector,
> because that is the only way Joe kernel developer is ever going to
> test it.

See patches 13 and 14. In addition there's another low level x86
injector too.

There's also a test suite available (mce-test on kernel.org git)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
