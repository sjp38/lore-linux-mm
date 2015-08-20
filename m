Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB066B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:26:07 -0400 (EDT)
Received: by pawq9 with SMTP id q9so38116021paw.3
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:26:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id da3si9760869pdb.56.2015.08.20.16.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 16:26:06 -0700 (PDT)
Date: Thu, 20 Aug 2015 16:26:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 3/5] mm: pack compound_dtor and compound_order into
 one word in struct page
Message-Id: <20150820162604.1a1dbbfeafefcda4327587af@linux-foundation.org>
In-Reply-To: <1439976106-137226-4-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1439976106-137226-4-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Aug 2015 12:21:44 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

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
> ...
>
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

Why not use ushort for 64-bit as well?

It would be clearer if that new enum had a name, so we use "enum
compound_dtor_id" everywhere instead of a bare uint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
