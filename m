Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 42B086B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 14:22:18 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so102029859wic.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:22:17 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id it9si263142wid.64.2015.08.18.11.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 11:22:16 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so107593525wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:22:16 -0700 (PDT)
Date: Tue, 18 Aug 2015 21:22:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 3/4] mm: pack compound_dtor and compound_order into one
 word in struct page
Message-ID: <20150818182214.GA21383@node.dhcp.inet.fi>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20150818154259.GL5033@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150818154259.GL5033@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 18, 2015 at 05:43:00PM +0200, Michal Hocko wrote:
> On Mon 17-08-15 18:09:04, Kirill A. Shutemov wrote:
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
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.com>
> 
> [...]
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
> >  		};
> 
> Why do we need this ifdef? We can go with short for both 32b and 64b
> AFAICS.

My assumption was that operations on ints can be faster on some
[micro]arhictectures. I'm not sure if it's ever true.

> We do not use compound_order for anything else than the order, right?

Right.

> While I am looking at this, it seems we are jugling with type for order
> quite a lot - int, unsing int and even unsigned long.

Yeah. It's mess. I'll check if I can fix anything of it in v3.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
