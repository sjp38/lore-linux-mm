Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE4B96B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 06:37:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e3so39466351wme.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 03:37:02 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id p4si7445262wmp.45.2016.06.03.03.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 03:37:01 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n184so22015253wmn.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 03:37:01 -0700 (PDT)
Date: Fri, 3 Jun 2016 13:36:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Message-ID: <20160603103659.GA23467@node>
References: <20160602172141.75c006a9@thinkpad>
 <20160602155149.GB8493@node.shutemov.name>
 <alpine.LSU.2.11.1606021240310.10558@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1606021240310.10558@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, Jun 02, 2016 at 12:47:57PM -0700, Hugh Dickins wrote:
> On Thu, 2 Jun 2016, Kirill A. Shutemov wrote:
> > On Thu, Jun 02, 2016 at 05:21:41PM +0200, Gerald Schaefer wrote:
> > > 
> > > The following quick hack fixed the issue:
> > > 
> > > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > > index 0d457e7..c99463a 100644
> > > --- a/mm/swap_state.c
> > > +++ b/mm/swap_state.c
> > > @@ -252,7 +252,10 @@ static inline void free_swap_cache(struct page *page)
> > >  void free_page_and_swap_cache(struct page *page)
> > >  {
> > >  	free_swap_cache(page);
> > > -	put_page(page);
> > > +	if (is_huge_zero_page(page))
> > > +		put_huge_zero_page();
> > > +	else
> > > +		put_page(page);
> > >  }
> > >  
> > >  /*
> > 
> > The fix looks good to me.
> 
> Is there a good reason why the refcount of the huge_zero_page is
> huge_zero_refcount, instead of the refcount of the huge_zero_page?
> Wouldn't the latter avoid such is_huge_zero_page() special-casing?

Hm. I thought I had a reason for not using page's refcount, but I can't
find any now. We would loose sanity check in put_huge_zero_page(), but I
guess it's fine since we never triggered it.

I'll put it to my todo list.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
