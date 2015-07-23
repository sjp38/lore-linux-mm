Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id CFDFB6B0262
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:07:01 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so79768950pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:07:01 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id uc10si9011902pac.78.2015.07.22.22.06.59
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 22:07:00 -0700 (PDT)
Date: Thu, 23 Jul 2015 14:11:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/page_owner: fix possible access violation
Message-ID: <20150723051124.GA4449@js1304-P5Q-DELUXE>
References: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150715235335.GD988@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150715235335.GD988@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 16, 2015 at 08:53:35AM +0900, Minchan Kim wrote:
> On Wed, Jul 15, 2015 at 03:33:58PM +0900, Joonsoo Kim wrote:
> > When I tested my new patches, I found that page pointer which is used
> > for setting page_owner information is changed. This is because page
> > pointer is used to set new migratetype in loop. After this work,
> > page pointer could be out of bound. If this wrong pointer is used for
> > page_owner, access violation happens. Below is error message that I got.
> > 
> > [ 6175.025217] BUG: unable to handle kernel paging request at 0000000000b00018
> > [ 6175.026400] IP: [<ffffffff81025f30>] save_stack_address+0x30/0x40
> > [ 6175.027341] PGD 1af2d067 PUD 166e0067 PMD 0
> > [ 6175.028129] Oops: 0002 [#1] SMP
> > snip...
> > [ 6175.055349] Call Trace:
> > [ 6175.055780]  [<ffffffff81018c0f>] print_context_stack+0xcf/0x100
> > [ 6175.056794]  [<ffffffff810f8552>] ? __module_text_address+0x12/0x70
> > [ 6175.057848]  [<ffffffff810177cf>] dump_trace+0x15f/0x320
> > [ 6175.058751]  [<ffffffff8106b140>] ? do_flush_tlb_all+0x50/0x50
> > [ 6175.059732]  [<ffffffff810f5529>] ? smp_call_function_single+0xb9/0x120
> > [ 6175.060856]  [<ffffffff81025e3f>] save_stack_trace+0x2f/0x50
> > [ 6175.061812]  [<ffffffff811e3366>] __set_page_owner+0x46/0x70
> > [ 6175.062774]  [<ffffffff8117bd47>] __isolate_free_page+0x1f7/0x210
> > [ 6175.063804]  [<ffffffff8117bd81>] split_free_page+0x21/0xb0
> > [ 6175.064757]  [<ffffffff8119aa82>] isolate_freepages_block+0x1e2/0x410
> > [ 6175.065855]  [<ffffffff8119b53d>] compaction_alloc+0x22d/0x2d0
> > [ 6175.066850]  [<ffffffff811d3779>] migrate_pages+0x289/0x8b0
> > [ 6175.067798]  [<ffffffff8119c16a>] ? isolate_migratepages_block+0x28a/0x6e0
> > [ 6175.068960]  [<ffffffff8119a000>] ? kmalloc_slab+0xa0/0xa0
> > [ 6175.069892]  [<ffffffff8119b310>] ? ftrace_raw_event_mm_compaction_deplete_template+0xc0/0xc0
> > [ 6175.071327]  [<ffffffff8119ce49>] compact_zone+0x409/0x880
> > [ 6175.072261]  [<ffffffff8119d32d>] compact_zone_order+0x6d/0x90
> > [ 6175.073250]  [<ffffffff8119d5d0>] try_to_compact_pages+0x110/0x210
> > [ 6175.074297]  [<ffffffff8176e9e8>] __alloc_pages_direct_compact+0x3d/0xe6
> > [ 6175.075427]  [<ffffffff8117d42d>] __alloc_pages_nodemask+0x6cd/0x9a0
> > [ 6175.076517]  [<ffffffff811c2bf1>] alloc_pages_current+0x91/0x100
> > [ 6175.077545]  [<ffffffff811e7216>] runtest_store+0x296/0xa50
> > [ 6175.078497]  [<ffffffff813a553c>] ? simple_strtoull+0x2c/0x50
> > [ 6175.079465]  [<ffffffff812130bd>] simple_attr_write+0xbd/0xe0
> > [ 6175.080458]  [<ffffffff811eb038>] __vfs_write+0x28/0xf0
> > [ 6175.081349]  [<ffffffff811edc39>] ? __sb_start_write+0x49/0xf0
> > [ 6175.082345]  [<ffffffff8130fe25>] ? security_file_permission+0x45/0xd0
> > [ 6175.083453]  [<ffffffff811eb729>] vfs_write+0xa9/0x1b0
> > [ 6175.084334]  [<ffffffff811ec4f6>] SyS_write+0x46/0xb0
> > [ 6175.085196]  [<ffffffff81172803>] ? context_tracking_user_enter+0x13/0x20
> > [ 6175.086339]  [<ffffffff81024c55>] ? syscall_trace_leave+0xa5/0x120
> > [ 6175.087389]  [<ffffffff81779472>] system_call_fastpath+0x16/0x75
> > 
> > This patch fixes this error by moving up set_page_owner().
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> -stable material?

Hello,

Strangely, I didn't hit the error on the kernel without some of my
patches. But, yes, it seems stable candidate.

This patch is already merged in the mainline so I will send it to
stable tree soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
