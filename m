Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 707C5900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 14:41:39 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id e89so4345408qgf.8
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 11:41:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m10si22124591qaz.46.2014.10.27.11.41.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 11:41:38 -0700 (PDT)
Date: Mon, 27 Oct 2014 19:41:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
Message-ID: <20141027184115.GX6911@redhat.com>
References: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
 <20141023.184035.388557314666522484.davem@davemloft.net>
 <1414107635.364.91.camel@pasglop>
 <1414167761.19984.17.camel@jarvis.lan>
 <1414356641.364.142.camel@pasglop>
 <20141027001842.GU6911@redhat.com>
 <87fve9xulq.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fve9xulq.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, steve.capper@linaro.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org

Hi Aneesh,

On Mon, Oct 27, 2014 at 11:28:41PM +0530, Aneesh Kumar K.V wrote:
> 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> 	if (pmd_trans_huge(*pmdp)) {
> 		pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
> 	} else {

The only problematic path that needs IPI is the below one yes.

> 		/*
> 		 * khugepaged calls this for normal pmd
> 		 */
> 		pmd = *pmdp;
> 		pmd_clear(pmdp);
> 		/*
> 		 * Wait for all pending hash_page to finish. This is needed
> 		 * in case of subpage collapse. When we collapse normal pages
> 		 * to hugepage, we first clear the pmd, then invalidate all
> 		 * the PTE entries. The assumption here is that any low level
> 		 * page fault will see a none pmd and take the slow path that
> 		 * will wait on mmap_sem. But we could very well be in a
> 		 * hash_page with local ptep pointer value. Such a hash page
> 		 * can result in adding new HPTE entries for normal subpages.
> 		 * That means we could be modifying the page content as we
> 		 * copy them to a huge page. So wait for parallel hash_page
> 		 * to finish before invalidating HPTE entries. We can do this
> 		 * by sending an IPI to all the cpus and executing a dummy
> 		 * function there.
> 		 */
> 		kick_all_cpus_sync();
>
> We already do an IPI for ppc64.

Agreed, ppc64 is already covered.

sparc/arm seem to be using the generic pmdp_clear_flush implementation
instead, which just calls flush_tlb_range, so perhaps they aren't.

As above, the IPIs are only needed if the *pmd is not transhuge.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
