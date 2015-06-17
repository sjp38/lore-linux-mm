Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E80436B0085
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 06:18:00 -0400 (EDT)
Received: by wifx6 with SMTP id x6so47674783wif.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 03:18:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wl7si6866662wjc.206.2015.06.17.03.17.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 03:17:58 -0700 (PDT)
Date: Wed, 17 Jun 2015 12:17:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] fs: inotify_handle_event() reading un-init memory
Message-ID: <20150617101754.GD1614@quack.suse.cz>
References: <20150616113300.10621.35439.stgit@devil>
 <20150616135209.GD7038@quack.suse.cz>
 <20150616222234.3ebc6402@redhat.com>
 <20150617081319.GA1614@quack.suse.cz>
 <20150617115707.7286616b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150617115707.7286616b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-06-15 11:57:07, Jesper Dangaard Brouer wrote:
> On Wed, 17 Jun 2015 10:13:19 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> > On Tue 16-06-15 22:22:34, Jesper Dangaard Brouer wrote:
> > > 
> > > On Tue, 16 Jun 2015 15:52:09 +0200 Jan Kara <jack@suse.cz> wrote:
> > > 
> > > > On Tue 16-06-15 13:33:18, Jesper Dangaard Brouer wrote:
> > > > > Caught by kmemcheck.
> > > > > 
> > > > > Don't know the fix... just pointed at the bug.
> > > > > 
> > > > > Introduced in commit 7053aee26a3 ("fsnotify: do not share
> > > > > events between notification groups").
> > > > > ---
> > > > >  fs/notify/inotify/inotify_fsnotify.c |    3 ++-
> > > > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > > > 
> > > > > diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> > > > > index 2cd900c2c737..370d66dc4ddb 100644
> > > > > --- a/fs/notify/inotify/inotify_fsnotify.c
> > > > > +++ b/fs/notify/inotify/inotify_fsnotify.c
> > > > > @@ -96,11 +96,12 @@ int inotify_handle_event(struct fsnotify_group *group,
> > > > >  	i_mark = container_of(inode_mark, struct inotify_inode_mark,
> > > > >  			      fsn_mark);
> > > > >  
> > > > > +	// new object alloc here
> > > > >  	event = kmalloc(alloc_len, GFP_KERNEL);
> > > > >  	if (unlikely(!event))
> > > > >  		return -ENOMEM;
> > > > >  
> > > > > -	fsn_event = &event->fse;
> > > > > +	fsn_event = &event->fse; // This looks wrong!?! read from un-init mem?
> > > > 
> > > > Where is here any read? This is just a pointer arithmetics where we add
> > > > offset of 'fse' entry to 'event' address.
> > > 
> > > I was kmemcheck that complained, perhaps it is a false-positive?
> >
> >   May be. What was the kmemcheck warning you saw? 
> 
> Kernel logmsg:
>  kernel: WARNING: kmemcheck: Caught 64-bit read from freed memory (ffff8800c8de7bc0)
>  kernel: 807bdec80088ffffc07bdec80088ffff588a508b0388ffff020000080000adde
>  kernel: f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f
>  kernel: ^
>  kernel: RIP: 0010:[<ffffffff8116148a>]  [<ffffffff8116148a>] __kmalloc+0x7a/0x1c0

Hum, but this one rather seems as a problem / false positive in __kmalloc()
itself, not in the inotify code...

>  kernel: RSP: 0018:ffff88038b47fc88  EFLAGS: 00010286
>  kernel: RAX: 0000000000000000 RBX: ffff88038b5df138 RCX: 0000000000012e2b
>  kernel: RDX: 0000000000012e2a RSI: 0000000000000000 RDI: ffffffff811aef8a
>  kernel: RBP: ffff88038b47fcb8 R08: 00000000000217f0 R09: ffff88038b508cd8
>  kernel: R10: 0000000000000000 R11: ffff88038b6ede00 R12: ffff88038f803b00
>  kernel: R13: ffff8800c8de7bc0 R14: 000000000000003f R15: 00000000000000d0
>  kernel: FS:  0000000000000000(0000) GS:ffff88038fd40000(0000) knlGS:0000000000000000
>  kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  kernel: CR2: ffff8800c8feaab0 CR3: 000000038c424000 CR4: 00000000001407e0
>  kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>  kernel: DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
>  kernel: [<ffffffff811aef8a>] inotify_handle_event+0x6a/0x180
>  kernel: [<ffffffff811acd0d>] fsnotify+0x2cd/0x480
>  kernel: [<ffffffff811ad0dd>] __fsnotify_parent+0xdd/0xf0
>  kernel: [<ffffffff8118f49f>] notify_change+0x26f/0x3a0
>  kernel: [<ffffffff81172378>] do_truncate+0x68/0xa0
>  kernel: [<ffffffff811726dc>] do_sys_ftruncate.constprop.16+0xfc/0x150
>  kernel: [<ffffffff81172759>] SyS_ftruncate+0x9/0x10
>  kernel: [<ffffffff81658117>] system_call_fastpath+0x12/0x6a
>  kernel: [<ffffffffffffffff>] 0xffffffffffffffff
> 
> > And can you also attach  disassembly of inotify_handle_event() from
> > your kernel? 
> 
> No, it was many kernel compile since...
> 
> I tried to reproduce on my current kernel, and now I don't hit it.  But
> I hit this instead (which is NOT related to your code):
> 
>  kernel: WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff8800371df628)
>  kernel: 189626090488ffff60351f370088ffffb50300000000000038f61d370088ffff
>  kernel: u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
>  kernel:                 ^
>  kernel: RIP: 0010:[<ffffffff8110d9a6>]  [<ffffffff8110d9a6>] vma_interval_tree_remove+0x1c6/0x240
>  kernel: RSP: 0018:ffff880408a2fd30  EFLAGS: 00010286
>  kernel: RAX: ffff8800371df618 RBX: ffff8804092fb700 RCX: 0000000000000000
>  kernel: RDX: ffff8800371df619 RSI: ffff88040d05b6b8 RDI: ffff8800371f3508
>  kernel: RBP: ffff880408a2fd38 R08: 00007f556712a000 R09: ffff880000000000
>  kernel: R10: ffff8800371f3560 R11: 0000000000000000 R12: ffff8800371f3508
>  kernel: R13: ffff88040d05b6c0 R14: ffff88040d05b698 R15: ffff8800371f3508
>  kernel: FS:  0000000000000000(0000) GS:ffff88041dc40000(0000) knlGS:0000000000000000
>  kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  kernel: CR2: ffff8800c6865540 CR3: 00000000018bb000 CR4: 00000000001407e0
>  kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>  kernel: DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
>  kernel: [<ffffffff8111738b>] unlink_file_vma+0x3b/0x50
>  kernel: [<ffffffff81110e20>] free_pgtables+0xb0/0x120
>  kernel: [<ffffffff8111a1d7>] exit_mmap+0xd7/0x150
>  kernel: [<ffffffff81053cd0>] mmput+0x50/0xe0
>  kernel: [<ffffffff811182de>] SyS_mmap_pgoff+0x10e/0x210
>  kernel: [<ffffffff8100796d>] SyS_mmap+0x1d/0x20
>  kernel: [<ffffffff815fabd7>] system_call_fastpath+0x12/0x6a
>  kernel: [<ffffffffffffffff>] 0xffffffffffffffff
> 
> $ addr2line -e vmlinux -i ffffffff8110d9a6
> /home/jbrouer/git/kernel/net-next-mm/include/linux/rbtree_augmented.h:125
> /home/jbrouer/git/kernel/net-next-mm/include/linux/rbtree_augmented.h:154
> /home/jbrouer/git/kernel/net-next-mm/include/linux/rbtree_augmented.h:237
> /home/jbrouer/git/kernel/net-next-mm/mm/interval_tree.c:24
> 
> $ gdb vmlinux
> (gdb) list *(vma_interval_tree_remove)+0x1c6
> 0xffffffff8110d9a6 is in vma_interval_tree_remove (include/linux/rbtree_augmented.h:125).
> 120	static inline void
> 121	__rb_change_child(struct rb_node *old, struct rb_node *new,
> 122			  struct rb_node *parent, struct rb_root *root)
> 123	{
> 124		if (parent) {
> 125 			if (parent->rb_left == old)
> 126				parent->rb_left = new;
> 127			else
> 128				parent->rb_right = new;
> 129		} else
  Hum, the data looks correct from the first look and the stack trace
doesn't show anything unusual either so it looks like a false positive to
me. It may deserve a closer investigation though.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
