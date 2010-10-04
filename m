Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5896B0047
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 23:26:34 -0400 (EDT)
Date: Mon, 4 Oct 2010 12:24:51 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: Transparent Hugepage Support #30
Message-ID: <20101004032451.GA11622@spritzera.linux.bs1.fc.nec.co.jp>
References: <20100901190859.GA20316@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100901190859.GA20316@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hi,

I experienced build error of "calling pte_alloc_map() with 3 parameters, 
while it's defined to have 4 parameters" in arch/x86/kernel/tboot.c etc.
Is the following chunk in patch "pte alloc trans splitting" necessary?

@@ -1167,16 +1168,18 @@ static inline void pgtable_page_dtor(struct page *page)
        pte_unmap(pte);                                 \
 } while (0)
 
-#define pte_alloc_map(mm, pmd, address)                        \
-       ((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-               NULL: pte_offset_map(pmd, address))
+#define pte_alloc_map(mm, vma, pmd, address)                           \
+       ((unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, vma,    \
+                                                       pmd, address))? \
+        NULL: pte_offset_map(pmd, address))
 
Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
