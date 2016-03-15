Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id EAF056B0262
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:17:30 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id l68so149737330wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:17:30 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id yz5si19732005wjc.113.2016.03.15.08.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 08:17:29 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id l68so155029535wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:17:29 -0700 (PDT)
Date: Tue, 15 Mar 2016 18:17:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160315151727.GA16462@node.shutemov.name>
References: <56E8192B.5030008@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E8192B.5030008@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Kaplan <alex@nextthing.co>

On Tue, Mar 15, 2016 at 03:16:11PM +0100, Richard Weinberger wrote:
> Hi!
> 
> We're facing this issue from 2014 on UBIFS:
> http://www.spinics.net/lists/linux-fsdevel/msg79941.html
> 
> So sum up:
> UBIFS does not allow pages directly marked as dirty. It want's everyone to do it via UBIFS's
> ->wirte_end() and ->page_mkwirte() functions.
> This assumption *seems* to be violated by CMA which migrates pages.

I don't thing the CMA/migration is the root cause.

How did we end up with writable and dirty pte, but not having
->page_mkwrite() called for the page?

Or if ->page_mkwrite() was called, why the page is not dirty?


> UBIFS enforces this because it has to account free space on the flash,
> in UBIFS speak "budget", for details please see fs/ubifs/file.c.
> 
> As in the report from 2014 the page is writable but not dirty.
> The kernel has this debug patch applied:
> http://www.spinics.net/lists/linux-fsdevel/msg80471.html
> But our kernel is based on v4.4 and does *not* use proprietary modules.
> 
> [  213.450000] page:debe03c0 count:3 mapcount:1 mapping:dce4b5fc index:0x2f
> [  213.460000] flags: 0x9(locked|uptodate)
> [  213.460000] page dumped because: try_to_unmap_one
> [  213.470000] pte_write: 1
> [  213.480000] UBIFS assert failed in ubifs_set_page_dirty at 1451 (pid 436)
> [  213.490000] CPU: 0 PID: 436 Comm: drm-stress-test Not tainted 4.4.4-00176-geaa802524636-dirty #1008
> [  213.490000] Hardware name: Allwinner sun4i/sun5i Families
> [  213.490000] [<c0015e70>] (unwind_backtrace) from [<c0012cdc>] (show_stack+0x10/0x14)
> [  213.490000] [<c0012cdc>] (show_stack) from [<c02ad834>] (dump_stack+0x8c/0xa0)
> [  213.490000] [<c02ad834>] (dump_stack) from [<c0236ee8>] (ubifs_set_page_dirty+0x44/0x50)
> [  213.490000] [<c0236ee8>] (ubifs_set_page_dirty) from [<c00fa0bc>] (try_to_unmap_one+0x10c/0x3a8)
> [  213.490000] [<c00fa0bc>] (try_to_unmap_one) from [<c00fadb4>] (rmap_walk+0xb4/0x290)
> [  213.490000] [<c00fadb4>] (rmap_walk) from [<c00fb1bc>] (try_to_unmap+0x64/0x80)
> [  213.490000] [<c00fb1bc>] (try_to_unmap) from [<c010dc28>] (migrate_pages+0x328/0x7a0)
> [  213.490000] [<c010dc28>] (migrate_pages) from [<c00d0cb0>] (alloc_contig_range+0x168/0x2f4)
> [  213.490000] [<c00d0cb0>] (alloc_contig_range) from [<c010ec00>] (cma_alloc+0x170/0x2c0)
> [  213.490000] [<c010ec00>] (cma_alloc) from [<c001a958>] (__alloc_from_contiguous+0x38/0xd8)
> [  213.490000] [<c001a958>] (__alloc_from_contiguous) from [<c001ad44>] (__dma_alloc+0x23c/0x274)
> [  213.490000] [<c001ad44>] (__dma_alloc) from [<c001ae08>] (arm_dma_alloc+0x54/0x5c)
> [  213.490000] [<c001ae08>] (arm_dma_alloc) from [<c035cecc>] (drm_gem_cma_create+0xb8/0xf0)
> [  213.490000] [<c035cecc>] (drm_gem_cma_create) from [<c035cf20>] (drm_gem_cma_create_with_handle+0x1c/0xe8)
> [  213.490000] [<c035cf20>] (drm_gem_cma_create_with_handle) from [<c035d088>] (drm_gem_cma_dumb_create+0x3c/0x48)
> [  213.490000] [<c035d088>] (drm_gem_cma_dumb_create) from [<c0341ed8>] (drm_ioctl+0x12c/0x444)
> [  213.490000] [<c0341ed8>] (drm_ioctl) from [<c0121adc>] (do_vfs_ioctl+0x3f4/0x614)
> [  213.490000] [<c0121adc>] (do_vfs_ioctl) from [<c0121d30>] (SyS_ioctl+0x34/0x5c)
> [  213.490000] [<c0121d30>] (SyS_ioctl) from [<c000f2c0>] (ret_fast_syscall+0x0/0x34)
> 
> The full kernellog can be found here:
> http://code.bulix.org/ysuo9x-93716?raw
> 
> So, let me repeat Artem's question from 2014:
> > Now the question is: is it UBIFS which has incorrect assumptions, or this is the
> > Linux MM which is not doing the right thing? I do not know the answer, let's see
> > if the MM list may give us a clue.
> 
> Thanks,
> //richard
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
