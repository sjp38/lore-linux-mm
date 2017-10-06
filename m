Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD596B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 05:27:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p46so14655209wrb.1
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 02:27:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a12sor754100edm.23.2017.10.06.02.27.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 02:27:41 -0700 (PDT)
Date: Fri, 6 Oct 2017 12:27:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: page_vma_mapped: Ensure pmd is loaded with READ_ONCE
 outside of lock
Message-ID: <20171006092739.zczk5ljzi4cguv6p@node.shutemov.name>
References: <1507222630-5839-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507222630-5839-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org

On Thu, Oct 05, 2017 at 05:57:10PM +0100, Will Deacon wrote:
> Loading the pmd without holding the pmd_lock exposes us to races with
> concurrent updaters of the page tables but, worse still, it also allows
> the compiler to cache the pmd value in a register and reuse it later on,
> even if we've performed a READ_ONCE in between and seen a more recent
> value.
> 
> In the case of page_vma_mapped_walk, this leads to the following crash
> when the pmd loaded for the initial pmd_trans_huge check is all zeroes
> and a subsequent valid table entry is loaded by check_pmd. We then
> proceed into map_pte, but the compiler re-uses the zero entry inside
> pte_offset_map, resulting in a junk pointer being installed in pvmw->pte:
> 
> [  254.032812] PC is at check_pte+0x20/0x170
> [  254.032948] LR is at page_vma_mapped_walk+0x2e0/0x540
> [...]
> [  254.036114] Process doio (pid: 2463, stack limit = 0xffff00000f2e8000)
> [  254.036361] Call trace:
> [  254.038977] [<ffff000008233328>] check_pte+0x20/0x170
> [  254.039137] [<ffff000008233758>] page_vma_mapped_walk+0x2e0/0x540
> [  254.039332] [<ffff000008234adc>] page_mkclean_one+0xac/0x278
> [  254.039489] [<ffff000008234d98>] rmap_walk_file+0xf0/0x238
> [  254.039642] [<ffff000008236e74>] rmap_walk+0x64/0xa0
> [  254.039784] [<ffff0000082370c8>] page_mkclean+0x90/0xa8
> [  254.040029] [<ffff0000081f3c64>] clear_page_dirty_for_io+0x84/0x2a8
> [  254.040311] [<ffff00000832f984>] mpage_submit_page+0x34/0x98
> [  254.040518] [<ffff00000832fb4c>] mpage_process_page_bufs+0x164/0x170
> [  254.040743] [<ffff00000832fc8c>] mpage_prepare_extent_to_map+0x134/0x2b8
> [  254.040969] [<ffff00000833530c>] ext4_writepages+0x484/0xe30
> [  254.041175] [<ffff0000081f6ab4>] do_writepages+0x44/0xe8
> [  254.041372] [<ffff0000081e5bd4>] __filemap_fdatawrite_range+0xbc/0x110
> [  254.041568] [<ffff0000081e5e68>] file_write_and_wait_range+0x48/0xd8
> [  254.041739] [<ffff000008324310>] ext4_sync_file+0x80/0x4b8
> [  254.041907] [<ffff0000082bd434>] vfs_fsync_range+0x64/0xc0
> [  254.042106] [<ffff0000082332b4>] SyS_msync+0x194/0x1e8
> 
> This patch fixes the problem by ensuring that READ_ONCE is used before
> the initial checks on the pmd, and this value is subsequently used when
> checking whether or not the pmd is present. pmd_check is removed and the
> pmd_present check is inlined directly.
> 
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: <stable@vger.kernel.org>
> Fixes: f27176cfc363 ("mm: convert page_mkclean_one() to use page_vma_mapped_walk()")
> Tested-by: Yury Norov <ynorov@caviumnetworks.com>
> Tested-by: Richard Ruigrok <rruigrok@codeaurora.org>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
