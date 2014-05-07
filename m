Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1236B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 07:40:12 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so954406pdi.21
        for <linux-mm@kvack.org>; Wed, 07 May 2014 04:40:11 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id pb4si13655367pac.195.2014.05.07.04.40.10
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 04:40:10 -0700 (PDT)
Date: Wed, 7 May 2014 12:39:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140507113928.GB17253@arm.com>
References: <1398390340.4283.36.camel@kjgkr>
 <20140501170610.GB28745@arm.com>
 <20140501184112.GH23420@cmpxchg.org>
 <1399431488.13268.29.camel@kjgkr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399431488.13268.29.camel@kjgkr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, May 07, 2014 at 03:58:08AM +0100, Jaegeuk Kim wrote:
> And then when I tested again with Catalin's patch, it still throws the
> following warning.
> Is it false alarm?

BTW, you can try this kmemleak branch:

git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64.git kmemleak

> unreferenced object 0xffff880004226da0 (size 576):
>   comm "fsstress", pid 14590, jiffies 4295191259 (age 706.308s)
>   hex dump (first 32 bytes):
>     01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
>     50 89 34 81 ff ff ff ff b8 6d 22 04 00 88 ff ff  P.4......m".....
>   backtrace:
>     [<ffffffff816c02e8>] kmemleak_update_trace+0x58/0x80
>     [<ffffffff81349517>] radix_tree_node_alloc+0x77/0xa0
>     [<ffffffff81349718>] __radix_tree_create+0x1d8/0x230
>     [<ffffffff8113286c>] __add_to_page_cache_locked+0x9c/0x1b0
>     [<ffffffff811329a8>] add_to_page_cache_lru+0x28/0x80
>     [<ffffffff81132f58>] grab_cache_page_write_begin+0x98/0xf0
>     [<ffffffffa02e4bf4>] f2fs_write_begin+0xb4/0x3c0 [f2fs]
>     [<ffffffff81131b77>] generic_perform_write+0xc7/0x1c0
>     [<ffffffff81133b7d>] __generic_file_aio_write+0x1cd/0x3f0
>     [<ffffffff81133dfe>] generic_file_aio_write+0x5e/0xe0
>     [<ffffffff81195c5a>] do_sync_write+0x5a/0x90
>     [<ffffffff811968d2>] vfs_write+0xc2/0x1d0
>     [<ffffffff81196daf>] SyS_write+0x4f/0xb0
>     [<ffffffff816dead2>] system_call_fastpath+0x16/0x1b
>     [<ffffffffffffffff>] 0xffffffffffffffff

OK, it shows that the allocation happens via add_to_page_cache_locked()
and I guess it's page_cache_tree_insert() which calls
__radix_tree_create() (the latter reusing the preloaded node). I'm not
familiar enough to this code (radix-tree.c and filemap.c) to tell where
the node should have been freed, who keeps track of it.

At a quick look at the hex dump (assuming that the above leak is struct
radix_tree_node):

	.path = 1
	.count = -0x7f (or 0xffffff81 as unsigned int)
	union {
		{
			.parent = NULL
			.private_data = 0xffffffff81348950
		}
		{
			.rcu_head.next = NULL
			.rcu_head.func = 0xffffffff81348950
		}
	}

The count is a bit suspicious.

>From the union, it looks most likely like rcu_head information. Is
radix_tree_node_rcu_free() function at the above rcu_head.func?

Could you please send us your .config file?

Also, if you run echo scan > /sys/kernel/debug/kmemleak a few times, do
any of the above leaks disappear (in case the above are some transient
rcu freeing reports; normally this shouldn't happen as the objects are
still referred but I'll look at the relevant code once I have your
.config).

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
