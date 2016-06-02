Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBBAD6B025E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 15:48:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so70360485pfs.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:48:07 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id t10si402957pat.178.2016.06.02.12.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 12:48:06 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id b124so34848469pfb.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:48:06 -0700 (PDT)
Date: Thu, 2 Jun 2016 12:47:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
In-Reply-To: <20160602155149.GB8493@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1606021240310.10558@eggly.anvils>
References: <20160602172141.75c006a9@thinkpad> <20160602155149.GB8493@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, 2 Jun 2016, Kirill A. Shutemov wrote:
> On Thu, Jun 02, 2016 at 05:21:41PM +0200, Gerald Schaefer wrote:
> > 
> > The following quick hack fixed the issue:
> > 
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 0d457e7..c99463a 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -252,7 +252,10 @@ static inline void free_swap_cache(struct page *page)
> >  void free_page_and_swap_cache(struct page *page)
> >  {
> >  	free_swap_cache(page);
> > -	put_page(page);
> > +	if (is_huge_zero_page(page))
> > +		put_huge_zero_page();
> > +	else
> > +		put_page(page);
> >  }
> >  
> >  /*
> 
> The fix looks good to me.

Is there a good reason why the refcount of the huge_zero_page is
huge_zero_refcount, instead of the refcount of the huge_zero_page?
Wouldn't the latter avoid such is_huge_zero_page() special-casing?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
