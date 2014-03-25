Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 963D56B003A
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:38:55 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gf5so637374lab.35
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 10:38:54 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id zv8si12795496lbb.83.2014.03.25.10.38.52
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 10:38:52 -0700 (PDT)
Date: Tue, 25 Mar 2014 19:36:05 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/1] mm: move FAULT_AROUND_ORDER to arch/
Message-ID: <20140325173605.GA21411@node.dhcp.inet.fi>
References: <1395730215-11604-1-git-send-email-maddy@linux.vnet.ibm.com>
 <1395730215-11604-2-git-send-email-maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395730215-11604-2-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On Tue, Mar 25, 2014 at 12:20:15PM +0530, Madhavan Srinivasan wrote:
> Kirill A. Shutemov with the commit 96bacfe542 introduced
> vm_ops->map_pages() for mapping easy accessible pages around
> fault address in hope to reduce number of minor page faults.
> Based on his workload runs, suggested FAULT_AROUND_ORDER
> (knob to control the numbers of pages to map) is 4.
> 
> This patch moves the FAULT_AROUND_ORDER macro to arch/ for
> architecture maintainers to decide on suitable FAULT_AROUND_ORDER
> value based on performance data for that architecture.
> 
> Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/pgtable.h |    6 ++++++
>  arch/x86/include/asm/pgtable.h     |    5 +++++
>  include/asm-generic/pgtable.h      |   10 ++++++++++
>  mm/memory.c                        |    2 --
>  4 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
> index 3ebb188..9fcbd48 100644
> --- a/arch/powerpc/include/asm/pgtable.h
> +++ b/arch/powerpc/include/asm/pgtable.h
> @@ -19,6 +19,12 @@ struct mm_struct;
>  #endif
>  
>  /*
> + * With a few real world workloads that were run,
> + * the performance data showed that a value of 3 is more advantageous.
> + */
> +#define FAULT_AROUND_ORDER	3
> +
> +/*
>   * We save the slot number & secondary bit in the second half of the
>   * PTE page. We use the 8 bytes per each pte entry.
>   */
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 938ef1d..8387a65 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -7,6 +7,11 @@
>  #include <asm/pgtable_types.h>
>  
>  /*
> + * Based on Kirill's test results, fault around order is set to 4
> + */
> +#define FAULT_AROUND_ORDER 4
> +
> +/*
>   * Macro to mark a page protection value as UC-
>   */
>  #define pgprot_noncached(prot)					\
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 1ec08c1..62f7f07 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -7,6 +7,16 @@
>  #include <linux/mm_types.h>
>  #include <linux/bug.h>
>  
> +
> +/*
> + * Fault around order is a control knob to decide the fault around pages.
> + * Default value is set to 0UL (disabled), but the arch can override it as
> + * desired.
> + */
> +#ifndef FAULT_AROUND_ORDER
> +#define FAULT_AROUND_ORDER	0UL
> +#endif

FAULT_AROUND_ORDER == 0 case should be handled separately in
do_read_fault(): no reason to go to do_fault_around() if we are going to
fault in only one page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
