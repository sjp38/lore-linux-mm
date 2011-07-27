Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0271D6B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 19:28:52 -0400 (EDT)
Date: Wed, 27 Jul 2011 16:28:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] tmpfs radix_tree: locate_item to speed up swapoff
Message-Id: <20110727162819.b595e442.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1107191553040.1593@sister.anvils>
References: <alpine.LSU.2.00.1107191549540.1593@sister.anvils>
	<alpine.LSU.2.00.1107191553040.1593@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 19 Jul 2011 15:54:23 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> We have already acknowledged that swapoff of a tmpfs file is slower
> than it was before conversion to the generic radix_tree: a little
> slower there will be acceptable, if the hotter paths are faster.
> 
> But it was a shock to find swapoff of a 500MB file 20 times slower
> on my laptop, taking 10 minutes; and at that rate it significantly
> slows down my testing.

So it used to take half a minute?  That was already awful.  Why?  Was
it IO-bound?  It doesn't sound like it.

> Now, most of that turned out to be overhead from PROVE_LOCKING and
> PROVE_RCU: without those it was only 4 times slower than before;
> and more realistic tests on other machines don't fare as badly.

What's unrealistic about doing swapoff of a 500MB tmpfs file?

Also, confused.  You're talking about creating a regular file on tmpfs
and then using that as a swapfile?  If so, that's a
kernel-hacker-curiosity only?

> I've tried a number of things to improve it, including tagging the
> swap entries, then doing lookup by tag: I'd expected that to halve
> the time, but in practice it's erratic, and often counter-productive.
> 
> The only change I've so far found to make a consistent improvement,
> is to short-circuit the way we go back and forth, gang lookup packing
> entries into the array supplied, then shmem scanning that array for the
> target entry.  Scanning in place doubles the speed, so it's now only
> twice as slow as before (or three times slower when the PROVEs are on).
> 
> So, add radix_tree_locate_item() as an expedient, once-off, single-caller
> hack to do the lookup directly in place.  #ifdef it on CONFIG_SHMEM and
> CONFIG_SWAP, as much to document its limited applicability as save space
> in other configurations.  And, sadly, #include sched.h for cond_resched().
> 

How much did that 10 minutes improve?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
