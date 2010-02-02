Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6A1856B0078
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 09:21:32 -0500 (EST)
Date: Tue, 2 Feb 2010 08:21:30 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202142130.GI6616@sgi.com>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
 <20100202131341.GI4135@random.random>
 <20100202132919.GO6653@sgi.com>
 <20100202134047.GJ4135@random.random>
 <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202141036.GL4135@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 03:10:36PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 02, 2010 at 07:51:41AM -0600, Robin Holt wrote:
> > I don't see the change in API with this method either.
> 
> The API change I'm referring to, is the reason that you had to patch
> virt/kvm/kvm_main.c and drivers/misc/sgi-gru/grutlbpurge.c to prevent

So the API is an mmu_notifier thing and not external.  I think
adding reference counting to the VMA  and converting the i_mmap_lock
to i_mmap_sem might have a slightly larger impact on users of kernel
headers than this proposal.

> compile failure. That isn't needed if we really make mmu notifier
> sleepable like my old patched did just fine. Except they slowed down
> the locking to achieve it... (the slowdown should be confined to
> config option) and you don't want that I guess. But if you didn't need

Your argument seems ridiculous.  Take this larger series of patches which
touches many parts of the kernel and has a runtime downside for 99% of
the user community but only when configured on and then try and argue
with the distros that they should slow all users down for our 1%.

> to return -EINVAL I think your userland would also be safer. Only

I think you missed my correction to an earlier statement.  This patcheset
does not have any data corruption or userland inconsistency.  I had mistakenly
spoken of a patchset I am working up as a lesser alternative to this one.

> problem I can see is that you would then have trouble to convince
> distro to build with the slower locking and you basically are ok to
> break userland in truncate to be sure your module will work with
> default binary distro kernel. It's a tradeoff and I'm not against it
> but it has to be well documented that this is an hack to be practical
> on binary shipped kernels.

This is no more a hack than the other long list of compromises that have
been made in the past.  Very similar to your huge page patchset which
invalidates a page by using the range callout.  NIHS is not the same as
a hack.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
