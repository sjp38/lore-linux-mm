Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77E9C828E5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 23:51:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fg1so37749982pad.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 20:51:15 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id v81si5133046pfi.110.2016.06.08.20.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 20:51:11 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id fg1so1772822pad.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 20:51:10 -0700 (PDT)
Date: Thu, 9 Jun 2016 12:51:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm, thp: fix locking inconsistency in collapse_huge_page
Message-ID: <20160609035108.GD655@swordfish>
References: <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
 <1464956884-4644-1-git-send-email-ebru.akagunduz@gmail.com>
 <12918dcd-a695-c6f4-e06f-69141c5f357f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12918dcd-a695-c6f4-e06f-69141c5f357f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, akpm@linux-foundation.org, sergey.senozhatsky.work@gmail.com, mhocko@kernel.org, kirill.shutemov@linux.intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On (06/06/16 15:05), Vlastimil Babka wrote:
[..]
> I think this does fix the inconsistency, thanks.
> 
> But looking at collapse_huge_page() as of latest -next, I wonder if there's
> another problem:
> 
> pmd = mm_find_pmd(mm, address);
> ...
> up_read(&mm->mmap_sem);
> down_write(&mm->mmap_sem);
> hugepage_vma_revalidate(mm, address);
> ...
> pte = pte_offset_map(pmd, address);
> 
> What guarantees that 'pmd' is still valid?

the same question applied to __collapse_huge_page_swapin(), I think.

__collapse_huge_page_swapin(pmd)
	pte = pte_offset_map(pmd, address);
	do_swap_page(mm, vma, _address, pte, pmd...)
		up_read(&mm->mmap_sem);
	down_read(&mm->mmap_sem);
	pte = pte_offset_map(pmd, _address);

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
