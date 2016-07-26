Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC6F6B0260
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:14:15 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q83so3543198iod.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:14:15 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f74si11520iod.184.2016.07.26.00.14.13
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 00:14:14 -0700 (PDT)
Date: Tue, 26 Jul 2016 16:18:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 06/11] mm/slab: don't keep free slabs if free_objects
 exceeds free_limit
Message-ID: <20160726071848.GA15721@js1304-P5Q-DELUXE>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1460436666-20462-7-git-send-email-iamjoonsoo.kim@lge.com>
 <2b417127-20a6-ef00-f541-57337a97c9ec@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2b417127-20a6-ef00-f541-57337a97c9ec@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org

On Fri, Jul 22, 2016 at 08:51:02PM +0900, Tetsuo Handa wrote:
> Joonsoo Kim wrote:
> > @@ -3313,6 +3310,14 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
> >  			list_add_tail(&page->lru, &n->slabs_partial);
> >  		}
> >  	}
> > +
> > +	while (n->free_objects > n->free_limit && !list_empty(&n->slabs_free)) {
> > +		n->free_objects -= cachep->num;
> > +
> > +		page = list_last_entry(&n->slabs_free, struct page, lru);
> > +		list_del(&page->lru);
> > +		list_add(&page->lru, list);
> > +	}
> >  }
> >  
> >  static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
> > 
> 
> I noticed that kmemcheck complains that n->free_limit is not initialized.
> 
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (ffff88013ec085b8)
> [    0.000000] a085c03e0188ffffa085c03e0188ffff06000000000000000000000000000000
> [    0.000000]  i i i i i i i i i i i i i i i i i i i i i i i i u u u u i i i i
> [    0.000000]                                                  ^
> [    0.000000] RIP: 0010:[<ffffffff8113073e>]  [<ffffffff8113073e>] free_block+0x14e/0x1d0
> [    0.000000] RSP: 0000:ffffffff81803e58  EFLAGS: 00010046
> [    0.000000] RAX: 0000000000000006 RBX: ffff88013ec0c000 RCX: 0000000000000000
> [    0.000000] RDX: 0000000000000000 RSI: ffff88013f7c5418 RDI: ffff88013ec0c000
> [    0.000000] RBP: ffffffff81803e88 R08: ffffffff81803ea0 R09: ffff88013ec08580
> [    0.000000] R10: ffff88013f7c55d0 R11: 00000000000005cd R12: ffff88013f7c5408
> [    0.000000] R13: ffffffff81803ea0 R14: 0000000002000000 R15: 000000000000001b
> [    0.000000] FS:  0000000000000000(0000) GS:ffffffff8182c000(0000) knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: ffff88013e800000 CR3: 000000000180c000 CR4: 00000000000406b0
> [    0.000000]  [<ffffffff81131a84>] __do_tune_cpucache+0x84/0x310
> [    0.000000]  [<ffffffff81131d35>] do_tune_cpucache+0x25/0x90
> [    0.000000]  [<ffffffff81131df0>] enable_cpucache+0x50/0xc0
> [    0.000000]  [<ffffffff818b5c70>] kmem_cache_init_late+0x3f/0x68
> [    0.000000]  [<ffffffff81895eda>] start_kernel+0x2f2/0x48d
> [    0.000000]  [<ffffffff8189553a>] x86_64_start_reservations+0x2f/0x31
> [    0.000000]  [<ffffffff81895632>] x86_64_start_kernel+0xf6/0x111
> [    0.000000]  [<ffffffffffffffff>] 0xffffffffffffffff
> [    0.000000] tsc: Unable to calibrate against PIT
> [    0.000000] tsc: using PMTIMER reference calibration
> [    0.000000] tsc: Detected 2793.551 MHz processor
> 
> Setting 0 at kmem_cache_node_init() fixes the problem, but what the initial
> value should be? (Since list_empty(&n->slabs_free) == true, uninitialized
> read of n->free_limit does not cause problems except kmemcheck.)

Setting 0 would be okay because it would mean that we don't want to cache any
object on kmem_cache_node. We will re-initialize it soon so it doesn't
cause any problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
