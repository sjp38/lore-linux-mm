Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8DAF6B036A
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 10:07:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a65so35779160pfg.11
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 07:07:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v2si10572pge.60.2017.06.13.07.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 07:07:02 -0700 (PDT)
Date: Tue, 13 Jun 2017 17:06:01 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170613140600.2orf4miov5gd3qqb@black.fi.intel.com>
References: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
 <1497349722-6731-3-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497349722-6731-3-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, vbabka@suse.cz

On Tue, Jun 13, 2017 at 11:28:41AM +0100, Will Deacon wrote:
> page_ref_freeze and page_ref_unfreeze are designed to be used as a pair,
> wrapping a critical section where struct pages can be modified without
> having to worry about consistency for a concurrent fast-GUP.
> 
> Whilst page_ref_freeze has full barrier semantics due to its use of
> atomic_cmpxchg, page_ref_unfreeze is implemented using atomic_set, which
> doesn't provide any barrier semantics and allows the operation to be
> reordered with respect to page modifications in the critical section.
> 
> This patch ensures that page_ref_unfreeze is ordered after any critical
> section updates, by invoking smp_mb() prior to the atomic_set.
> 
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Acked-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  include/linux/page_ref.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> index 610e13271918..1fd71733aa68 100644
> --- a/include/linux/page_ref.h
> +++ b/include/linux/page_ref.h
> @@ -174,6 +174,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
>  	VM_BUG_ON_PAGE(page_count(page) != 0, page);
>  	VM_BUG_ON(count == 0);
>  
> +	smp_mb();

Don't we want some comment here?

Otherwise:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
