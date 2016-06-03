Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F232E6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 00:15:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s73so87507906pfs.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 21:15:29 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id u3si4788006pfu.244.2016.06.02.21.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 21:15:29 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id f144so10264602pfa.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 21:15:28 -0700 (PDT)
Date: Fri, 3 Jun 2016 13:14:19 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603041351.GA10882@swordfish>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
 <20160602185856.GA3854@debian>
 <20160603010036.GA464@swordfish>
 <20160603012919.GB464@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603012919.GB464@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org

On (06/03/16 10:29), Sergey Senozhatsky wrote:
> > 	if (allocstall == curr_allocstall && swap != 0) {
> > 		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
> > 			{
> > 			:	if (ret & VM_FAULT_RETRY) {
> > 			:		down_read(&mm->mmap_sem);
> > 			:		^^^^^^^^^
> 
> oh... it's in a loop
> 
> 		for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
> 						pte++, _address += PAGE_SIZE) {
> 			ret = do_swap_page()
> 			if (ret & VM_FAULT_RETRY) {
> 				down_read(&mm->mmap_sem);
> 				^^^^^^^^^
> 				...
> 			}
> 		}
> 
> so there can be multiple sem->count++ in __collapse_huge_page_swapin(),
> and you don't know how many sem->count-- you need to do later? is this
> correct or am I hallucinating?

No, I was wrong, sorry for the noise.

it's getting unlocked in

__collapse_huge_page_swapin()
	do_swap_page()
		lock_page_or_retry()
			if (flags & FAULT_FLAG_ALLOW_RETRY)
				up_read(&mm->mmap_sem);
	return VM_FAULT_RETRY

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
