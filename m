Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B785B6B0085
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:20:09 -0400 (EDT)
Date: Tue, 5 Oct 2010 21:18:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage Support #30
Message-ID: <20101005191837.GY26357@random.random>
References: <20100901190859.GA20316@random.random>
 <20101004032451.GA11622@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101004032451.GA11622@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hi Naoya,

On Mon, Oct 04, 2010 at 12:24:51PM +0900, Naoya Horiguchi wrote:
> Hi,
> 
> I experienced build error of "calling pte_alloc_map() with 3 parameters, 
> while it's defined to have 4 parameters" in arch/x86/kernel/tboot.c etc.
> Is the following chunk in patch "pte alloc trans splitting" necessary?
> 
> @@ -1167,16 +1168,18 @@ static inline void pgtable_page_dtor(struct page *page)
>         pte_unmap(pte);                                 \
>  } while (0)
>  
> -#define pte_alloc_map(mm, pmd, address)                        \
> -       ((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
> -               NULL: pte_offset_map(pmd, address))
> +#define pte_alloc_map(mm, vma, pmd, address)                           \
> +       ((unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, vma,    \
> +                                                       pmd, address))? \
> +        NULL: pte_offset_map(pmd, address))

Sure it's necessary.

Can you try again with current aa.git origin/master?
(84c5ce35cf221ed0e561dec279df6985a388a080) Thanks a lot.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
