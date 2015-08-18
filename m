Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E305F6B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:43:05 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so112482425wib.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 08:43:05 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id kb8si31025055wjb.134.2015.08.18.08.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 08:43:04 -0700 (PDT)
Received: by wijp15 with SMTP id p15so104114299wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 08:43:03 -0700 (PDT)
Date: Tue, 18 Aug 2015 17:43:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 3/4] mm: pack compound_dtor and compound_order into one
 word in struct page
Message-ID: <20150818154259.GL5033@dhcp22.suse.cz>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 17-08-15 18:09:04, Kirill A. Shutemov wrote:
> The patch halves space occupied by compound_dtor and compound_order in
> struct page.
> 
> For compound_order, it's trivial long -> int/short conversion.
> 
> For get_compound_page_dtor(), we now use hardcoded table for destructor
> lookup and store its index in the struct page instead of direct pointer
> to destructor. It shouldn't be a big trouble to maintain the table: we
> have only two destructor and NULL currently.
> 
> This patch free up one word in tail pages for reuse. This is preparation
> for the next patch.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Michal Hocko <mhocko@suse.com>

[...]
> @@ -145,8 +143,13 @@ struct page {
>  						 */
>  		/* First tail page of compound page */
>  		struct {
> -			compound_page_dtor *compound_dtor;
> -			unsigned long compound_order;
> +#ifdef CONFIG_64BIT
> +			unsigned int compound_dtor;
> +			unsigned int compound_order;
> +#else
> +			unsigned short int compound_dtor;
> +			unsigned short int compound_order;
> +#endif
>  		};

Why do we need this ifdef? We can go with short for both 32b and 64b
AFAICS. We do not use compound_order for anything else than the order,
right?

While I am looking at this, it seems we are jugling with type for order
quite a lot - int, unsing int and even unsigned long.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
