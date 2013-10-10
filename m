Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0216B0044
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:15:23 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3087381pdj.29
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:15:23 -0700 (PDT)
Date: Thu, 10 Oct 2013 21:14:58 +0200
From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [PATCH 13/34] avr32: handle pgtable_page_ctor() fail
Message-ID: <20131010191458.GA10670@samfundet.no>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-14-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381428359-14843-14-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Around Thu 10 Oct 2013 21:05:38 +0300 or thereabout, Kirill A. Shutemov wrote:
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

Given [1].

> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> ---
>  arch/avr32/include/asm/pgalloc.h | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
> index bc7e8ae479..1aba19d68c 100644
> --- a/arch/avr32/include/asm/pgalloc.h
> +++ b/arch/avr32/include/asm/pgalloc.h
> @@ -68,7 +68,10 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
>  		return NULL;
>  
>  	page = virt_to_page(pg);
> -	pgtable_page_ctor(page);
> +	if (!pgtable_page_ctor(page)) {
> +		quicklist_free(QUICK_PT, NULL, pg);
> +		return NULL;
> +	}
>  
>  	return page;
>  }

1: I'm assuming that pgtable_page_ctor() now returns success/error, but there
is a patch series that I have not seen.

-- 
mvh
Hans-Christian Egtvedt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
