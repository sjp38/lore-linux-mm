Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9B86B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 00:53:35 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so43414087pad.9
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 21:53:35 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id vr2si3178354pbc.134.2015.01.19.21.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 21:53:33 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 20 Jan 2015 15:53:27 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C514A2CE8040
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 16:53:23 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0K5rMAi39387162
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 16:53:23 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0K5rLFl005109
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 16:53:22 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
In-Reply-To: <54BD308A.4080905@suse.cz>
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org> <54BD308A.4080905@suse.cz>
Date: Tue, 20 Jan 2015 11:22:58 +0530
Message-ID: <87fvb6uhfp.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Vlastimil Babka <vbabka@suse.cz> writes:

> On 01/17/2015 01:02 AM, Andrew Morton wrote:
>> On Fri, 16 Jan 2015 12:56:36 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> 
>>> This make sure that we try to allocate hugepages from local node if
>>> allowed by mempolicy. If we can't, we fallback to small page allocation
>>> based on mempolicy. This is based on the observation that allocating pages
>>> on local node is more beneficial than allocating hugepages on remote node.
>> 
>> The changelog is a bit incomplete.  It doesn't describe the current
>> behaviour, nor what is wrong with it.  What are the before-and-after
>> effects of this change?
>> 
>> And what might be the user-visible effects?
>> 
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -2030,6 +2030,46 @@ retry_cpuset:
>>>  	return page;
>>>  }
>>>  
>>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>>> +				unsigned long addr, int order)
>> 
>> alloc_pages_vma() is nicely documented.  alloc_hugepage_vma() is not
>> documented at all.  This makes it a bit had for readers to work out the
>> difference!
>> 
>> Is it possible to scrunch them both into the same function?  Probably
>> too messy?
>
> Hm that could work, alloc_pages_vma already has an if (MPOL_INTERLEAVE) part, so
> just put the THP specialities into an "else if (huge_page)" part there?
>
> You could probably test for GFP_TRANSHUGE the same way as __alloc_pages_slowpath
> does. There might be false positives theoretically, but is there anything else
> that would use these flags and not be a THP?
>

is that check correct ? ie, 

if ((gfp & GFP_TRANSHUGE) == GFP_TRANSHUGE)

may not always indicate transparent hugepage if defrag = 0 . With defrag
cleared, we remove __GFP_WAIT from GFP_TRANSHUGE.

static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
{
	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
}

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
