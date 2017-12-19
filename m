Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5D046B0293
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:49:57 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id i33so7388582pld.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:49:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1si9254678plu.508.2017.12.19.04.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 04:49:56 -0800 (PST)
Date: Tue, 19 Dec 2017 04:49:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/8] mm: Store compound_dtor / compound_order as bytes
Message-ID: <20171219124955.GB13680@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-7-willy@infradead.org>
 <20171219081956.GC2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219081956.GC2787@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 09:19:56AM +0100, Michal Hocko wrote:
> On Sat 16-12-17 08:44:23, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Neither of these values get even close to 256; compound_dtor is
> > currently at a maximum of 3, and compound_order can't be over 64.
> > No machine has inefficient access to bytes since EV5, and while
> > those are still supported, we don't optimise for them any more.
> 
> Hmm, so the improvement is the ifdef-ery removale, right? Beucase this
> will not shrink the structure size AFAICS. I think that the former is
> a sufficient justification. Maybe you should spell it out.

I'll add that to the changelog.  It also frees up 2-6 bytes for another
usage, if we decide there's something else we need to store in a
compound page.  I also added the pahole diff output:

@@ -34,8 +34,8 @@
                struct callback_head callback_head;      /*    32    16 */
                struct {
                        long unsigned int compound_head; /*    32     8 */
-                       unsigned int compound_dtor;      /*    40     4 */
-                       unsigned int compound_order;     /*    44     4 */
+                       unsigned char compound_dtor;     /*    40     1 */
+                       unsigned char compound_order;    /*    41     1 */
                };                                       /*    32    16 */
        };                                               /*    32    16 */
        union {

> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  include/linux/mm_types.h | 15 ++-------------
> >  1 file changed, 2 insertions(+), 13 deletions(-)
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 5521c9799c50..1a3ba1f1605d 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -136,19 +136,8 @@ struct page {
> >  			unsigned long compound_head; /* If bit zero is set */
> >  
> >  			/* First tail page only */
> > -#ifdef CONFIG_64BIT
> > -			/*
> > -			 * On 64 bit system we have enough space in struct page
> > -			 * to encode compound_dtor and compound_order with
> > -			 * unsigned int. It can help compiler generate better or
> > -			 * smaller code on some archtectures.
> > -			 */
> > -			unsigned int compound_dtor;
> > -			unsigned int compound_order;
> > -#else
> > -			unsigned short int compound_dtor;
> > -			unsigned short int compound_order;
> > -#endif
> > +			unsigned char compound_dtor;
> > +			unsigned char compound_order;
> >  		};
> >  
> >  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> > -- 
> > 2.15.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
