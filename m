Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1700A6B0241
	for <linux-mm@kvack.org>; Thu,  6 May 2010 02:32:10 -0400 (EDT)
Date: Thu, 6 May 2010 09:27:55 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: virtio: put last_used and last_avail index into ring itself.
Message-ID: <20100506062755.GC8363@redhat.com>
References: <cover.1257349249.git.mst@redhat.com> <200911091647.29655.rusty@rustcorp.com.au> <20100504182236.GA14141@redhat.com> <201005061022.13815.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201005061022.13815.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 10:22:12AM +0930, Rusty Russell wrote:
> On Wed, 5 May 2010 03:52:36 am Michael S. Tsirkin wrote:
> > > virtio: put last_used and last_avail index into ring itself.
> > > 
> > > Generally, the other end of the virtio ring doesn't need to see where
> > > you're up to in consuming the ring.  However, to completely understand
> > > what's going on from the outside, this information must be exposed.
> > > For example, if you want to save and restore a virtio_ring, but you're
> > > not the consumer because the kernel is using it directly.
> > > 
> > > Fortunately, we have room to expand: the ring is always a whole number
> > > of pages and there's hundreds of bytes of padding after the avail ring
> > > and the used ring, whatever the number of descriptors (which must be a
> > > power of 2).
> > > 
> > > We add a feature bit so the guest can tell the host that it's writing
> > > out the current value there, if it wants to use that.
> > > 
> > > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> > 
> > I've been looking at this patch some more (more on why
> > later), and I wonder: would it be better to add some
> > alignment to the last used index address, so that
> > if we later add more stuff at the tail, it all
> > fits in a single cache line?
> 
> In theory, but not in practice.  We don't have many rings, so the
> difference between 1 and 2 cache lines is not very much.

Fair enough.

> > We use a new feature bit anyway, so layout change should not be
> > a problem.
> > 
> > Since I raised the question of caches: for used ring,
> > the ring is not aligned to 64 bit, so on CPUs with 64 bit
> > or larger cache lines, used entries will often cross
> > cache line boundaries. Am I right and might it
> > have been better to align ring entries to cache line boundaries?
> > 
> > What do you think?
> 
> I think everyone is settled on 128 byte cache lines for the forseeable
> future, so it's not really an issue.
> 
> Cheers,
> Rusty.

You mean with 64 bit descriptors we will be bouncing a cache line
between host and guest, anyway?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
