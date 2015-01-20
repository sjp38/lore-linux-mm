Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5456B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 04:08:19 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so10965865wid.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 01:08:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si9902583wjn.77.2015.01.20.01.08.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 01:08:18 -0800 (PST)
Message-ID: <54BE1B00.3090102@suse.cz>
Date: Tue, 20 Jan 2015 10:08:16 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org> <54BD308A.4080905@suse.cz> <87fvb6uhfp.fsf@linux.vnet.ibm.com>
In-Reply-To: <87fvb6uhfp.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/20/2015 06:52 AM, Aneesh Kumar K.V wrote:
> Vlastimil Babka <vbabka@suse.cz> writes:
> 
>> On 01/17/2015 01:02 AM, Andrew Morton wrote:
>>> On Fri, 16 Jan 2015 12:56:36 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>> 
>>>> This make sure that we try to allocate hugepages from local node if
>>>> allowed by mempolicy. If we can't, we fallback to small page allocation
>>>> based on mempolicy. This is based on the observation that allocating pages
>>>> on local node is more beneficial than allocating hugepages on remote node.
>>> 
>>> The changelog is a bit incomplete.  It doesn't describe the current
>>> behaviour, nor what is wrong with it.  What are the before-and-after
>>> effects of this change?
>>> 
>>> And what might be the user-visible effects?
>>> 
>>>> --- a/mm/mempolicy.c
>>>> +++ b/mm/mempolicy.c
>>>> @@ -2030,6 +2030,46 @@ retry_cpuset:
>>>>  	return page;
>>>>  }
>>>>  
>>>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>>>> +				unsigned long addr, int order)
>>> 
>>> alloc_pages_vma() is nicely documented.  alloc_hugepage_vma() is not
>>> documented at all.  This makes it a bit had for readers to work out the
>>> difference!
>>> 
>>> Is it possible to scrunch them both into the same function?  Probably
>>> too messy?
>>
>> Hm that could work, alloc_pages_vma already has an if (MPOL_INTERLEAVE) part, so
>> just put the THP specialities into an "else if (huge_page)" part there?
>>
>> You could probably test for GFP_TRANSHUGE the same way as __alloc_pages_slowpath
>> does. There might be false positives theoretically, but is there anything else
>> that would use these flags and not be a THP?
>>
> 
> is that check correct ? ie, 
> 
> if ((gfp & GFP_TRANSHUGE) == GFP_TRANSHUGE)
> 
> may not always indicate transparent hugepage if defrag = 0 . With defrag
> cleared, we remove __GFP_WAIT from GFP_TRANSHUGE.

Yep, that looks wrong. Sigh. I guess we can't spare an extra GFP flag to
indicate TRANSHUGE?

> static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
> {
> 	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
> }
> 
> -aneesh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
