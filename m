Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB3D6B00BB
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 23:46:07 -0400 (EDT)
Date: Sun, 8 Mar 2009 20:45:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2] memdup_user(): introduce
Message-Id: <20090308204535.8a2af3fa.akpm@linux-foundation.org>
In-Reply-To: <49B48D4A.6000207@cn.fujitsu.com>
References: <49B0CAEC.80801@cn.fujitsu.com>
	<20090306082056.GB3450@x200.localdomain>
	<49B0DE89.9000401@cn.fujitsu.com>
	<20090306003900.a031a914.akpm@linux-foundation.org>
	<49B0E67C.2090404@cn.fujitsu.com>
	<20090306011548.ffdf9cbc.akpm@linux-foundation.org>
	<49B0F1B9.1080903@cn.fujitsu.com>
	<20090306150335.c512c1b6.akpm@linux-foundation.org>
	<20090307084805.7cf3d574@infradead.org>
	<49B47D50.5000608@cn.fujitsu.com>
	<20090308200033.f5282b5b.akpm@linux-foundation.org>
	<49B48D4A.6000207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Arjan van de Ven <arjan@infradead.org>, adobriyan@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Karsten Keil <kkeil@suse.de>, Samuel Ortiz <samuel@sortiz.org>, Chris Mason <chris.mason@oracle.com>, Steven Whitehouse <swhiteho@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Mon, 09 Mar 2009 11:30:18 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:

> Andrew Morton wrote:
> > On Mon, 09 Mar 2009 10:22:08 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> >>>>> +EXPORT_SYMBOL(memdup_user);
> >>> Hi,
> >>>
> >>> I like the general idea of this a lot; it will make things much less
> >>> error prone (and we can add some sanity checks on "len" to catch the
> >>> standard security holes around copy_from_user usage). I'd even also
> >>> want a memdup_array() like thing in the style of calloc().
> >>>
> >>> However, I have two questions/suggestions for improvement:
> >>>
> >>> I would like to question the use of the gfp argument here;
> >>> copy_from_user sleeps, so you can't use GFP_ATOMIC anyway.
> >>> You can't use GFP_NOFS etc, because the pagefault path will happily do
> >>> things that are equivalent, if not identical, to GFP_KERNEL.
> >>>
> >>> So the only value you can pass in correctly, as far as I can see, is
> >>> GFP_KERNEL. Am I wrong?
> >>>
> >> Right! I just dug and found a few kmalloc(GFP_ATOMIC/GFP_NOFS)+copy_from_user(),
> >> so we have one more reason to use this memdup_user().
> > 
> > gack, those callsites are probably buggy.  Where are they?
> > 
> 
> Yes, either buggy or should use GFP_KERNEL.
> 
> All are in -mm only, except the first one:
> 
> drivers/isdn/i4l/isdn_common.c:
> 	struct sk_buff *skb = alloc_skb(hl + len, GFP_ATOMIC);
> 	...
> 	if (copy_from_user(skb_put(skb, len), buf, len)) {

Bug.  Should be GFP_KERNEL, or copy_from_user() is incorrect in this
context.

> 
> net/irda/af_irda.c:
> 	ias_opt = kmalloc(sizeof(struct irda_ias_set), GFP_ATOMIC);
> 	...
> 	if (copy_from_user(ias_opt, optval, optlen)) {

Bug.  Should be GFP_KERNEL, or copy_from_user() is incorrect in this
context.

> 
> fs/btrfs/ioctl.c:
> 	vol_args = kmalloc(sizeof(*vol_args), GFP_NOFS);
> 	...
> 	if (copy_from_user(vol_args, arg, sizeof(*vol_args))) {

Bug.  Should be GFP_KERNEL, or copy_from_user() is incorrect in this
context.

> > fs/ocfs2/dlm/dlmfs.c:
> 	lvb_buf = kmalloc(writelen, GFP_NOFS);
> 	...
> 	bytes_left = copy_from_user(lvb_buf, buf, writelen);

Bug.  Should be GFP_KERNEL, or copy_from_user() is incorrect in this
context.

> 
> net/sunrpc/auth_gss/auth_gss.c:
> 	buf = kmalloc(mlen, GFP_NOFS);
> 	...
> 	if (copy_from_user(buf, src, mlen))

Bug.  Should be GFP_KERNEL, or copy_from_user() is incorrect in this
context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
