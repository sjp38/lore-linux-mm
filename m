Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDF36B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 13:28:28 -0400 (EDT)
Received: by wetk59 with SMTP id k59so13118625wet.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:28:27 -0700 (PDT)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id hl10si4423093wib.6.2015.03.17.10.28.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 10:28:26 -0700 (PDT)
Received: by wetk59 with SMTP id k59so13118110wet.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:28:26 -0700 (PDT)
Date: Tue, 17 Mar 2015 18:28:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID: 1 at
 drivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
Message-ID: <20150317172823.GA25494@dhcp22.suse.cz>
References: <1426227621.6711.238.camel@intel.com>
 <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, LKP ML <lkp@01.org>, linux-mm <linux-mm@kvack.org>, Theodore Ts'o <tytso@mit.edu>

[CCing Ted]

On Tue 17-03-15 10:15:29, Linus Torvalds wrote:
> Explicitly adding the emails of other people involved with that commit
> and the original oom thread to make sure people are aware, since this
> didn't get any response.
> 
> Commit cc87317726f8 fixed some behavior,

Yes, it was ext4 remounting RO because of the allocation failures AFAIR.
I am not sure those were addressed in the meantime. Ted?

> but also seems to have turned an oom situation into a complete
> hang. So presumably we shouldn't loop *forever*. Hmm?

I am definitely for the failure for GFP_NOFS allocations. It is weird to
loop inside the allocator without any way out because even OOM killer as
the last resort is not used. The primary force for the revert was that
the change came in very late in the release cycle. I guess we should go
with revert of cc87317726f8 for 4.1.

> 
> Comments?
> 
>                            Linus
> 
> On Thu, Mar 12, 2015 at 11:20 PM, Huang Ying <ying.huang@intel.com> wrote:
> > FYI, we noticed the below changes on
> >
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > commit cc87317726f851531ae8422e0c2d3d6e2d7b1955 ("mm: page_alloc: revert inadvertent !__GFP_FS retry behavior change")
> >
> > Before the commit, the page allocation failure is as follow (in prev_dmesg).
> >
> > [    3.069031] BTRFS: selftest: Running space stealing from bitmap to extent
> > [    3.070243] BTRFS: selftest: Free space cache tests finished
> > [    3.070919] BTRFS: selftest: Running extent buffer operation tests
> > [    3.072111] BTRFS: selftest: Running btrfs_split_item tests
> > [    3.072840] BTRFS: selftest: Running find delalloc tests
> > [    3.295788] swapper/0: page allocation failure: order:0, mode:0x50
> > [    3.296315] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W       4.0.0-rc1-00038-g39afb5e #4
> > [    3.297033] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [    3.297490]  00000000 00000000 4002bdd4 4158716c 00000001 4002bdfc 410c64f1 41719e60
> > [    3.298218]  4001b304 00000000 00000050 4002bdf8 4158da0d 00000000 00000000 4002be80
> > [    3.298929]  410c8331 00000050 00000000 00000000 00000001 00000050 4001b000 00000040
> > [    3.299644] Call Trace:
> > [    3.299859]  [<4158716c>] dump_stack+0x48/0x60
> > [    3.300235]  [<410c64f1>] warn_alloc_failed+0xa1/0xe0
> > [    3.300640]  [<4158da0d>] ? _raw_spin_unlock+0x1d/0x30
> > [    3.301070]  [<410c8331>] __alloc_pages_nodemask+0x4d1/0x810
> > [    3.301517]  [<410c04e3>] pagecache_get_page+0xf3/0x1c0
> > [    3.301957]  [<4124ccf7>] btrfs_test_extent_io+0x67/0x660
> > [    3.302401]  [<4124c5cb>] ? btrfs_test_extent_buffer_operations+0x54b/0x6c0
> > [    3.302966]  [<4184109b>] ? debugfs_init+0x4e/0x4e
> > [    3.303360]  [<41841192>] init_btrfs_fs+0xf7/0x172
> > [    3.303750]  [<41000472>] do_one_initcall+0xc2/0x1c0
> > [    3.304155]  [<41829462>] ? repair_env_string+0x12/0x54
> > [    3.304566]  [<41829400>] ? do_early_param+0x23/0x73
> > [    3.304971]  [<4104ca99>] ? parse_args+0x249/0x4e0
> > [    3.305364]  [<41829450>] ? do_early_param+0x73/0x73
> > [    3.305767]  [<41829bce>] kernel_init_freeable+0xe3/0x160
> > [    3.306204]  [<41829bce>] ? kernel_init_freeable+0xe3/0x160
> > [    3.306632]  [<41582b78>] kernel_init+0x8/0xc0
> > [    3.307022]  [<4158e281>] ret_from_kernel_thread+0x21/0x30
> > [    3.307455]  [<41582b70>] ? rest_init+0xb0/0xb0
> > [    3.307826] Mem-Info:
> > [    3.308024] Normal per-cpu:
> > [    3.308251] CPU    0: hi:   90, btch:  15 usd:  82
> > [    3.308630] CPU    1: hi:   90, btch:  15 usd:   2
> > [    3.309026] active_anon:0 inactive_anon:0 isolated_anon:0
> > [    3.309026]  active_file:873 inactive_file:62554 isolated_file:0
> > [    3.309026]  unevictable:9425 dirty:0 writeback:0 unstable:0
> > [    3.309026]  free:539 slab_reclaimable:0 slab_unreclaimable:0
> > [    3.309026]  mapped:0 shmem:0 pagetables:0 bounce:0
> > [    3.309026]  free_cma:0
> >
> >
> > After the commit, the system hang at the same position (in .dmesg).
> >
> > [    3.303002] BTRFS: selftest: Running btrfs free space cache tests
> > [    3.303636] BTRFS: selftest: Running extent only tests
> > [    3.304190] BTRFS: selftest: Running bitmap only tests
> > [    3.304726] BTRFS: selftest: Running bitmap and extent tests
> > [    3.305346] BTRFS: selftest: Running space stealing from bitmap to extent
> > [    3.306318] BTRFS: selftest: Free space cache tests finished
> > [    3.306881] BTRFS: selftest: Running extent buffer operation tests
> > [    3.307483] BTRFS: selftest: Running btrfs_split_item tests
> > [    3.308134] BTRFS: selftest: Running find delalloc tests
> >
> > BUG: kernel boot hang
> > Elapsed time: 305
> >
> >
> > Thanks,
> > Ying Huang
> >
> >
> > _______________________________________________
> > LKP mailing list
> > LKP@linux.intel.com
> >
> >

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
