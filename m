Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id AC6EB6B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 17:50:57 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so965497pbb.35
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 14:50:57 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id x3si30680347pbk.53.2014.02.05.14.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 14:50:56 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so543238pdb.38
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 14:50:56 -0800 (PST)
Date: Wed, 5 Feb 2014 14:50:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: BUG in do_huge_pmd_wp_page
In-Reply-To: <52F27F1C.10601@oracle.com>
Message-ID: <alpine.LSU.2.11.1402051416220.4008@eggly.anvils>
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop> <5166CEDD.9050301@oracle.com> <20130411151323.89D40E0085@blue.fi.intel.com> <5166D355.2060103@oracle.com> <20130424154607.60e9b9895539eb5668d2f505@linux-foundation.org>
 <5179CF8F.7000702@oracle.com> <20130426020101.GA21162@redhat.com> <52F05827.1040401@oracle.com> <alpine.LSU.2.11.1402031949450.29601@eggly.anvils> <52F27F1C.10601@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 5 Feb 2014, Sasha Levin wrote:
> On 02/03/2014 10:59 PM, Hugh Dickins wrote:
> > On Mon, 3 Feb 2014, Sasha Levin wrote:
> > > 
> > > [  762.701278] BUG: unable to handle kernel paging request at
> > > ffff88009eae6000
> > > [  762.702462] IP: [<ffffffff81ae8455>] copy_page_rep+0x5/0x10
> > > [  762.710135] Call Trace:
> > > [  762.710135]  [<ffffffff81298995>] ? copy_user_huge_page+0x1a5/0x210
> > > [  762.710135]  [<ffffffff812d7260>] do_huge_pmd_wp_page+0x3d0/0x650
> > > [  762.710135]  [<ffffffff811a308e>] ? put_lock_stats+0xe/0x30
> > > [  762.710135]  [<ffffffff8129b511>] __handle_mm_fault+0x2b1/0x3d0
> > > [  762.710135]  [<ffffffff8129b763>] handle_mm_fault+0x133/0x1c0
> > > [  762.710135]  [<ffffffff8129bcf8>] __get_user_pages+0x438/0x630
> > > [  762.710135]  [<ffffffff811a308e>] ? put_lock_stats+0xe/0x30
> > > [  762.710135]  [<ffffffff8129cfc4>] __mlock_vma_pages_range+0xd4/0xe0
> > > [  762.710135]  [<ffffffff8129d0e0>] __mm_populate+0x110/0x190
> > > [  762.710135]  [<ffffffff8129dcd0>] SyS_mlockall+0x160/0x1b0
> > > [  762.710135]  [<ffffffff84450650>] tracesys+0xdd/0xe2
> > 
> > Here's what I suggested about that one in eecc1e426d68
> > "thp: fix copy_page_rep GPF by testing is_huge_zero_pmd once only":
> > Note: this is not the same issue as trinity's DEBUG_PAGEALLOC BUG
> > in copy_page_rep with RSI: ffff88009c422000, reported by Sasha Levin
> > in https://lkml.org/lkml/2013/3/29/103.  I believe that one is due
> > to the source page being split, and a tail page freed, while copy
> > is in progress; and not a problem without DEBUG_PAGEALLOC, since
> > the pmd_same check will prevent a miscopy from being made visible.
> > 
> > It could be fixed by additional locking, or by taking an additional
> > reference on every tail page, in the DEBUG_PAGEALLOC case (we wouldn't
> > want to add to the overhead in the normal case).  I didn't feel very
> > motivated to uglify the code in that way just for DEBUG_PAGEALLOC and
> > trinity: if it only comes up once in seven months, I'm inclined to
> > live with it myself, but you may have a different perspective.
> 
> Either something changed in the kernel or in trinity, but I'm now hitting it
> 3-4 times a day.
> 
> I've been trying to look at the code to understand the issue you've
> described, but I can't pinpoint the exact location where that happen.
> 
> Could you please point me to the relevant code sections?

I'm not sure which part of it is unclear.

copy_page_rep (arch/x86/lib/copy_page_64.S) is what copy_user_huge_page
(mm/memory.c) ends up calling, when it's invoked from do_huge_pmd_wp_page
(mm/huge_memory.c).  At this point we hold down_read of this mm's mmap_sem,
and a get_page on the head of the THP; but we don't have down_write or
page_table_lock or compound_lock or anon_vma lock, some of which might
prevent concurrent THP splitting (I say "some" and "might" because I've
not gone back to check precisely which are actually relevant here: THP
locking rules are not the simplest...).

Do you accept that the THP might be split while we're copying?  And if
that happens, then, for example, there might be a WP fault from another
thread to one of the 4k pages it gets split into, which results in that
particular 4k page being freed after it's been copied (I'm thinking its
refcount demands that it be copied at the time of the fault, but then
the additional ref gets freed - a fork proceeds to exec and frees it,
for example).

When the page is freed, free_pages_prepare (mm/page_alloc.c) calls
kernel_map_pages (arch/x86/mm/pageattr.c if CONFIG_DEBUG_PAGEALLOC) to
unmap the freed page from kernel virtual address space (__set_pages_np).
Hence "unable to handle kernel paging request" when copy_page_rep
reaches that part of what used to be the THP.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
