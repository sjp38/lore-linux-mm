Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id AED646B0070
	for <linux-mm@kvack.org>; Fri, 15 May 2015 07:43:31 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so58664199wic.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 04:43:31 -0700 (PDT)
Received: from johanna2.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id m15si580225wiv.119.2015.05.15.04.43.30
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 04:43:30 -0700 (PDT)
Date: Fri, 15 May 2015 14:43:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 01/28] mm, proc: adjust PSS calculation
Message-ID: <20150515114314.GF6250@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-2-git-send-email-kirill.shutemov@linux.intel.com>
 <5554AD4D.9040000@suse.cz>
 <20150515105621.GA6250@node.dhcp.inet.fi>
 <5555D98B.7010900@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5555D98B.7010900@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 01:33:31PM +0200, Vlastimil Babka wrote:
> On 05/15/2015 12:56 PM, Kirill A. Shutemov wrote:
> >On Thu, May 14, 2015 at 04:12:29PM +0200, Vlastimil Babka wrote:
> >>On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >>>With new refcounting all subpages of the compound page are not nessessary
> >>>have the same mapcount. We need to take into account mapcount of every
> >>>sub-page.
> >>>
> >>>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >>>Tested-by: Sasha Levin <sasha.levin@oracle.com>
> >>
> >>Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >>
> >>(some nitpicks below)
> >>
> >>>---
> >>>  fs/proc/task_mmu.c | 43 ++++++++++++++++++++++---------------------
> >>>  1 file changed, 22 insertions(+), 21 deletions(-)
> >>>
> >>>diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >>>index 956b75d61809..95bc384ee3f7 100644
> >>>--- a/fs/proc/task_mmu.c
> >>>+++ b/fs/proc/task_mmu.c
> >>>@@ -449,9 +449,10 @@ struct mem_size_stats {
> >>>  };
> >>>
> >>>  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> >>>-		unsigned long size, bool young, bool dirty)
> >>>+		bool compound, bool young, bool dirty)
> >>>  {
> >>>-	int mapcount;
> >>>+	int i, nr = compound ? hpage_nr_pages(page) : 1;
> >>
> >>Why not just HPAGE_PMD_NR instead of hpage_nr_pages(page)?
> >
> >Okay, makes sense. Compiler is smart enough to optimize away HPAGE_PMD_NR
> >for THP=n. (HPAGE_PMD_NR is BUILD_BUG() for THP=n)
> 
> Ah, BUILD_BUG()... I'm not sure we can rely on optimization to avoid
> BUILD_BUG(), what if somebody compiles with all optimizations off?

Kernel relies on dead-code elimination. You cannot build kernel with -O0.

> So why not replace BUILD_BUG() with "1", or create a variant of HPAGE_PMD_NR
> that does that, for this case and patch 3. Seems better than testing
> PageTransHuge everywhere...

I think we could try to downgrade it BUG(). Although I found BUILD_BUG()
useful few times.

HPAGE_PMD_NR==1 would be just wrong. It would mean you can map order-0
page with PMD %-|

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
