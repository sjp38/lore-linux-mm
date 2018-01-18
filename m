Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA076B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 07:25:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v10so8331684wrv.22
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 04:25:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor4661867edk.31.2018.01.18.04.25.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 04:25:55 -0800 (PST)
Date: Thu, 18 Jan 2018 15:25:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, dave.hansen@linux.intel.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Thu, Jan 18, 2018 at 05:12:45PM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > OK. I missed the mark. I overlooked that 4.11 already has this problem.
> > 
> > I needed to bisect between 4.10 and 4.11, and I got plausible culprit.
> > 
> > I haven't completed bisecting between b4fb8f66f1ae2e16 and c470abd4fde40ea6, but
> > b4fb8f66f1ae2e16 ("mm, page_alloc: Add missing check for memory holes") and
> > 13ad59df67f19788 ("mm, page_alloc: avoid page_to_pfn() when merging buddies")
> > are talking about memory holes, which matches the situation that I'm trivially
> > hitting the bug if CONFIG_SPARSEMEM=y .
> > 
> > Thus, I call for an attention by speculative execution. ;-)
> 
> Speculative execution failed. I was confused by jiffies precision bug.
> The final culprit is c7ab0d2fdc840266 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()").

I think I've tracked it down. check_pte() in mm/page_vma_mapped.c doesn't
work as intended.

I've added instrumentation below to prove it.

The BUG() triggers with following output:

[   10.084024] diff: -858690919
[   10.084258] hpage_nr_pages: 1
[   10.084386] check1: 0
[   10.084478] check2: 0

Basically, pte_page(*pvmw->pte) is below pvmw->page, but
(pte_page(*pvmw->pte) < pvmw->page) doesn't catch it.

Well, I can see how C lawyer can argue that you can only compare pointers
of the same memory object which is not the case here. But this is kinda
insane.

Any suggestions how to rewrite it in a way that compiler would
understand?

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index d22b84310f6d..57b4397f1ea5 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -70,6 +70,14 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
 		}
 		if (pte_page(*pvmw->pte) < pvmw->page)
 			return false;
+
+		if (pte_page(*pvmw->pte) - pvmw->page) {
+			printk("diff: %d\n", pte_page(*pvmw->pte) - pvmw->page);
+			printk("hpage_nr_pages: %d\n", hpage_nr_pages(pvmw->page));
+			printk("check1: %d\n", pte_page(*pvmw->pte) - pvmw->page < 0);
+			printk("check2: %d\n", pte_page(*pvmw->pte) - pvmw->page >= hpage_nr_pages(pvmw->page));
+			BUG();
+		}
 	}
 
 	return true;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
