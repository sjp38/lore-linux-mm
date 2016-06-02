Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBC616B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 14:40:34 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so60481510pad.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 11:40:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ie10si130542pad.48.2016.06.02.11.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 11:40:33 -0700 (PDT)
Date: Thu, 2 Jun 2016 11:40:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Message-Id: <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
In-Reply-To: <20160602155149.GB8493@node.shutemov.name>
References: <20160602172141.75c006a9@thinkpad>
	<20160602155149.GB8493@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, 2 Jun 2016 18:51:50 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Thu, Jun 02, 2016 at 05:21:41PM +0200, Gerald Schaefer wrote:
> > Christian Borntraeger reported a kernel panic after corrupt page counts,
> > and it turned out to be a regression introduced with commit aa88b68c
> > "thp: keep huge zero page pinned until tlb flush", at least on s390.
> > 
> > put_huge_zero_page() was moved over from zap_huge_pmd() to release_pages(),
> > and it was replaced by tlb_remove_page(). However, release_pages() might
> > not always be triggered by (the arch-specific) tlb_remove_page().
> > 
> > On s390 we call free_page_and_swap_cache() from tlb_remove_page(), and not
> > tlb_flush_mmu() -> free_pages_and_swap_cache() like the generic version,
> > because we don't use the MMU-gather logic. Although both functions have very
> > similar names, they are doing very unsimilar things, in particular
> > free_page_xxx is just doing a put_page(), while free_pages_xxx calls
> > release_pages().
> > 
> > This of course results in very harmful put_page()s on the huge zero page,
> > on architectures where tlb_remove_page() is implemented in this way. It
> > seems to affect only s390 and sh, but sh doesn't have THP support, so
> > the problem (currently) probably only exists on s390.
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

Yes.  A bit regrettable, but that's what release_pages() does.

Can we have a signed-off-by please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
