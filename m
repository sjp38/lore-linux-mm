Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3766B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 03:13:45 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so8200512wic.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 00:13:45 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id s12si2730169wik.34.2015.08.21.00.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 00:13:44 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so11628203wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 00:13:43 -0700 (PDT)
Date: Fri, 21 Aug 2015 09:13:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 3/5] mm: pack compound_dtor and compound_order into one
 word in struct page
Message-ID: <20150821071341.GE23723@dhcp22.suse.cz>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820162604.1a1dbbfeafefcda4327587af@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820162604.1a1dbbfeafefcda4327587af@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 20-08-15 16:26:04, Andrew Morton wrote:
> On Wed, 19 Aug 2015 12:21:44 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > The patch halves space occupied by compound_dtor and compound_order in
> > struct page.
> > 
> > For compound_order, it's trivial long -> int/short conversion.
> > 
> > For get_compound_page_dtor(), we now use hardcoded table for destructor
> > lookup and store its index in the struct page instead of direct pointer
> > to destructor. It shouldn't be a big trouble to maintain the table: we
> > have only two destructor and NULL currently.
> > 
> > This patch free up one word in tail pages for reuse. This is preparation
> > for the next patch.
> > 
> > ...
> >
> > @@ -145,8 +143,13 @@ struct page {
> >  						 */
> >  		/* First tail page of compound page */
> >  		struct {
> > -			compound_page_dtor *compound_dtor;
> > -			unsigned long compound_order;
> > +#ifdef CONFIG_64BIT
> > +			unsigned int compound_dtor;
> > +			unsigned int compound_order;
> > +#else
> > +			unsigned short int compound_dtor;
> > +			unsigned short int compound_order;
> > +#endif
> 
> Why not use ushort for 64-bit as well?

Yeah, I have asked the same in the previous round. So I've tried to
compile with ushort. The resulting code was slightly larger
   text    data     bss     dec     hex filename
 476370   90811   44632  611813   955e5 mm/built-in.o.prev
 476418   90811   44632  611861   95615 mm/built-in.o.after

E.g. prep_compound_page
before:
4c6b:       c7 47 68 01 00 00 00    movl   $0x1,0x68(%rdi)
4c72:       89 77 6c                mov    %esi,0x6c(%rdi)
after:
4c6c:       66 c7 47 68 01 00       movw   $0x1,0x68(%rdi)
4c72:       66 89 77 6a             mov    %si,0x6a(%rdi)

which looks very similar to me but I am not an expert here so it might
possible that movw is slower.

__free_pages_ok
before:
63af:       8b 77 6c                mov    0x6c(%rdi),%esi
after:
63b1:       0f b7 77 6a             movzwl 0x6a(%rdi),%esi

which looks like a worse code to me. Whether this all is measurable or
worth it I dunno. The ifdef is ugly but maybe the ugliness is a destiny
for struct page.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
