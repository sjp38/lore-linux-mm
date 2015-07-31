Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B3AFA9003C7
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 17:25:46 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so48469515pdb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:25:46 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id pd8si12951069pac.123.2015.07.31.14.25.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 14:25:46 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so48469379pdb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:25:45 -0700 (PDT)
Date: Fri, 31 Jul 2015 14:25:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to
 __alloc_pages_node
In-Reply-To: <55BA822B.3020508@suse.cz>
Message-ID: <alpine.DEB.2.10.1507311423310.5910@chino.kir.corp.google.com>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.11.1507301255380.5521@east.gentwo.org> <55BA822B.3020508@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Michael Ellerman <mpe@ellerman.id.au>, Robin Holt <robinmholt@gmail.com>

On Thu, 30 Jul 2015, Vlastimil Babka wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index aa58a32..56355f2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2469,7 +2469,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
>  	 */
>  	up_read(&mm->mmap_sem);
>  
> -	*hpage = alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
> +	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
>  	if (unlikely(!*hpage)) {
>  		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>  		*hpage = ERR_PTR(-ENOMEM);
> @@ -2568,9 +2568,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  
> -	/* Only allocate from the target node */
> -	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
> -		__GFP_THISNODE;
> +	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), 0);
>  
>  	/* release the mmap_sem read lock. */
>  	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);

Hmm, where is the __GFP_THISNODE enforcement in khugepaged_alloc_page() 
that is removed in collapse_huge_page()?  I also don't see what happened 
to the __GFP_OTHER_NODE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
