Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 66CCD6B0037
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:38 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so2660682ead.8
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j47si3871095eeo.11.2013.12.16.22.11.36
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:37 -0800 (PST)
Date: Tue, 17 Dec 2013 01:11:23 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1387260683-9qoogm56-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <52AFD559.5010405@oracle.com>
References: <52AE3D45.8000100@oracle.com>
 <52AF9E68.9000309@oracle.com>
 <52AFA46A.2040605@oracle.com>
 <52AFD559.5010405@oracle.com>
Subject: Re: mm: kernel BUG at mm/mempolicy.c:1203!
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dan.carpenter@oracle.com

Hello Bob,

On Tue, Dec 17, 2013 at 12:38:49PM +0800, Bob Liu wrote:
> On 12/17/2013 09:10 AM, Sasha Levin wrote:
> > On 12/16/2013 07:44 PM, Bob Liu wrote:
> >>
> >> On 12/16/2013 07:37 AM, Sasha Levin wrote:
> >>> Hi all,
> >>>
> >>> While fuzzing with trinity inside a KVM tools guest running latest -next
> >>> kernel, I've
> >>> stumbled on the following spew.
> >>>
> >>> This seems to be due to commit 0bf598d863e "mbind: add BUG_ON(!vma) in
> >>> new_vma_page()"
> >>> which added that BUG_ON.
> >>
> >> Could you take a try with this patch from Wanpeng Li?
> >>
> >> Thanks,
> >> -Bob
> >>
> >> Subject: [PATCH] mm/mempolicy: fix !vma in new_vma_page()
> >> ....
> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> index eca4a31..73b5a35 100644
> >> --- a/mm/mempolicy.c
> >> +++ b/mm/mempolicy.c
> >> @@ -1197,14 +1197,16 @@ static struct page *new_vma_page(struct page
> >> *page, unsigned long private, int *
> >>               break;
> >>           vma = vma->vm_next;
> >>       }
> >> +
> >> +    if (PageHuge(page)) {
> >> +        if (vma)
> >> +            return alloc_huge_page_noerr(vma, address, 1);
> >> +        else
> >> +            return NULL;
> >> +    }
> >>       /*
> >> -     * queue_pages_range() confirms that @page belongs to some vma,
> >> -     * so vma shouldn't be NULL.
> >> +     * if !vma, alloc_page_vma() will use task or system default policy
> >>        */
> >> -    BUG_ON(!vma);
> >> -
> >> -    if (PageHuge(page))
> >> -        return alloc_huge_page_noerr(vma, address, 1);
> >>       return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> >>   }
> >>   #else
> >>
> > 
> > Hmm... So in essence it's mostly a revert of Naoya's patch, who seemed
> > pretty certain that this
> > situation shouldn't happen at all. What's the reasoning behind just
> 
> I think this assumption may not correct.
> Even if
> address = __vma_address(page, vma);
> and
> vma->start < address < vma->end;
> page_address_in_vma() may still return -EFAULT because of many other
> conditions in it.
> As a result the while loop in new_vma_page() may end with vma=NULL.
> 
> Naoya, any idea?

Yes, you totally make sense. So please apply Wanpeng's patch.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
