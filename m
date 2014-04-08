Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7956B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 16:26:07 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so1102718eek.7
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 13:26:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v8si4313551eew.37.2014.04.08.13.26.04
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 13:26:05 -0700 (PDT)
Date: Tue, 8 Apr 2014 16:25:39 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 1/5] hugetlb: prep_compound_gigantic_page(): drop __init
 marker
Message-ID: <20140408162539.41f68428@redhat.com>
In-Reply-To: <1396986711-o0m2kq1v@n-horiguchi@ah.jp.nec.com>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
	<1396983740-26047-2-git-send-email-lcapitulino@redhat.com>
	<1396986711-o0m2kq1v@n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Tue, 08 Apr 2014 15:51:51 -0400
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Hi Luiz,
> 
> On Tue, Apr 08, 2014 at 03:02:16PM -0400, Luiz Capitulino wrote:
> > This function is going to be used by non-init code in a future
> > commit.
> > 
> > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> > ---
> >  mm/hugetlb.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 7c02b9d..319db28 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -689,8 +689,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
> >  	put_page(page); /* free it into the hugepage allocator */
> >  }
> >  
> > -static void __init prep_compound_gigantic_page(struct page *page,
> > -					       unsigned long order)
> > +static void prep_compound_gigantic_page(struct page *page, unsigned long order)
> >  {
> >  	int i;
> >  	int nr_pages = 1 << order;
> 
> Is __ClearPageReserved() in this function relevant only in boot time
> allocation? 

Yes.

> If yes, it might be good to avoid calling it in runtime
> allocation.

The problem is that prep_compound_gigantic_page() is good and used by
both boottime and runtime allocations. Having two functions to do the
same thing seems like overkill, especially because the runtime allocation
code skips reserved pages. So the reserved bit should always be cleared
for runtime allocated gigantic pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
