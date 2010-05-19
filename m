Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C54916B0214
	for <linux-mm@kvack.org>; Wed, 19 May 2010 09:50:26 -0400 (EDT)
Subject: Re: [PATCH] cache last free vmap_area to avoid restarting beginning
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20100505161632.GB5378@laptop>
References: <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <1271681929.7196.175.camel@localhost.localdomain>
	 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
	 <1272548602.7196.371.camel@localhost.localdomain>
	 <1272821394.2100.224.camel@barrios-desktop>
	 <1273063728.7196.385.camel@localhost.localdomain>
	 <20100505161632.GB5378@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 May 2010 14:54:54 +0100
Message-ID: <1274277294.2532.54.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 2010-05-06 at 02:16 +1000, Nick Piggin wrote:
> On Wed, May 05, 2010 at 01:48:48PM +0100, Steven Whitehouse wrote:
> > Hi,
> > 
> > On Mon, 2010-05-03 at 02:29 +0900, Minchan Kim wrote:
> > > Hi, Steven. 
> > > 
> > > Sorry for lazy response.
> > > I wanted to submit the patch which implement Nick's request whole.
> > > And unfortunately, I am so busy now. 
> > > But if it's urgent, I want to submit this one firstly and 
> > > at next version, maybe I will submit remained TODO things 
> > > after middle of May.
> > > 
> > > I think this patch can't make regression other usages.
> > > Nick. What do you think about?
> > > 
> > I guess the question is whether the remaining items are essential for
> > correct functioning of this patch, or whether they are "it would be nice
> > if" items. I suspect that they are the latter (I'm not a VM expert, but
> > from the brief descriptions it looks like that to me) in which case I'd
> > suggest send the currently existing patch first and the following up
> > with the remaining changes later.
> > 
> > We have got a nice speed up with your current patch and so far as I'm
> > aware not introduced any new bugs or regressions with it.
> > 
> > Nick, does that sound ok?
> 
> Just got around to looking at it again. I definitely agree we need to
> fix the regression, however I'm concerned about introducing other
> possible problems while doing that.
> 
> The following patch should (modulo bugs, but it's somewhat tested) give
> no difference in the allocation patterns, so won't introduce virtual
> memory layout changes.
> 
> Any chance you could test it?
> 

At last some further info on the failed boot during testing. The
messages look like this:

dracut: Starting plymouth daemon
G------------[ cut here ]------------
kernel BUG at mm/vmalloc.c:391!
invalid opcode: 0000 [#1] SMP 
last sysfs file: /sys/devices/virtual/vtconsole/vtcon0/uevent
CPU 7 
Modules linked in:
Pid: 193, comm: modprobe Tainted: G        W  2.6.32-23.el6.bz583026.patches2.3.7.x86_64 #1 ProLiant DL580 G3
RIP: 0010:[<ffffffff8113c161>]  [<ffffffff8113c161>] alloc_vmap_area+0x431/0x440
RSP: 0018:ffff8803dae3bcf8  EFLAGS: 00010287
RAX: ffffc9001232e000 RBX: 0000000000004000 RCX: 0000000000000000
RDX: ffffffffa0000000 RSI: ffff8803db66fdc0 RDI: ffffffff81b6d0a0
RBP: ffff8803dae3bd88 R08: 000000000000000a R09: 00000000000000d0
R10: ffff8803db6b6e40 R11: 0000000000000040 R12: 0000000000000001
R13: ffffffffff000000 R14: ffffffffffffffff R15: ffffffffa0000000
FS:  00007f5872189700(0000) GS:ffff88002c2e0000(0000) knlGS:0000000000000000

and the code around that point is:

static struct vmap_area *alloc_vmap_area(unsigned long size,
                                unsigned long align,
                                unsigned long vstart, unsigned long vend,
                                int node, gfp_t gfp_mask)
{

...

                if (!first)
                        goto found;

                if (first->va_start < addr) {
391>                    BUG_ON(first->va_end < addr);
                        n = rb_next(&first->rb_node);
                        addr = ALIGN(first->va_end + PAGE_SIZE, align);
                        if (n)
                                first = rb_entry(n, struct vmap_area, rb_node);
                        else
                                goto found;
                }


so that seems to pinpoint the line on which the problem occurred. Let us
know if you'd like us to do some more testing. I think we have the
console access issue fixed now. Many thanks for all you help in this
so far,

Steve.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
