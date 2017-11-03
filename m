Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E45E56B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:20:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f85so2256002pfe.7
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:20:58 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g7si4635652pln.421.2017.11.03.02.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 02:20:53 -0700 (PDT)
Date: Fri, 3 Nov 2017 12:20:49 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] s390/mm: fix pud table accounting
Message-ID: <20171103092048.ozmskabkq5rrwizz@black.fi.intel.com>
References: <20171103090551.18231-1-heiko.carstens@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171103090551.18231-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Fri, Nov 03, 2017 at 09:05:51AM +0000, Heiko Carstens wrote:
> With "mm: account pud page tables" and "mm: consolidate page table
> accounting" pud page table accounting was introduced which now results
> in tons of warnings like this one on s390:
> 
> BUG: non-zero pgtables_bytes on freeing mm: -16384
> 
> Reason for this are our run-time folded page tables: by default new
> processes start with three page table levels where the allocated pgd
> is the same as the first pud. In this case there won't ever be a pud
> allocated and therefore mm_inc_nr_puds() will also never be called.
> 
> However when freeing the address space free_pud_range() will call
> exactly once mm_dec_nr_puds() which leads to misaccounting.
> 
> Therefore call mm_inc_nr_puds() within init_new_context() to fix
> this. This is the same like we have it already for processes that run
> with two page table levels (aka compat processes).
> 
> While at it also adjust the comment, since there is no "mm->nr_pmds"
> anymore.

Thanks for tracking it down.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
