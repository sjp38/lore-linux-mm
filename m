Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E35B6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 09:05:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so18010637wme.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:05:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n124si18515873wma.8.2016.06.06.06.05.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 06:05:23 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: fix locking inconsistency in collapse_huge_page
References: <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
 <1464956884-4644-1-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <12918dcd-a695-c6f4-e06f-69141c5f357f@suse.cz>
Date: Mon, 6 Jun 2016 15:05:19 +0200
MIME-Version: 1.0
In-Reply-To: <1464956884-4644-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, akpm@linux-foundation.org
Cc: sergey.senozhatsky.work@gmail.com, mhocko@kernel.org, kirill.shutemov@linux.intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On 06/03/2016 02:28 PM, Ebru Akagunduz wrote:
> After creating revalidate vma function, locking inconsistency occured
> due to directing the code path to wrong label. This patch directs
> to correct label and fix the inconsistency.
>
> Related commit that caused inconsistency:
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=da4360877094368f6dfe75bbe804b0f0a5d575b0
>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

I think this does fix the inconsistency, thanks.

But looking at collapse_huge_page() as of latest -next, I wonder if 
there's another problem:

pmd = mm_find_pmd(mm, address);
...
up_read(&mm->mmap_sem);
down_write(&mm->mmap_sem);
hugepage_vma_revalidate(mm, address);
...
pte = pte_offset_map(pmd, address);

What guarantees that 'pmd' is still valid?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
