Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C5D646B005A
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 00:47:26 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2383773qcs.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 21:47:25 -0700 (PDT)
Date: Sat, 30 Jun 2012 00:47:18 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 04/40] xen: document Xen is using an unused bit for the
 pagetables
Message-ID: <20120630044700.GA3975@localhost.localdomain>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340888180-15355-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jun 28, 2012 at 02:55:44PM +0200, Andrea Arcangeli wrote:
> Xen has taken over the last reserved bit available for the pagetables

Some time ago when I saw this patch I asked about it (if there is way
to actually stop using this bit) and you mentioned it is not the last
bit available for pagemaps. Perhaps you should alter the comment
in this description?

> which is set through ioremap, this documents it and makes the code

It actually is through ioremap, gntdev (to map another guest memory),
and on pfns which fall in E820 on the non-RAM and gap sections.

> more readable.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  arch/x86/include/asm/pgtable_types.h |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 013286a..b74cac9 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -17,7 +17,7 @@
>  #define _PAGE_BIT_PAT		7	/* on 4KB pages */
>  #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
>  #define _PAGE_BIT_UNUSED1	9	/* available for programmer */
> -#define _PAGE_BIT_IOMAP		10	/* flag used to indicate IO mapping */
> +#define _PAGE_BIT_UNUSED2	10
>  #define _PAGE_BIT_HIDDEN	11	/* hidden by kmemcheck */
>  #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
>  #define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
> @@ -41,7 +41,7 @@
>  #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
>  #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
>  #define _PAGE_UNUSED1	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED1)
> -#define _PAGE_IOMAP	(_AT(pteval_t, 1) << _PAGE_BIT_IOMAP)
> +#define _PAGE_UNUSED2	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED2)
>  #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
>  #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
>  #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
> @@ -49,6 +49,13 @@
>  #define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
>  #define __HAVE_ARCH_PTE_SPECIAL
>  
> +/* flag used to indicate IO mapping */
> +#ifdef CONFIG_XEN
> +#define _PAGE_IOMAP	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED2)
> +#else
> +#define _PAGE_IOMAP	(_AT(pteval_t, 0))
> +#endif
> +
>  #ifdef CONFIG_KMEMCHECK
>  #define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
>  #else
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
