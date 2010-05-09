Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BBF4D6B021C
	for <linux-mm@kvack.org>; Sun,  9 May 2010 05:02:21 -0400 (EDT)
Date: Sun, 9 May 2010 11:57:33 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: virtio: put last_used and last_avail index into ring itself.
Message-ID: <20100509085733.GD16775@redhat.com>
References: <cover.1257349249.git.mst@redhat.com> <201005061022.13815.rusty@rustcorp.com.au> <20100506062755.GC8363@redhat.com> <201005071235.40590.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201005071235.40590.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 07, 2010 at 12:35:39PM +0930, Rusty Russell wrote:
> On Thu, 6 May 2010 03:57:55 pm Michael S. Tsirkin wrote:
> > On Thu, May 06, 2010 at 10:22:12AM +0930, Rusty Russell wrote:
> > > On Wed, 5 May 2010 03:52:36 am Michael S. Tsirkin wrote:
> > > > What do you think?
> > > 
> > > I think everyone is settled on 128 byte cache lines for the forseeable
> > > future, so it's not really an issue.
> > 
> > You mean with 64 bit descriptors we will be bouncing a cache line
> > between host and guest, anyway?
> 
> I'm confused by this entire thread.
> 
> Descriptors are 16 bytes.  They are at the start, so presumably aligned to
> cache boundaries.
> 
> Available ring follows that at 2 bytes per entry, so it's also packed nicely
> into cachelines.
> 
> Then there's padding to page boundary.  That puts us on a cacheline again
> for the used ring; also 2 bytes per entry.
> 

Hmm, is used ring really 2 bytes per entry?


/* u32 is used here for ids for padding reasons. */
struct vring_used_elem {
        /* Index of start of used descriptor chain. */
        __u32 id;
        /* Total length of the descriptor chain which was used (written to) */
        __u32 len;
};

struct vring_used {
        __u16 flags;
        __u16 idx;
        struct vring_used_elem ring[];
};

> I don't see how any change in layout could be more cache friendly?
> Rusty.

I thought that used ring has 8 bytes per entry, and that struct
vring_used is aligned at page boundary, this
would mean that ring element is at offset 4 bytes from page boundary.
Thus with cacheline size 128 bytes, each 4th element crosses
a cacheline boundary. If we had a 4 byte padding after idx, each
used element would always be completely within a single cacheline.

What am I missing?
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
