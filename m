Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id E61ED6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:24:06 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so6513777pbc.24
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:24:06 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id v7si10876572pbi.38.2013.12.16.22.24.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 22:24:05 -0800 (PST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Dec 2013 16:23:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9CC7D3578050
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:23:52 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBH6NdqK4456912
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:23:40 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBH6Npfs009289
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:23:51 +1100
Date: Tue, 17 Dec 2013 14:23:49 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at mm/mempolicy.c:1203!
Message-ID: <52afee05.0722440a.307f.1b9dSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52AE3D45.8000100@oracle.com>
 <52AF9E68.9000309@oracle.com>
 <52AFA46A.2040605@oracle.com>
 <52AFD559.5010405@oracle.com>
 <1387260683-9qoogm56-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387260683-9qoogm56-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Bob Liu <bob.liu@oracle.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dan.carpenter@oracle.com

On Tue, Dec 17, 2013 at 01:11:23AM -0500, Naoya Horiguchi wrote:
>Hello Bob,
>
>On Tue, Dec 17, 2013 at 12:38:49PM +0800, Bob Liu wrote:
>> On 12/17/2013 09:10 AM, Sasha Levin wrote:
>> > On 12/16/2013 07:44 PM, Bob Liu wrote:
>> >>
>> >> On 12/16/2013 07:37 AM, Sasha Levin wrote:
>> >>> Hi all,
>> >>>
>> >>> While fuzzing with trinity inside a KVM tools guest running latest -next
>> >>> kernel, I've
>> >>> stumbled on the following spew.
>> >>>
>> >>> This seems to be due to commit 0bf598d863e "mbind: add BUG_ON(!vma) in
>> >>> new_vma_page()"
>> >>> which added that BUG_ON.
>> >>
>> >> Could you take a try with this patch from Wanpeng Li?
>> >>
>> >> Thanks,
>> >> -Bob
>> >>
>> >> Subject: [PATCH] mm/mempolicy: fix !vma in new_vma_page()
>> >> ....
>> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> >> index eca4a31..73b5a35 100644
>> >> --- a/mm/mempolicy.c
>> >> +++ b/mm/mempolicy.c
>> >> @@ -1197,14 +1197,16 @@ static struct page *new_vma_page(struct page
>> >> *page, unsigned long private, int *
>> >>               break;
>> >>           vma = vma->vm_next;
>> >>       }
>> >> +
>> >> +    if (PageHuge(page)) {
>> >> +        if (vma)
>> >> +            return alloc_huge_page_noerr(vma, address, 1);
>> >> +        else
>> >> +            return NULL;
>> >> +    }
>> >>       /*
>> >> -     * queue_pages_range() confirms that @page belongs to some vma,
>> >> -     * so vma shouldn't be NULL.
>> >> +     * if !vma, alloc_page_vma() will use task or system default policy
>> >>        */
>> >> -    BUG_ON(!vma);
>> >> -
>> >> -    if (PageHuge(page))
>> >> -        return alloc_huge_page_noerr(vma, address, 1);
>> >>       return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
>> >>   }
>> >>   #else
>> >>
>> > 
>> > Hmm... So in essence it's mostly a revert of Naoya's patch, who seemed
>> > pretty certain that this
>> > situation shouldn't happen at all. What's the reasoning behind just
>> 
>> I think this assumption may not correct.
>> Even if
>> address = __vma_address(page, vma);
>> and
>> vma->start < address < vma->end;
>> page_address_in_vma() may still return -EFAULT because of many other
>> conditions in it.
>> As a result the while loop in new_vma_page() may end with vma=NULL.
>> 
>> Naoya, any idea?
>
>Yes, you totally make sense. So please apply Wanpeng's patch.
>

Ah, ok, I will send a formalized patch. 

Regards,
Wanpeng Li 

>Thanks,
>Naoya Horiguchi
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
