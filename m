Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3266B0074
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 10:43:38 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so15601313pdb.18
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 07:43:38 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id ty10si21365469pbc.66.2014.12.03.07.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 07:43:36 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 3 Dec 2014 21:13:32 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6422F125805F
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 21:13:49 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB3FhKIF58851434
	for <linux-mm@kvack.org>; Wed, 3 Dec 2014 21:13:20 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB3Fh7xW002304
	for <linux-mm@kvack.org>; Wed, 3 Dec 2014 21:13:07 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm/thp: Allocate transparent hugepages on local node
In-Reply-To: <547DD100.30307@suse.cz>
References: <1417412803-27234-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141201113340.GA545@node.dhcp.inet.fi> <87vblvh3b9.fsf@linux.vnet.ibm.com> <547DD100.30307@suse.cz>
Date: Wed, 03 Dec 2014 21:13:06 +0530
Message-ID: <87fvcwbuyd.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Vlastimil Babka <vbabka@suse.cz> writes:

> On 12/01/2014 03:06 PM, Aneesh Kumar K.V wrote:
>> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>>
>>> On Mon, Dec 01, 2014 at 11:16:43AM +0530, Aneesh Kumar K.V wrote:
>>>> This make sure that we try to allocate hugepages from local node if
>>>> allowed by mempolicy. If we can't, we fallback to small page allocation
>>>> based on mempolicy. This is based on the observation that allocating pages
>>>> on local node is more beneficial that allocating hugepages on remote node.
>>>>
........
......

>>>> index e58725aff7e9..fa96af5b31f7 100644
>>>> --- a/mm/mempolicy.c
>>>> +++ b/mm/mempolicy.c
>>>> @@ -2041,6 +2041,46 @@ retry_cpuset:
>>>>   	return page;
>>>>   }
>>>>
>>>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>>>> +				unsigned long addr, int order)
>
> It's somewhat confusing that the name talks about hugepages, yet you 
> have to supply the order and gfp. Only the policy handling is tailored 
> for hugepages. But maybe it's better than calling the function 
> "alloc_pages_vma_local_only_unless_interpolate" :/
>

I did try to do an API that does

struct page *alloc_hugepage_vma(struct vm_area_struct *vma, unsigned long addr)

But that will result in further #ifdef in mm/mempolicy, because we will
then introduce transparent_hugepage_defrag(vma) and HPAGE_PMD_ORDER
there. I was not sure whether we really wanted that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
