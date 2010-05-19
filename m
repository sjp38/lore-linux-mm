Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A4AA26B0216
	for <linux-mm@kvack.org>; Wed, 19 May 2010 09:56:26 -0400 (EDT)
Date: Wed, 19 May 2010 23:56:24 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] cache last free vmap_area to avoid restarting beginning
Message-ID: <20100519135624.GA2516@laptop>
References: <1271350270.2013.29.camel@barrios-desktop>
 <1271427056.7196.163.camel@localhost.localdomain>
 <1271603649.2100.122.camel@barrios-desktop>
 <1271681929.7196.175.camel@localhost.localdomain>
 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
 <1272548602.7196.371.camel@localhost.localdomain>
 <1272821394.2100.224.camel@barrios-desktop>
 <1273063728.7196.385.camel@localhost.localdomain>
 <20100505161632.GB5378@laptop>
 <1274277294.2532.54.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1274277294.2532.54.camel@localhost>
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 19, 2010 at 02:54:54PM +0100, Steven Whitehouse wrote:
> On Thu, 2010-05-06 at 02:16 +1000, Nick Piggin wrote:
> > On Wed, May 05, 2010 at 01:48:48PM +0100, Steven Whitehouse wrote:
> > Any chance you could test it?
> > 
> 
> At last some further info on the failed boot during testing. The
> messages look like this:
> 
> dracut: Starting plymouth daemon
> G------------[ cut here ]------------
> kernel BUG at mm/vmalloc.c:391!
> invalid opcode: 0000 [#1] SMP 
> last sysfs file: /sys/devices/virtual/vtconsole/vtcon0/uevent
> CPU 7 
> Modules linked in:
> Pid: 193, comm: modprobe Tainted: G        W  2.6.32-23.el6.bz583026.patches2.3.7.x86_64 #1 ProLiant DL580 G3
> RIP: 0010:[<ffffffff8113c161>]  [<ffffffff8113c161>] alloc_vmap_area+0x431/0x440
> RSP: 0018:ffff8803dae3bcf8  EFLAGS: 00010287
> RAX: ffffc9001232e000 RBX: 0000000000004000 RCX: 0000000000000000
> RDX: ffffffffa0000000 RSI: ffff8803db66fdc0 RDI: ffffffff81b6d0a0
> RBP: ffff8803dae3bd88 R08: 000000000000000a R09: 00000000000000d0
> R10: ffff8803db6b6e40 R11: 0000000000000040 R12: 0000000000000001
> R13: ffffffffff000000 R14: ffffffffffffffff R15: ffffffffa0000000
> FS:  00007f5872189700(0000) GS:ffff88002c2e0000(0000) knlGS:0000000000000000
> 
> and the code around that point is:
> 
> static struct vmap_area *alloc_vmap_area(unsigned long size,
>                                 unsigned long align,
>                                 unsigned long vstart, unsigned long vend,
>                                 int node, gfp_t gfp_mask)
> {
> 
> ...
> 
>                 if (!first)
>                         goto found;
> 
>                 if (first->va_start < addr) {
> 391>                    BUG_ON(first->va_end < addr);
>                         n = rb_next(&first->rb_node);
>                         addr = ALIGN(first->va_end + PAGE_SIZE, align);
>                         if (n)
>                                 first = rb_entry(n, struct vmap_area, rb_node);
>                         else
>                                 goto found;
>                 }
> 
> 
> so that seems to pinpoint the line on which the problem occurred. Let us
> know if you'd like us to do some more testing. I think we have the
> console access issue fixed now. Many thanks for all you help in this
> so far,

Thanks for testing it out. Hmm, I thought I'd shaken out these bugs --
I put the code in a userspace test harness and hammered it pretty hard,
but I must have overlooked something or you're triggering a really
specific sequence.

Let me get back to you if I cannot trigger anything here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
