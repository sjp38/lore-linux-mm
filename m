Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95E416B02F3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:17:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z36so10138356wrb.13
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:17:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n84si3673824wmi.265.2017.08.09.13.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:17:47 -0700 (PDT)
Date: Wed, 9 Aug 2017 13:17:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/rmap: try_to_unmap_one() do not call mmu_notifier
 under ptl
Message-Id: <20170809131742.303dfdc5730d8a8bba62a7cb@linux-foundation.org>
In-Reply-To: <88997080.69197246.1502297566486.JavaMail.zimbra@redhat.com>
References: <20170809161709.9278-1-jglisse@redhat.com>
	<20170809163434.p356oyarqpqh52hu@node.shutemov.name>
	<88997080.69197246.1502297566486.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, 9 Aug 2017 12:52:46 -0400 (EDT) Jerome Glisse <jglisse@redhat.com> wrote:

> > On Wed, Aug 09, 2017 at 12:17:09PM -0400, jglisse@redhat.com wrote:
> > > From: J__r__me Glisse <jglisse@redhat.com>
> > > 
> > > MMU notifiers can sleep, but in try_to_unmap_one() we call
> > > mmu_notifier_invalidate_page() under page table lock.
> > > 
> > > Let's instead use mmu_notifier_invalidate_range() outside
> > > page_vma_mapped_walk() loop.
> > > 
> > > Signed-off-by: J__r__me Glisse <jglisse@redhat.com>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
> > > page_vma_mapped_walk()")
> > > ---
> > >  mm/rmap.c | 36 +++++++++++++++++++++---------------
> > >  1 file changed, 21 insertions(+), 15 deletions(-)
> > > 
> > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > index aff607d5f7d2..d60e887f1cda 100644
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -1329,7 +1329,8 @@ static bool try_to_unmap_one(struct page *page,
> > > struct vm_area_struct *vma,
> > >  	};
> > >  	pte_t pteval;
> > >  	struct page *subpage;
> > > -	bool ret = true;
> > > +	bool ret = true, invalidation_needed = false;
> > > +	unsigned long end = address + PAGE_SIZE;
> > 
> > I think it should be 'address + (1UL << compound_order(page))'.
> 
> Can't address point to something else than first page in huge page ?
> Also i did use end as an optimization ie maybe not all the pte in the
> range are valid and thus they not all need to be invalidated hence by
> tracking the last one that needs invalidation i am limiting the range.
> 
> But it is a small optimization so i am not attach to it.
> 

So we need this patch in addition to Kirrill's "rmap: do not call
mmu_notifier_invalidate_page() under ptl". 

Jerome, I'm seeing a bunch of rejects applying this patch to current
mainline.  It's unclear which kernel you're patching but we'll need
something which can go into Linus soon and which is backportable (with
mimimal fixups) into -stable kernels, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
