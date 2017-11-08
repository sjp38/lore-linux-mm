Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2126B02F6
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 09:21:11 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p96so1434058wrb.12
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 06:21:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f51si3573741edf.124.2017.11.08.06.21.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 06:21:09 -0800 (PST)
Date: Wed, 8 Nov 2017 15:21:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: page_ext: check if page_ext is not prepared
Message-ID: <20171108142106.v76ictdykeqjzhhh@dhcp22.suse.cz>
References: <CGME20171107093947epcas2p3d449dd14d11907cd29df7be7984d90f0@epcas2p3.samsung.com>
 <20171107094131.14621-1-jaewon31.kim@samsung.com>
 <20171107094730.5732nqqltx2miszq@dhcp22.suse.cz>
 <20171108075956.GC18747@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108075956.GC18747@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, akpm@linux-foundation.org, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Wed 08-11-17 16:59:56, Joonsoo Kim wrote:
> On Tue, Nov 07, 2017 at 10:47:30AM +0100, Michal Hocko wrote:
> > [CC Joonsoo]
> > 
> > On Tue 07-11-17 18:41:31, Jaewon Kim wrote:
> > > online_page_ext and page_ext_init allocate page_ext for each section, but
> > > they do not allocate if the first PFN is !pfn_present(pfn) or
> > > !pfn_valid(pfn). Then section->page_ext remains as NULL. lookup_page_ext
> > > checks NULL only if CONFIG_DEBUG_VM is enabled. For a valid PFN,
> > > __set_page_owner will try to get page_ext through lookup_page_ext.
> > > Without CONFIG_DEBUG_VM lookup_page_ext will misuse NULL pointer as value
> > > 0. This incurrs invalid address access.
> > > 
> > > This is the panic example when PFN 0x100000 is not valid but PFN 0x13FC00
> > > is being used for page_ext. section->page_ext is NULL, get_entry returned
> > > invalid page_ext address as 0x1DFA000 for a PFN 0x13FC00.
> > > 
> > > To avoid this panic, CONFIG_DEBUG_VM should be removed so that page_ext
> > > will be checked at all times.
> > > 
> > > <1>[   11.618085] Unable to handle kernel paging request at virtual address 01dfa014
> > > <1>[   11.618140] pgd = ffffffc0c6dc9000
> > > <1>[   11.618174] [01dfa014] *pgd=0000000000000000, *pud=0000000000000000
> > > <4>[   11.618240] ------------[ cut here ]------------
> > > <2>[   11.618278] Kernel BUG at ffffff80082371e0 [verbose debug info unavailable]
> > > <0>[   11.618338] Internal error: Oops: 96000045 [#1] PREEMPT SMP
> > > <4>[   11.618381] Modules linked in:
> > > <4>[   11.618524] task: ffffffc0c6ec9180 task.stack: ffffffc0c6f40000
> > > <4>[   11.618569] PC is at __set_page_owner+0x48/0x78
> > > <4>[   11.618607] LR is at __set_page_owner+0x44/0x78
> > > <4>[   11.626025] [<ffffff80082371e0>] __set_page_owner+0x48/0x78
> > > <4>[   11.626071] [<ffffff80081df9f0>] get_page_from_freelist+0x880/0x8e8
> > > <4>[   11.626118] [<ffffff80081e00a4>] __alloc_pages_nodemask+0x14c/0xc48
> > > <4>[   11.626165] [<ffffff80081e610c>] __do_page_cache_readahead+0xdc/0x264
> > > <4>[   11.626214] [<ffffff80081d8824>] filemap_fault+0x2ac/0x550
> > > <4>[   11.626259] [<ffffff80082e5cf8>] ext4_filemap_fault+0x3c/0x58
> > > <4>[   11.626305] [<ffffff800820a2f8>] __do_fault+0x80/0x120
> > > <4>[   11.626347] [<ffffff800820eb4c>] handle_mm_fault+0x704/0xbb0
> > > <4>[   11.626393] [<ffffff800809ba70>] do_page_fault+0x2e8/0x394
> > > <4>[   11.626437] [<ffffff8008080be4>] do_mem_abort+0x88/0x124
> > > 
> > 
> > I suspec this goes all the way down to when page_ext has been
> > resurrected.  It is quite interesting that nobody has noticed this in 3
> > years but maybe the feature is not used all that much and the HW has to
> > be quite special to trigger. Anyway the following should be added
> > 
> >  Fixes: eefa864b701d ("mm/page_ext: resurrect struct page extending code for debugging")
> >  Cc: stable
> 
> IIRC, caller of lookup_page_ext() doesn't check 'NULL' until
> f86e427197 ("mm: check the return value of lookup_page_ext for all
> call sites"). So, this problem would happen old kernel even if this
> patch is applied to old kernel.

OK, then the changelog should mention dependency on that check so that
anybody who backports this patch to pre 4.7 kernels knows to pull that
one as well.

> IMO, proper fix is to check all the pfn in the section. It is sent
> from Jaewon in other mail.

I believe that this patch is valuable on its own and the other one
should build on top of it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
