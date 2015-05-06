Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2675E6B0071
	for <linux-mm@kvack.org>; Tue,  5 May 2015 20:11:23 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so113059217wic.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 17:11:22 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id d2si1552693wix.113.2015.05.05.17.11.20
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 17:11:21 -0700 (PDT)
Date: Wed, 6 May 2015 03:11:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm/thp: Use new function to clear pmd before THP
 splitting
Message-ID: <20150506001105.GA14559@node.dhcp.inet.fi>
References: <1430760556-28137-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430760556-28137-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, May 04, 2015 at 10:59:16PM +0530, Aneesh Kumar K.V wrote:
> Archs like ppc64 require pte_t * to remain stable in some code path.
> They use local_irq_disable to prevent a parallel split. Generic code
> clear pmd instead of marking it _PAGE_SPLITTING in code path
> where we can afford to mark pmd none before splitting. Use a
> variant of pmdp_splitting_clear_notify that arch can override.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Sorry, I still try wrap my head around this problem.

So, Power has __find_linux_pte_or_hugepte() which does lock-less lookup in
page tables with local interrupts disabled. For huge pages it casts pmd_t
to pte_t. Since format of pte_t is different from pmd_t we want to prevent
transit from pmd pointing to page table to pmd pinging to huge page (and
back) while interrupts are disabled.

The complication for Power is that it doesn't do implicit IPI on tlb
flush.

Is it correct?

For THP, split_huge_page() and collapse sides are covered. This patch
should address two cases of splitting PMD, but not compound page in
current upstream.

But I think there's still *big* problem for Power -- zap_huge_pmd().

For instance: other CPU can shoot out a THP PMD with MADV_DONTNEED and
fault in small pages instead. IIUC, for __find_linux_pte_or_hugepte(),
it's equivalent of splitting.

I don't see how this can be fixed without kick_all_cpus_sync() in all
pmdp_clear_flush() on Power.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
