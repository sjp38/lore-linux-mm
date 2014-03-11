Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E6B056B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:47:01 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so11472pab.23
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:47:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id nc6si11295pbc.293.2014.03.11.12.47.00
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 12:47:01 -0700 (PDT)
Date: Tue, 11 Mar 2014 12:46:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] mm/vmalloc: avoid soft lockup warnings when
 vunmap()'ing large ranges
Message-Id: <20140311124659.9565a5cc86ade7084eabe24d@linux-foundation.org>
In-Reply-To: <1394563223-5045-1-git-send-email-david.vrabel@citrix.com>
References: <1394563223-5045-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Dietmar Hahn <dietmar.hahn@ts.fujitsu.com>

On Tue, 11 Mar 2014 18:40:23 +0000 David Vrabel <david.vrabel@citrix.com> wrote:

> If vunmap() is used to unmap a large (e.g., 50 GB) region, it may take
> sufficiently long that it triggers soft lockup warnings.
> 
> Add a cond_resched() into vunmap_pmd_range() so the calling task may
> be resheduled after unmapping each PMD entry.  This is how
> zap_pmd_range() fixes the same problem for userspace mappings.
> 
> All callers may sleep except for the APEI GHES driver (apei/ghes.c)
> which calls unmap_kernel_range_no_flush() from NMI and IRQ contexts.
> This driver only unmaps a single pages so don't call cond_resched() if
> the unmap doesn't cross a PMD boundary.
> 
> Reported-by: Dietmar Hahn <dietmar.hahn@ts.fujitsu.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
> v2: don't call cond_resched() at the end of a PMD range.
> ---
>  mm/vmalloc.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0fdf968..1a8b162 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -75,6 +75,8 @@ static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
>  		if (pmd_none_or_clear_bad(pmd))
>  			continue;
>  		vunmap_pte_range(pmd, addr, next);
> +		if (next != end)
> +			cond_resched();
>  	} while (pmd++, addr = next, addr != end);
>  }

Worried.  This adds a schedule into a previously atomic function.  Are
there any callers which call into here from interrupt or with a lock
held, etc?

I started doing an audit, got to
mvebu_hwcc_dma_ops.free->__dma_free_remap->unmap_kernel_range->vunmap_page_range
and gave up - there's just too much.

The best I can suggest is to do

--- a/mm/vmalloc.c~mm-vmalloc-avoid-soft-lockup-warnings-when-vunmaping-large-ranges-fix
+++ a/mm/vmalloc.c
@@ -71,6 +71,8 @@ static void vunmap_pmd_range(pud_t *pud,
 	pmd_t *pmd;
 	unsigned long next;
 
+	might_sleep();
+
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);

so we at least find out about bugs promptly, but that's a pretty lame
approach.

Who the heck is mapping 50GB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
