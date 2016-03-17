Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 357E56B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 03:10:44 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id x3so108356768pfb.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 00:10:44 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id ta4si1974963pac.193.2016.03.17.00.10.42
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 00:10:43 -0700 (PDT)
Date: Thu, 17 Mar 2016 16:11:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160317071155.GB10315@js1304-P5Q-DELUXE>
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
 <56E82B18.9040807@nod.at>
 <20160315153744.GB28522@infradead.org>
 <56E8985A.1020509@nod.at>
 <20160316142156.GA23595@node.shutemov.name>
 <20160316142729.GA125481@black.fi.intel.com>
 <56E9C658.1020903@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E9C658.1020903@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, Alexander Kaplan <alex@nextthing.co>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, rvaswani@codeaurora.org, "Luck, Tony" <tony.luck@intel.com>, Shailendra Verma <shailendra.capricorn@gmail.com>, s.strogin@partner.samsung.com

On Wed, Mar 16, 2016 at 09:47:20PM +0100, Richard Weinberger wrote:
> Adding more CC's.
> 
> Am 16.03.2016 um 15:27 schrieb Kirill A. Shutemov:
> > On Wed, Mar 16, 2016 at 05:21:56PM +0300, Kirill A. Shutemov wrote:
> >> On Wed, Mar 16, 2016 at 12:18:50AM +0100, Richard Weinberger wrote:
> >>> Am 15.03.2016 um 16:37 schrieb Christoph Hellwig:
> >>>> On Tue, Mar 15, 2016 at 04:32:40PM +0100, Richard Weinberger wrote:
> >>>>>> Or if ->page_mkwrite() was called, why the page is not dirty?
> >>>>>
> >>>>> BTW: UBIFS does not implement ->migratepage(), could this be a problem?
> >>>>
> >>>> This might be the reason.  I can't reall make sense of
> >>>> buffer_migrate_page, but it seems to migrate buffer_head state to
> >>>> the new page.
> >>>>
> >>>> I'd love to know why CMA even tries to migrate pages that don't have a
> >>>> ->migratepage method, this seems incredibly dangerous to me.
> >>>
> >>> FYI, with a dummy ->migratepage() which returns only -EINVAL UBIFS does no
> >>> longer explode upon page migration.
> >>> Tomorrow I'll do more tests to make sure.
> >>
> >> Could you check if something like this would fix the issue.
> 
> Nope.
> 
> [  108.080000] BUG: Bad page state in process drm-stress-test  pfn:5c674
> [  108.080000] page:deb8ce80 count:0 mapcount:0 mapping:  (null) index:0x0
> [  108.090000] flags: 0x810(dirty|private)
> [  108.100000] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> [  108.100000] bad because of flags:
> [  108.110000] flags: 0x800(private)
> [  108.110000] Modules linked in:
> [  108.120000] CPU: 0 PID: 1855 Comm: drm-stress-test Not tainted 4.4.4-gaae1ad1-dirty #14
> [  108.120000] Hardware name: Allwinner sun4i/sun5i Families
> [  108.120000] [<c0015eb4>] (unwind_backtrace) from [<c0012cec>] (show_stack+0x10/0x14)
> [  108.120000] [<c0012cec>] (show_stack) from [<c02abaf8>] (dump_stack+0x8c/0xa0)
> [  108.120000] [<c02abaf8>] (dump_stack) from [<c00cbe78>] (bad_page+0xcc/0x11c)
> [  108.120000] [<c00cbe78>] (bad_page) from [<c00cc0f4>] (free_pages_prepare+0x22c/0x2f4)
> [  108.120000] [<c00cc0f4>] (free_pages_prepare) from [<c00cdf2c>] (free_hot_cold_page+0x34/0x194)
> [  108.120000] [<c00cdf2c>] (free_hot_cold_page) from [<c00ce0d4>] (free_hot_cold_page_list+0x48/0xdc)
> [  108.120000] [<c00ce0d4>] (free_hot_cold_page_list) from [<c00d55a8>] (release_pages+0x1dc/0x224)
> [  108.120000] [<c00d55a8>] (release_pages) from [<c00d56d8>] (pagevec_lru_move_fn+0xe8/0xf8)
> [  108.120000] [<c00d56d8>] (pagevec_lru_move_fn) from [<c00d579c>] (__lru_cache_add+0x60/0x88)
> [  108.120000] [<c00d579c>] (__lru_cache_add) from [<c00d9578>] (putback_lru_page+0x68/0xbc)
> [  108.120000] [<c00d9578>] (putback_lru_page) from [<c010bd6c>] (migrate_pages+0x208/0x730)
> [  108.120000] [<c010bd6c>] (migrate_pages) from [<c00d0860>] (alloc_contig_range+0x168/0x2f4)
> [  108.120000] [<c00d0860>] (alloc_contig_range) from [<c010cdb4>] (cma_alloc+0x170/0x2c0)
> [  108.120000] [<c010cdb4>] (cma_alloc) from [<c001a9d4>] (__alloc_from_contiguous+0x38/0xd8)
> [  108.120000] [<c001a9d4>] (__alloc_from_contiguous) from [<c001adb8>] (__dma_alloc+0x234/0x278)
> [  108.120000] [<c001adb8>] (__dma_alloc) from [<c001ae8c>] (arm_dma_alloc+0x54/0x5c)
> [  108.120000] [<c001ae8c>] (arm_dma_alloc) from [<c035bd70>] (drm_gem_cma_create+0x9c/0xf0)
> [  108.120000] [<c035bd70>] (drm_gem_cma_create) from [<c035bde0>] (drm_gem_cma_create_with_handle+0x1c/0xe8)
> [  108.120000] [<c035bde0>] (drm_gem_cma_create_with_handle) from [<c035bf48>] (drm_gem_cma_dumb_create+0x3c/0x48)
> [  108.120000] [<c035bf48>] (drm_gem_cma_dumb_create) from [<c0340d18>] (drm_ioctl+0x12c/0x440)
> [  108.120000] [<c0340d18>] (drm_ioctl) from [<c011fc7c>] (do_vfs_ioctl+0x3f4/0x614)
> [  108.120000] [<c011fc7c>] (do_vfs_ioctl) from [<c011fed0>] (SyS_ioctl+0x34/0x5c)
> [  108.120000] [<c011fed0>] (SyS_ioctl) from [<c000f2c0>] (ret_fast_syscall+0x0/0x34)
> 
> It is still not clear why UBIFS has to provide a >migratepage() and what the expected semantics
> are.
> What we know so far is that the fall back migration function is broken. I'm sure not only on UBIFS.
> 
> Can CMA folks please clarify? :-)

Hello,

As you mentioned earlier, this issue would not be directly related
to CMA. It looks like it is more general issue related to interaction
between MM and FS. Your first error log shows that error happens when
ubifs_set_page_dirty() is called in try_to_unmap_one() which also
can be called by reclaimer (kswapd or direct reclaim). Quick search shows
that problem also happens on reclaim. Is that fixed?

http://www.spinics.net/lists/linux-fsdevel/msg79531.html

I think that you need to CC other people who understand interaction
between MM and FS perfectly.

Sorry about not much helpful here.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
