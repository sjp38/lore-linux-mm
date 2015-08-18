Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 34C096B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 14:24:46 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so102075695wic.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:24:45 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id s1si28673076wif.85.2015.08.18.11.24.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 11:24:44 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so116176951wib.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:24:43 -0700 (PDT)
Date: Tue, 18 Aug 2015 21:24:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 4/4] mm: make compound_head() robust
Message-ID: <20150818182441.GC21383@node.dhcp.inet.fi>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150818112022.GJ5033@dhcp22.suse.cz>
 <20150818164112.GN5033@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150818164112.GN5033@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 18, 2015 at 06:41:13PM +0200, Michal Hocko wrote:
> On Tue 18-08-15 13:20:22, Michal Hocko wrote:
> > On Mon 17-08-15 18:09:05, Kirill A. Shutemov wrote:
> > > Hugh has pointed that compound_head() call can be unsafe in some
> > > context. There's one example:
> > > 
> > > 	CPU0					CPU1
> > > 
> > > isolate_migratepages_block()
> > >   page_count()
> > >     compound_head()
> > >       !!PageTail() == true
> > > 					put_page()
> > > 					  tail->first_page = NULL
> > >       head = tail->first_page
> > > 					alloc_pages(__GFP_COMP)
> > > 					   prep_compound_page()
> > > 					     tail->first_page = head
> > > 					     __SetPageTail(p);
> > >       !!PageTail() == true
> > >     <head == NULL dereferencing>
> > > 
> > > The race is pure theoretical. I don't it's possible to trigger it in
> > > practice. But who knows.
> > > 
> > > We can fix the race by changing how encode PageTail() and compound_head()
> > > within struct page to be able to update them in one shot.
> > > 
> > > The patch introduces page->compound_head into third double word block in
> > > front of compound_dtor and compound_order. That means it shares storage
> > > space with:
> > > 
> > >  - page->lru.next;
> > >  - page->next;
> > >  - page->rcu_head.next;
> > >  - page->pmd_huge_pte;
> > > 
> > > That's too long list to be absolutely sure, but looks like nobody uses
> > > bit 0 of the word. It can be used to encode PageTail(). And if the bit
> > > set, rest of the word is pointer to head page.
> > 
> > I didn't look too closely but the general idea makes sense to me and the
> > overal code simplification is sound. I will give it more detailed review
> > after I sort out other stuff.
> 
> AFICS page::first_page wasn't used outside of compound page logic so you
> should remove it in this patch. The rest looks good to me.

I missed it by accident during rework for v2. Will fix.

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
