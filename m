Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5476B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 19:13:59 -0400 (EDT)
Received: by pddn5 with SMTP id n5so69675239pdd.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 16:13:59 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id n7si4822007pdr.125.2015.04.01.16.13.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 16:13:58 -0700 (PDT)
Received: by pactp5 with SMTP id tp5so65656159pac.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 16:13:58 -0700 (PDT)
Date: Wed, 1 Apr 2015 16:13:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound
 page
In-Reply-To: <20150401131753.GD17153@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1504011600120.5710@eggly.anvils>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com> <87lhicbbf8.fsf@linux.vnet.ibm.com> <20150401131753.GD17153@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 1 Apr 2015, Kirill A. Shutemov wrote:
> On Wed, Apr 01, 2015 at 12:08:35PM +0530, Aneesh Kumar K.V wrote:
> > 
> > With this we now have pte mapping part of a compound page(). Now the
> > gneric gup implementation does
> > 
> > gup_pte_range()
> > 	ptem = ptep = pte_offset_map(&pmd, addr);
> > 	do {
> > 
> > ....
> > ...
> > 		if (!page_cache_get_speculative(page))
> > 			goto pte_unmap;
> > .....
> >         }
> > 
> > That page_cache_get_speculative will fail in our case because it does
> > if (unlikely(!get_page_unless_zero(page))) on a tail page. ??
> 
> Nice catch, thanks.

Indeed; but it's not the generic gup implementation,
it's just the generic fast gup implementation.

> 
> But the problem is not exclusive to my patchset. In current kernel some
> drivers (sound, for instance) map compound pages with PTEs.

Nobody has cared whether fast gup works on those, just so long as
slow gup works on those without VM_IO | VM_PFNMAP.  Whereas people did
care that fast gup work on THPs, so gave them more complicated handling.

> 
> We can try to get page_cache_get_speculative() work on PTE-mapped tail
> pages. Untested patch is below.

I didn't check through; but we'll agree that it's sad to see the
complexity you've managed to reduce elsewhere now popping up again
in other places.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
