Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 35FB96B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 17:45:50 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so50305053wib.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:45:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dl3si8247446wib.41.2015.07.31.14.45.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 14:45:48 -0700 (PDT)
Message-ID: <55BBEC86.1070307@suse.cz>
Date: Fri, 31 Jul 2015 23:45:42 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to __alloc_pages_node
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.11.1507301255380.5521@east.gentwo.org> <55BA822B.3020508@suse.cz> <alpine.DEB.2.10.1507311423310.5910@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507311423310.5910@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Michael Ellerman <mpe@ellerman.id.au>, Robin Holt <robinmholt@gmail.com>

On 31.7.2015 23:25, David Rientjes wrote:
> On Thu, 30 Jul 2015, Vlastimil Babka wrote:
> 
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index aa58a32..56355f2 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2469,7 +2469,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
>>  	 */
>>  	up_read(&mm->mmap_sem);
>>  
>> -	*hpage = alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
>> +	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
>>  	if (unlikely(!*hpage)) {
>>  		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>>  		*hpage = ERR_PTR(-ENOMEM);
>> @@ -2568,9 +2568,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>>  
>>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>>  
>> -	/* Only allocate from the target node */
>> -	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
>> -		__GFP_THISNODE;
>> +	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), 0);
>>  
>>  	/* release the mmap_sem read lock. */
>>  	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
> 
> Hmm, where is the __GFP_THISNODE enforcement in khugepaged_alloc_page() 
> that is removed in collapse_huge_page()?  I also don't see what happened 
> to the __GFP_OTHER_NODE.

Crap, I messed up with git, this hunk was supposed to be gone. Thanks for
noticing. Please apply without the collapse_huge_page hunk, or tell me to resend
once more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
