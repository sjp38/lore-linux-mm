Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA6D6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 21:42:34 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so673935pdb.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:42:34 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id r10si25481187pdp.125.2015.01.12.18.42.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 18:42:33 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 13 Jan 2015 12:42:26 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 08EC92BB0023
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:42:22 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0D2gLlK49741896
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:42:21 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0D2gLB8020910
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:42:21 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm/thp: Allocate transparent hugepages on local node
In-Reply-To: <87fvcwbuyd.fsf@linux.vnet.ibm.com>
References: <1417412803-27234-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141201113340.GA545@node.dhcp.inet.fi> <87vblvh3b9.fsf@linux.vnet.ibm.com> <547DD100.30307@suse.cz> <87fvcwbuyd.fsf@linux.vnet.ibm.com>
Date: Tue, 13 Jan 2015 08:12:10 +0530
Message-ID: <87vbkb7665.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Vlastimil Babka <vbabka@suse.cz> writes:
>
>> On 12/01/2014 03:06 PM, Aneesh Kumar K.V wrote:
>>> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>>>
>>>> On Mon, Dec 01, 2014 at 11:16:43AM +0530, Aneesh Kumar K.V wrote:
>>>>> This make sure that we try to allocate hugepages from local node if
>>>>> allowed by mempolicy. If we can't, we fallback to small page allocation
>>>>> based on mempolicy. This is based on the observation that allocating pages
>>>>> on local node is more beneficial that allocating hugepages on remote node.
>>>>>
> ........
> ......
>
>>>>> index e58725aff7e9..fa96af5b31f7 100644
>>>>> --- a/mm/mempolicy.c
>>>>> +++ b/mm/mempolicy.c
>>>>> @@ -2041,6 +2041,46 @@ retry_cpuset:
>>>>>   	return page;
>>>>>   }
>>>>>
>>>>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>>>>> +				unsigned long addr, int order)
>>
>> It's somewhat confusing that the name talks about hugepages, yet you 
>> have to supply the order and gfp. Only the policy handling is tailored 
>> for hugepages. But maybe it's better than calling the function 
>> "alloc_pages_vma_local_only_unless_interpolate" :/
>>
>
> I did try to do an API that does
>
> struct page *alloc_hugepage_vma(struct vm_area_struct *vma, unsigned long addr)
>
> But that will result in further #ifdef in mm/mempolicy, because we will
> then introduce transparent_hugepage_defrag(vma) and HPAGE_PMD_ORDER
> there. I was not sure whether we really wanted that.
>

Any update on this ? Should I resend the patch rebasing it to the latest
upstream ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
