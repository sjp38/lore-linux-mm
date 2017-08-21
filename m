Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2D756B04F2
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 17:41:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b14so9087287wrd.11
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:41:53 -0700 (PDT)
Received: from mail-wr0-x236.google.com (mail-wr0-x236.google.com. [2a00:1450:400c:c0c::236])
        by mx.google.com with ESMTPS id y43si1646035edd.48.2017.08.21.14.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 14:41:52 -0700 (PDT)
Received: by mail-wr0-x236.google.com with SMTP id z91so108004298wrc.4
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:41:52 -0700 (PDT)
Date: Tue, 22 Aug 2017 00:41:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch] fs, proc: unconditional cond_resched when reading smaps
Message-ID: <20170821214150.pgv3ulpicnacslak@node.shutemov.name>
References: <alpine.DEB.2.10.1708211405520.131071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708211405520.131071@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 21, 2017 at 02:06:45PM -0700, David Rientjes wrote:
> If there are large numbers of hugepages to iterate while reading
> /proc/pid/smaps, the page walk never does cond_resched().  On archs
> without split pmd locks, there can be significant and observable
> contention on mm->page_table_lock which cause lengthy delays without
> rescheduling.
> 
> Always reschedule in smaps_pte_range() if necessary since the pagewalk
> iteration can be expensive.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  fs/proc/task_mmu.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -599,11 +599,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	if (ptl) {
>  		smaps_pmd_entry(pmd, addr, walk);
>  		spin_unlock(ptl);
> -		return 0;
> +		goto out;
>  	}
>  
>  	if (pmd_trans_unstable(pmd))
> -		return 0;
> +		goto out;
>  	/*
>  	 * The mmap_sem held all the way back in m_start() is what
>  	 * keeps khugepaged out of here and from collapsing things
> @@ -613,6 +613,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	for (; addr != end; pte++, addr += PAGE_SIZE)
>  		smaps_pte_entry(pte, addr, walk);
>  	pte_unmap_unlock(pte - 1, ptl);
> +out:
>  	cond_resched();
>  	return 0;
>  }

Maybe just call cond_resched() at the beginning of the function and don't
bother with gotos?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
