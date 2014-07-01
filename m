Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id C4FCE6B0037
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 14:50:31 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id i8so8887581qcq.34
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 11:50:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k62si15711852qge.52.2014.07.01.11.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 11:50:30 -0700 (PDT)
Date: Tue, 1 Jul 2014 14:50:21 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] rmap: fix pgoff calculation to handle hugepage correctly
Message-ID: <20140701185021.GA10356@nhori.bos.redhat.com>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140701180739.GA4985@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701180739.GA4985@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 01, 2014 at 09:07:39PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 01, 2014 at 10:46:22AM -0400, Naoya Horiguchi wrote:
> > I triggered VM_BUG_ON() in vma_address() when I try to migrate an anonymous
> > hugepage with mbind() in the kernel v3.16-rc3. This is because pgoff's
> > calculation in rmap_walk_anon() fails to consider compound_order() only to
> > have an incorrect value. So this patch fixes it.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/rmap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git v3.16-rc3.orig/mm/rmap.c v3.16-rc3/mm/rmap.c
> > index b7e94ebbd09e..8cc964c6bd8d 100644
> > --- v3.16-rc3.orig/mm/rmap.c
> > +++ v3.16-rc3/mm/rmap.c
> > @@ -1639,7 +1639,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
> >  static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
> >  {
> >  	struct anon_vma *anon_vma;
> > -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > +	pgoff_t pgoff = page->index << compound_order(page);
> >  	struct anon_vma_chain *avc;
> >  	int ret = SWAP_AGAIN;
> 
> Hm. It will not work with THP: ->index there is in PAGE_SIZE units.

I wrongly assumed that rmap is never used by thp, sorry.

> Why do we need this special case for hugetlb page ->index? Why not use
> PAGE_SIZE units there too? Or I miss something?

hugetlb pages are never split, so we use larger page cache size for
hugetlbfs file (to avoid large sparse page cache tree.) I'm not sure
if we should do this for anonymous hugepages, but I guess that using
different cache size in hugetlbfs makes code complicated.

Anyway I'll do some generalization to handle any types of pages
rmap_walk_anon() can called on. Maybe something similar to
linear_page_index() will be added.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
