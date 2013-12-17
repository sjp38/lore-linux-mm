Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id C8BD06B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:55:31 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so6600396pbb.0
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:55:31 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id yd9si10938106pab.118.2013.12.16.22.55.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 22:55:29 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Dec 2013 16:55:26 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0AF542CE8052
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:55:21 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBH6t82H11141390
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:55:08 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBH6tKcj003633
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:55:20 +1100
Date: Tue, 17 Dec 2013 14:55:18 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at mm/mempolicy.c:1203!
Message-ID: <52aff561.e9a2420a.6c70.2c3dSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52AE3D45.8000100@oracle.com>
 <52AF9E68.9000309@oracle.com>
 <52AFA46A.2040605@oracle.com>
 <52AFD559.5010405@oracle.com>
 <1387260683-9qoogm56-mutt-n-horiguchi@ah.jp.nec.com>
 <52AFF352.2080302@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AFF352.2080302@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dan.carpenter@oracle.com

Hi Sasha,
On Tue, Dec 17, 2013 at 01:46:42AM -0500, Sasha Levin wrote:
>On 12/17/2013 01:11 AM, Naoya Horiguchi wrote:
>> Hello Bob,
>> 
>> On Tue, Dec 17, 2013 at 12:38:49PM +0800, Bob Liu wrote:
>>> On 12/17/2013 09:10 AM, Sasha Levin wrote:
>>>> On 12/16/2013 07:44 PM, Bob Liu wrote:
>>>>>
>>>>> On 12/16/2013 07:37 AM, Sasha Levin wrote:
>>>>>> Hi all,
>>>>>>
>>>>>> While fuzzing with trinity inside a KVM tools guest running latest -next
>>>>>> kernel, I've
>>>>>> stumbled on the following spew.
>>>>>>
>>>>>> This seems to be due to commit 0bf598d863e "mbind: add BUG_ON(!vma) in
>>>>>> new_vma_page()"
>>>>>> which added that BUG_ON.
>>>>>
>>>>> Could you take a try with this patch from Wanpeng Li?
>>>>>
>>>>> Thanks,
>>>>> -Bob
>>>>>
>>>>> Subject: [PATCH] mm/mempolicy: fix !vma in new_vma_page()
>>>>> ....
>>>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>>>> index eca4a31..73b5a35 100644
>>>>> --- a/mm/mempolicy.c
>>>>> +++ b/mm/mempolicy.c
>>>>> @@ -1197,14 +1197,16 @@ static struct page *new_vma_page(struct page
>>>>> *page, unsigned long private, int *
>>>>>                break;
>>>>>            vma = vma->vm_next;
>>>>>        }
>>>>> +
>>>>> +    if (PageHuge(page)) {
>>>>> +        if (vma)
>>>>> +            return alloc_huge_page_noerr(vma, address, 1);
>>>>> +        else
>>>>> +            return NULL;
>>>>> +    }
>>>>>        /*
>>>>> -     * queue_pages_range() confirms that @page belongs to some vma,
>>>>> -     * so vma shouldn't be NULL.
>>>>> +     * if !vma, alloc_page_vma() will use task or system default policy
>>>>>         */
>>>>> -    BUG_ON(!vma);
>>>>> -
>>>>> -    if (PageHuge(page))
>>>>> -        return alloc_huge_page_noerr(vma, address, 1);
>>>>>        return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
>>>>>    }
>>>>>    #else
>>>>>
>>>>
>>>> Hmm... So in essence it's mostly a revert of Naoya's patch, who seemed
>>>> pretty certain that this
>>>> situation shouldn't happen at all. What's the reasoning behind just
>>>
>>> I think this assumption may not correct.
>>> Even if
>>> address = __vma_address(page, vma);
>>> and
>>> vma->start < address < vma->end;
>>> page_address_in_vma() may still return -EFAULT because of many other
>>> conditions in it.
>>> As a result the while loop in new_vma_page() may end with vma=NULL.
>>>
>>> Naoya, any idea?
>> 
>> Yes, you totally make sense. So please apply Wanpeng's patch.
>
>Shouldn't it just be a revert of Naoya's patch? Otherwise we're
>changing code paths unnecessarily.
>

Actually, the original target of Naoya's patch is try to fix potential dereference 
NULL pointer by Dan. http://marc.info/?l=linux-mm&m=137689530323257&w=2 

This patch fix both the regression and potential dereference NULL pointer reported 
by Dan. http://marc.info/?l=linux-kernel&m=138726268626705&w=2

Regards,
Wanpeng Li 

>
>Thanks,
>Sasha
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
