Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4D39000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 05:47:46 -0400 (EDT)
Date: Thu, 7 Jul 2011 10:47:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/14] Swap-over-NBD without deadlocking v5
Message-ID: <20110707094737.GG15285@suse.de>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
 <20110706165146.be7ab61b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110706165146.be7ab61b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Jul 06, 2011 at 04:51:46PM -0700, Andrew Morton wrote:
> On Mon, 20 Jun 2011 14:12:06 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Swapping over NBD is something that is technically possible but not
> > often advised. While there are number of guides on the internet
> > on how to configure it and nbd-client supports a -swap switch to
> > "prevent deadlocks", the fact of the matter is a machine using NBD
> > for swap can be locked up within minutes if swap is used intensively.
> > 
> > The problem is that network block devices do not use mempools like
> > normal block devices do. As the host cannot control where they receive
> > packets from, they cannot reliably work out in advance how much memory
> > they might need.
> > 
> > Some years ago, Peter Ziljstra developed a series of patches that
> > supported swap over an NFS that some distributions are carrying in
> > their kernels. This patch series borrows very heavily from Peter's work
> > to support swapping over NBD (the relatively straight-forward case)
> > and uses throttling instead of dynamically resized memory reserves
> > so the series is not too unwieldy for review.
> 
> I have to say, I look over these patches and my mind wants to turn to
> things like puppies.  And ice cream.
> 

People do love puppies and ice cream!

> There's quite some complexity added here in areas which are already
> reliably unreliable and afaik swap-over-NBD is not a thing which a lot
> of people want to do. I can see that swap-over-NFS would be useful to
> some people, and the fact that distros are carrying swap-over-NFS
> patches has weight.
> 
> Do these patches lead on to swap-over-NFS?  If so, how much more
> additional complexity are we buying into for that?

Swap-over-NFS is the primary motivation. As you say, distributions are
carrying this and have been for some time. Based on my asking about the
background, the primary user is clusters of blades that are diskless
or have extremely limited storage with no possibility of expansion (be
it due to physical dimensions or maintenance overhead). They require
an amount of infrequently used swap for their workloads. They are
connected to some sort of SAN that may or may not be running Linux
but that exports NFS so they want to stick a swapfile on it.

Swap-over-NBD is the simplier case that can be used if the SAN
is running Linux. Almost all of the compexity required to support
swap-over-NBD is reused for swap-over-NFS (obviously the NBD-specific
bits are not reused).

Additional complexity is required for swap-over-NFS but affects the
core kernel far less than this series. I do not have a series prepared
but from what's in a distro kernel, supporting NFS requires extending
address_space_operations for swapfile activation/deactivation with
some minor helpers and the bulk of the remaining complexity within
NFS itself.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
