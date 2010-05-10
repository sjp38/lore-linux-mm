Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9A66B026D
	for <linux-mm@kvack.org>; Mon, 10 May 2010 04:54:16 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio: put last_used and last_avail index into ring itself.
Date: Mon, 10 May 2010 12:41:56 +0930
References: <cover.1257349249.git.mst@redhat.com> <201005071235.40590.rusty@rustcorp.com.au> <20100509085733.GD16775@redhat.com>
In-Reply-To: <20100509085733.GD16775@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201005101241.57237.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, 9 May 2010 06:27:33 pm Michael S. Tsirkin wrote:
> On Fri, May 07, 2010 at 12:35:39PM +0930, Rusty Russell wrote:
> > Then there's padding to page boundary.  That puts us on a cacheline again
> > for the used ring; also 2 bytes per entry.
> > 
> 
> Hmm, is used ring really 2 bytes per entry?

Err, no, I am an idiot.

> /* u32 is used here for ids for padding reasons. */
> struct vring_used_elem {
>         /* Index of start of used descriptor chain. */
>         __u32 id;
>         /* Total length of the descriptor chain which was used (written to) */
>         __u32 len;
> };
> 
> struct vring_used {
>         __u16 flags;
>         __u16 idx;
>         struct vring_used_elem ring[];
> };

OK, now I get it.  Sorry, I was focussed on the avail ring.

> I thought that used ring has 8 bytes per entry, and that struct
> vring_used is aligned at page boundary, this
> would mean that ring element is at offset 4 bytes from page boundary.
> Thus with cacheline size 128 bytes, each 4th element crosses
> a cacheline boundary. If we had a 4 byte padding after idx, each
> used element would always be completely within a single cacheline.

I think the numbers are: every 16th entry hits two cachelines.  So currently
the first 15 entries are "free" (assuming we hit the idx cacheline anyway),
then 1 in 16 cost 2 cachelines.  That makes the aligned version win when
N > 240.

But, we access the array linearly.  So the extra cacheline cost is in fact
amortized.  I doubt it could be measured, but maybe vring_get_buf() should
prefetch?  While you're there, we could use an & rather than a mod on the
calculation, which may actually be measurable :)

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
