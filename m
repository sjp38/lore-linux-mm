Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CE3256B0299
	for <linux-mm@kvack.org>; Wed,  5 May 2010 20:52:24 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio: put last_used and last_avail index into ring itself.
Date: Thu, 6 May 2010 10:22:12 +0930
References: <cover.1257349249.git.mst@redhat.com> <200911091647.29655.rusty@rustcorp.com.au> <20100504182236.GA14141@redhat.com>
In-Reply-To: <20100504182236.GA14141@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201005061022.13815.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 5 May 2010 03:52:36 am Michael S. Tsirkin wrote:
> > virtio: put last_used and last_avail index into ring itself.
> > 
> > Generally, the other end of the virtio ring doesn't need to see where
> > you're up to in consuming the ring.  However, to completely understand
> > what's going on from the outside, this information must be exposed.
> > For example, if you want to save and restore a virtio_ring, but you're
> > not the consumer because the kernel is using it directly.
> > 
> > Fortunately, we have room to expand: the ring is always a whole number
> > of pages and there's hundreds of bytes of padding after the avail ring
> > and the used ring, whatever the number of descriptors (which must be a
> > power of 2).
> > 
> > We add a feature bit so the guest can tell the host that it's writing
> > out the current value there, if it wants to use that.
> > 
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> I've been looking at this patch some more (more on why
> later), and I wonder: would it be better to add some
> alignment to the last used index address, so that
> if we later add more stuff at the tail, it all
> fits in a single cache line?

In theory, but not in practice.  We don't have many rings, so the
difference between 1 and 2 cache lines is not very much.

> We use a new feature bit anyway, so layout change should not be
> a problem.
> 
> Since I raised the question of caches: for used ring,
> the ring is not aligned to 64 bit, so on CPUs with 64 bit
> or larger cache lines, used entries will often cross
> cache line boundaries. Am I right and might it
> have been better to align ring entries to cache line boundaries?
> 
> What do you think?

I think everyone is settled on 128 byte cache lines for the forseeable
future, so it's not really an issue.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
