Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D337F6B0253
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 21:00:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id te7so24618944pab.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 18:00:58 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id t12si3772041pfj.44.2016.06.02.18.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 18:00:57 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id gp3so4471445pac.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 18:00:57 -0700 (PDT)
Date: Fri, 3 Jun 2016 10:00:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603010036.GA464@swordfish>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
 <20160602185856.GA3854@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602185856.GA3854@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, sergey.senozhatsky.work@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org

On (06/02/16 21:58), Ebru Akagunduz wrote:
[..]
> > I think it's this patch:
> > 
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem.patch
> > 
> > Some parts of the code in collapse_huge_page() that were under
> > down_write(mmap_sem) are under down_read() after the patch. But
> > there's "goto out" which continues via "goto out_up_write" which
> > does up_write(mmap_sem) so there's an imbalance. One path seems to
> > go via both up_read() and up_write(). I can imagine this can cause a
> > stuck down_write() among other things?
> Recently, I realized the same imbalance, it is an obvious
> inconsistency. I don't know, this issue can be related with
> mine. I'll send a fix patch.

a good find by Vlastimil.

Ebru, can you also re-visit __collapse_huge_page_swapin()? it's called
from collapse_huge_page() under the down_read(&mm->mmap_sem), is there
any reason to do the nested down_read(&mm->mmap_sem)?

collapse_huge_page()
...
	down_read(&mm->mmap_sem);
	result = hugepage_vma_revalidate(mm, vma, address);
	if (result)
		goto out;

	pmd = mm_find_pmd(mm, address);
	if (!pmd) {
		result = SCAN_PMD_NULL;
		goto out;
	}

	if (allocstall == curr_allocstall && swap != 0) {
		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
			{
			:	if (ret & VM_FAULT_RETRY) {
			:		down_read(&mm->mmap_sem);
			:		^^^^^^^^^
			:		if (hugepage_vma_revalidate(mm, vma, address))
			:			return false;
			:	}
			}

			up_read(&mm->mmap_sem);
			goto out;
		}
	}

	up_read(&mm->mmap_sem);



so if __collapse_huge_page_swapin() retruns true we have:
	- down_read() twice, up_read() once?

the locking rules here are a bit confusing. (I didn't have my morning coffee yet).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
