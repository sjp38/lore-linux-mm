Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A8D5A6B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 18:36:11 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so296925pab.1
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 15:36:11 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id w11si221475pdj.140.2014.07.10.15.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 15:36:10 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so275784pdj.19
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 15:36:09 -0700 (PDT)
Date: Thu, 10 Jul 2014 15:34:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 28/83] mm: Change timing of notification to IOMMUs about
 a page to be invalidated
In-Reply-To: <20140710222200.GZ1958@8bytes.org>
Message-ID: <alpine.LSU.2.11.1407101523130.22274@eggly.anvils>
References: <1405029208-6703-1-git-send-email-oded.gabbay@amd.com> <20140710222200.GZ1958@8bytes.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Oded Gabbay <oded.gabbay@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, John Bridgman <John.Bridgman@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, linux-mm <linux-mm@kvack.org>, Oded Gabbay <oded.gabbay@amd.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jerome Glisse <jglisse@redhat.com>, Jianyu Zhan <nasa4836@gmail.com>

On Fri, 11 Jul 2014, Joerg Roedel wrote:
> On Fri, Jul 11, 2014 at 12:53:26AM +0300, Oded Gabbay wrote:
> >  mm/rmap.c | 8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 196cd0c..73d4c3d 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1231,13 +1231,17 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  	} else
> >  		dec_mm_counter(mm, MM_FILEPAGES);
> >  
> > +	pte_unmap_unlock(pte, ptl);
> > +
> > +	mmu_notifier_invalidate_page(vma, address, event);
> > +
> >  	page_remove_rmap(page);
> >  	page_cache_release(page);
> >  
> > +	return ret;
> > +
> >  out_unmap:
> >  	pte_unmap_unlock(pte, ptl);
> > -	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
> > -		mmu_notifier_invalidate_page(vma, address, event);
> >  out:
> >  	return ret;
> 
> I think there is no bug. In that function the page is just unmapped,
> removed from the rmap (page_remove_rmap), and the LRU list
> (page_cache_release). The page itself is not released in this function,
> so the call mmu_notifier_invalidate_page() at the end is fine.

Agreed, nothing to fix here: the try_to_unmap() callers must hold
their own reference to the page.  If they did not, how could they
be sure that this is a page which is appropriate to unmap?

(Nit: we don't actually take a separate reference for the LRU list:
the page_cache_release above corresponds to the reference in the
pte which has just been removed.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
