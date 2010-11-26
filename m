Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 657D48D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 13:02:29 -0500 (EST)
Date: Fri, 26 Nov 2010 19:01:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 11 of 66] add pmd paravirt ops
Message-ID: <20101126180141.GZ6118@random.random>
References: <patchbomb.1288798055@v2.random>
 <19e5af8e27282a543e50.1288798066@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19e5af8e27282a543e50.1288798066@v2.random>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:27:46PM +0100, Andrea Arcangeli wrote:
> @@ -543,6 +554,18 @@ static inline void set_pte_at(struct mm_
>  		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> +			      pmd_t *pmdp, pmd_t pmd)
> +{
> +	if (sizeof(pmdval_t) > sizeof(long))
> +		/* 5 arg words */
> +		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
> +	else
> +		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp, pmd.pmd);
> +}
> +#endif
> +
>  static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
>  	pmdval_t val = native_pmd_val(pmd);

btw, I noticed the 32bit build with HIGHMEM off, paravirt on, and THP
on fails without this below change (that configuration clearly has
never been tested for build), so I'm merging this in the above quoted
patch.

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -558,11 +558,13 @@ static inline void set_pte_at(struct mm_
 static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 			      pmd_t *pmdp, pmd_t pmd)
 {
+#if PAGETABLE_LEVELS >= 3
 	if (sizeof(pmdval_t) > sizeof(long))
 		/* 5 arg words */
 		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
 	else
 		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp, pmd.pmd);
+#endif
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
