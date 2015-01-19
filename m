Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBB96B0038
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 11:27:59 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so9808517wiv.4
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 08:27:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si26939467wjx.63.2015.01.19.08.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 08:27:56 -0800 (PST)
Message-ID: <54BD308A.4080905@suse.cz>
Date: Mon, 19 Jan 2015 17:27:54 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org>
In-Reply-To: <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/17/2015 01:02 AM, Andrew Morton wrote:
> On Fri, 16 Jan 2015 12:56:36 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
>> This make sure that we try to allocate hugepages from local node if
>> allowed by mempolicy. If we can't, we fallback to small page allocation
>> based on mempolicy. This is based on the observation that allocating pages
>> on local node is more beneficial than allocating hugepages on remote node.
> 
> The changelog is a bit incomplete.  It doesn't describe the current
> behaviour, nor what is wrong with it.  What are the before-and-after
> effects of this change?
> 
> And what might be the user-visible effects?
> 
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2030,6 +2030,46 @@ retry_cpuset:
>>  	return page;
>>  }
>>  
>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>> +				unsigned long addr, int order)
> 
> alloc_pages_vma() is nicely documented.  alloc_hugepage_vma() is not
> documented at all.  This makes it a bit had for readers to work out the
> difference!
> 
> Is it possible to scrunch them both into the same function?  Probably
> too messy?

Hm that could work, alloc_pages_vma already has an if (MPOL_INTERLEAVE) part, so
just put the THP specialities into an "else if (huge_page)" part there?

You could probably test for GFP_TRANSHUGE the same way as __alloc_pages_slowpath
does. There might be false positives theoretically, but is there anything else
that would use these flags and not be a THP?



>> +{
>> +	struct page *page;
>> +	nodemask_t *nmask;
>> +	struct mempolicy *pol;
>> +	int node = numa_node_id();
>> +	unsigned int cpuset_mems_cookie;
>> +
>> +retry_cpuset:
>> +	pol = get_vma_policy(vma, addr);
>> +	cpuset_mems_cookie = read_mems_allowed_begin();
>> +
>> +	if (pol->mode != MPOL_INTERLEAVE) {
>> +		/*
>> +		 * For interleave policy, we don't worry about
>> +		 * current node. Otherwise if current node is
>> +		 * in nodemask, try to allocate hugepage from
>> +		 * current node. Don't fall back to other nodes
>> +		 * for THP.
>> +		 */
> 
> This code isn't "interleave policy".  It's everything *but* interleave
> policy.  Comment makes no sense!
> 
>> +		nmask = policy_nodemask(gfp, pol);
>> +		if (!nmask || node_isset(node, *nmask)) {
>> +			mpol_cond_put(pol);
>> +			page = alloc_pages_exact_node(node, gfp, order);
>> +			if (unlikely(!page &&
>> +				     read_mems_allowed_retry(cpuset_mems_cookie)))
>> +				goto retry_cpuset;
>> +			return page;
>> +		}
>> +	}
>> +	mpol_cond_put(pol);
>> +	/*
>> +	 * if current node is not part of node mask, try
>> +	 * the allocation from any node, and we can do retry
>> +	 * in that case.
>> +	 */
>> +	return alloc_pages_vma(gfp, order, vma, addr, node);
>> +}
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
