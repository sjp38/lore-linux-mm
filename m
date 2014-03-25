Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 113976B003A
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:03:47 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so813279qae.5
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 10:03:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s39si10929399qgs.134.2014.03.25.10.03.46
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 10:03:47 -0700 (PDT)
Date: Tue, 25 Mar 2014 13:03:25 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: slab_common: fix the check for duplicate slab names
Message-ID: <20140325170324.GC580@redhat.com>
References: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>

[Sorry for top-post but...]

This patch still isn't upstream.  Who should be shepherding it to Linus?

Without it we're seeing crashes on Fedora when running regression tests
that use dm-raid (dm target that wraps MD raid), e.g.:

6,484484,682379136295,-;md: mdX: recovery done.
6,484485,682379145308,-;bio: create slab <bio-0> at 0
6,484486,682379147581,-;md/raid:mdX: device dm-17 operational as raid disk 4
6,484487,682379149216,-;md/raid:mdX: device dm-11 operational as raid disk 2
6,484488,682379150829,-;md/raid:mdX: device dm-20 operational as raid disk 1
6,484489,682379152369,-;md/raid:mdX: device dm-9 operational as raid disk 0
3,484490,682379153954,-;kmem_cache_sanity_check (raid6-ffff880014e8b010): Cache name already exists.
4,484491,682379155824,-;CPU: 0 PID: 11228 Comm: lvm Not tainted 3.14.0-0.rc6.git0.1.fc21.x86_64 #1
4,484492,682379157704,-;Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
4,484493,682379159298,-; 0000000000000000 00000000a0bb80c5 ffff88003428d9d8 ffffffff816edd6b
4,484494,682379161238,-; ffff880076b51700 ffff88003428da50 ffffffff811982c3 0000000000000000
4,484495,682379163199,-; 0000000000000000 0000000000000790 0000000000000000 0000000000000000
4,484496,682379165206,-;Call Trace:
4,484497,682379166523,-; [<ffffffff816edd6b>] dump_stack+0x45/0x56
4,484498,682379168098,-; [<ffffffff811982c3>] kmem_cache_create_memcg+0x143/0x3e0
4,484499,682379169854,-; [<ffffffff8119858b>] kmem_cache_create+0x2b/0x30
4,484500,682379171541,-; [<ffffffffa020fc6c>] setup_conf+0x5cc/0x810 [raid456]
4,484501,682379173264,-; [<ffffffff811771ad>] ? mempool_create_node+0xdd/0x140
4,484502,682379174988,-; [<ffffffff81176dd0>] ? mempool_alloc_slab+0x20/0x20
4,484503,682379176728,-; [<ffffffffa0210a38>] run+0x868/0xa60 [raid456]
4,484504,682379178380,-; [<ffffffff81220a3e>] ? bioset_create+0x21e/0x2e0
4,484505,682379180038,-; [<ffffffff81563d3a>] md_run+0x3fa/0x980
4,484506,682379181631,-; [<ffffffff81221778>] ? bio_put+0x78/0x90
4,484507,682379183339,-; [<ffffffff8155badd>] ? sync_page_io+0x8d/0x110
4,484508,682379185000,-; [<ffffffffa0227570>] raid_ctr+0xf30/0x1389 [dm_raid]
4,484509,682379186771,-; [<ffffffff8156f857>] dm_table_add_target+0x177/0x460
4,484510,682379188538,-; [<ffffffff81572d57>] table_load+0x157/0x380
4,484511,682379190198,-; [<ffffffff81572c00>] ? retrieve_status+0x1c0/0x1c0
4,484512,682379191925,-; [<ffffffff815739c5>] ctl_ioctl+0x255/0x500
4,484513,682379193589,-; [<ffffffff811e8b00>] ? do_sync_write+0x50/0xa0
4,484514,682379195256,-; [<ffffffff81573c83>] dm_ctl_ioctl+0x13/0x20
4,484515,682379196900,-; [<ffffffff811fc790>] do_vfs_ioctl+0x2e0/0x4a0
4,484516,682379198600,-; [<ffffffff811eb931>] ? __sb_end_write+0x31/0x60
4,484517,682379200286,-; [<ffffffff811e9392>] ? vfs_write+0x172/0x1e0
4,484518,682379201957,-; [<ffffffff811fc9f1>] SyS_ioctl+0xa1/0xc0
4,484519,682379203651,-; [<ffffffff816fe129>] system_call_fastpath+0x16/0x1b
3,484520,682379205496,-;md/raid:mdX: couldn't allocate 0kB for buffers

On Tue, Mar 04 2014 at  5:13pm -0500,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> The patch 3e374919b314f20e2a04f641ebc1093d758f66a4 is supposed to fix the
> problem where kmem_cache_create incorrectly reports duplicate cache name
> and fails. The problem is described in the header of that patch.
> 
> However, the patch doesn't really fix the problem because of these
> reasons:
> 
> * the logic to test for debugging is reversed. It was intended to perform
>   the check only if slub debugging is enabled (which implies that caches
>   with the same parameters are not merged). Therefore, there should be
>   #if !defined(CONFIG_SLUB) || defined(CONFIG_SLUB_DEBUG_ON)
>   The current code has the condition reversed and performs the test if
>   debugging is disabled.
> 
> * slub debugging may be enabled or disabled based on kernel command line,
>   CONFIG_SLUB_DEBUG_ON is just the default settings. Therefore the test
>   based on definition of CONFIG_SLUB_DEBUG_ON is unreliable.
> 
> This patch fixes the problem by removing the test
> "!defined(CONFIG_SLUB_DEBUG_ON)". Therefore, duplicate names are never
> checked if the SLUB allocator is used.
> 
> Note to stable kernel maintainers: when backporint this patch, please
> backport also the patch 3e374919b314f20e2a04f641ebc1093d758f66a4.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Cc: stable@vger.kernel.org	# 3.6+
> 
> ---
>  mm/slab_common.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-3.14-rc5/mm/slab_common.c
> ===================================================================
> --- linux-3.14-rc5.orig/mm/slab_common.c	2014-03-04 22:47:02.000000000 +0100
> +++ linux-3.14-rc5/mm/slab_common.c	2014-03-04 22:47:08.000000000 +0100
> @@ -56,7 +56,7 @@ static int kmem_cache_sanity_check(struc
>  			continue;
>  		}
>  
> -#if !defined(CONFIG_SLUB) || !defined(CONFIG_SLUB_DEBUG_ON)
> +#if !defined(CONFIG_SLUB)
>  		/*
>  		 * For simplicity, we won't check this in the list of memcg
>  		 * caches. We have control over memcg naming, and if there
> 
> --
> dm-devel mailing list
> dm-devel@redhat.com
> https://www.redhat.com/mailman/listinfo/dm-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
