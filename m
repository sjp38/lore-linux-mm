Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA6E6B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:41:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c6so13622194pfj.5
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:41:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d17si4085856pge.245.2017.06.08.03.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 03:41:00 -0700 (PDT)
Date: Thu, 8 Jun 2017 13:40:56 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170608104056.ujuytybmwumuty64@black.fi.intel.com>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 11:38:21AM +0200, Vlastimil Babka wrote:
> On 06/06/2017 07:58 PM, Will Deacon wrote:
> > page_ref_freeze and page_ref_unfreeze are designed to be used as a pair,
> > wrapping a critical section where struct pages can be modified without
> > having to worry about consistency for a concurrent fast-GUP.
> > 
> > Whilst page_ref_freeze has full barrier semantics due to its use of
> > atomic_cmpxchg, page_ref_unfreeze is implemented using atomic_set, which
> > doesn't provide any barrier semantics and allows the operation to be
> > reordered with respect to page modifications in the critical section.
> > 
> > This patch ensures that page_ref_unfreeze is ordered after any critical
> > section updates, by invoking smp_mb__before_atomic() prior to the
> > atomic_set.
> > 
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Acked-by: Steve Capper <steve.capper@arm.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Undecided if it's really needed. This is IMHO not the classical case
> from Documentation/core-api/atomic_ops.rst where we have to make
> modifications visible before we let others see them? Here the one who is
> freezing is doing it so others can't get their page pin and interfere
> with the freezer's work.

Hm.. I'm not sure I'm getting what you are talking about. 

What would guarantee others to see changes to page before seeing page
unfreezed?

> >  include/linux/page_ref.h | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> > index 610e13271918..74d32d7905cb 100644
> > --- a/include/linux/page_ref.h
> > +++ b/include/linux/page_ref.h
> > @@ -174,6 +174,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
> >  	VM_BUG_ON_PAGE(page_count(page) != 0, page);
> >  	VM_BUG_ON(count == 0);
> >  
> > +	smp_mb__before_atomic();
> >  	atomic_set(&page->_refcount, count);

I *think* it should be smp_mb(), not __before_atomic(). atomic_set() is
not really atomic. For instance on x86 it's plain WRITE_ONCE() which CPU
would happily reorder.

> >  	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
> >  		__page_ref_unfreeze(page, count);
> > 
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
