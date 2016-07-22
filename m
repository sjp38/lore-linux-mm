Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14D126B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 07:52:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so226148207pfb.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:52:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id tm1si15613320pac.20.2016.07.22.04.52.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 04:52:46 -0700 (PDT)
Subject: Re: [PATCH v2 06/11] mm/slab: don't keep free slabs if free_objects
 exceeds free_limit
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1460436666-20462-7-git-send-email-iamjoonsoo.kim@lge.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <2b417127-20a6-ef00-f541-57337a97c9ec@I-love.SAKURA.ne.jp>
Date: Fri, 22 Jul 2016 20:51:02 +0900
MIME-Version: 1.0
In-Reply-To: <1460436666-20462-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Joonsoo Kim wrote:
> @@ -3313,6 +3310,14 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
>  			list_add_tail(&page->lru, &n->slabs_partial);
>  		}
>  	}
> +
> +	while (n->free_objects > n->free_limit && !list_empty(&n->slabs_free)) {
> +		n->free_objects -= cachep->num;
> +
> +		page = list_last_entry(&n->slabs_free, struct page, lru);
> +		list_del(&page->lru);
> +		list_add(&page->lru, list);
> +	}
>  }
>  
>  static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
> 

I noticed that kmemcheck complains that n->free_limit is not initialized.

[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (ffff88013ec085b8)
[    0.000000] a085c03e0188ffffa085c03e0188ffff06000000000000000000000000000000
[    0.000000]  i i i i i i i i i i i i i i i i i i i i i i i i u u u u i i i i
[    0.000000]                                                  ^
[    0.000000] RIP: 0010:[<ffffffff8113073e>]  [<ffffffff8113073e>] free_block+0x14e/0x1d0
[    0.000000] RSP: 0000:ffffffff81803e58  EFLAGS: 00010046
[    0.000000] RAX: 0000000000000006 RBX: ffff88013ec0c000 RCX: 0000000000000000
[    0.000000] RDX: 0000000000000000 RSI: ffff88013f7c5418 RDI: ffff88013ec0c000
[    0.000000] RBP: ffffffff81803e88 R08: ffffffff81803ea0 R09: ffff88013ec08580
[    0.000000] R10: ffff88013f7c55d0 R11: 00000000000005cd R12: ffff88013f7c5408
[    0.000000] R13: ffffffff81803ea0 R14: 0000000002000000 R15: 000000000000001b
[    0.000000] FS:  0000000000000000(0000) GS:ffffffff8182c000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: ffff88013e800000 CR3: 000000000180c000 CR4: 00000000000406b0
[    0.000000]  [<ffffffff81131a84>] __do_tune_cpucache+0x84/0x310
[    0.000000]  [<ffffffff81131d35>] do_tune_cpucache+0x25/0x90
[    0.000000]  [<ffffffff81131df0>] enable_cpucache+0x50/0xc0
[    0.000000]  [<ffffffff818b5c70>] kmem_cache_init_late+0x3f/0x68
[    0.000000]  [<ffffffff81895eda>] start_kernel+0x2f2/0x48d
[    0.000000]  [<ffffffff8189553a>] x86_64_start_reservations+0x2f/0x31
[    0.000000]  [<ffffffff81895632>] x86_64_start_kernel+0xf6/0x111
[    0.000000]  [<ffffffffffffffff>] 0xffffffffffffffff
[    0.000000] tsc: Unable to calibrate against PIT
[    0.000000] tsc: using PMTIMER reference calibration
[    0.000000] tsc: Detected 2793.551 MHz processor

Setting 0 at kmem_cache_node_init() fixes the problem, but what the initial
value should be? (Since list_empty(&n->slabs_free) == true, uninitialized
read of n->free_limit does not cause problems except kmemcheck.)

diff --git a/mm/slab.c b/mm/slab.c
index cc6d816..6e0fa8c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -233,6 +233,7 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 	spin_lock_init(&parent->list_lock);
 	parent->free_objects = 0;
 	parent->free_touched = 0;
+	parent->free_limit = 0;
 }
 
 #define MAKE_LIST(cachep, listp, slab, nodeid)				\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
