Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F11B900002
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 17:36:35 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so1990085iga.7
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 14:36:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k4si10024343igx.63.2014.07.09.14.36.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 14:36:34 -0700 (PDT)
Date: Wed, 9 Jul 2014 17:36:24 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 13/13] mincore: apply page table walker on do_mincore()
Message-ID: <20140709213624.GC24698@nhori>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404234451-21695-14-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140709133436.GA18391@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140709133436.GA18391@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 09, 2014 at 04:34:36PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 01, 2014 at 01:07:31PM -0400, Naoya Horiguchi wrote:
> > This patch makes do_mincore() use walk_page_vma(), which reduces many lines
> > of code by using common page table walk code.
> > 
> > ChangeLog v4:
> > - remove redundant vma
> > 
> > ChangeLog v3:
> > - add NULL vma check in mincore_unmapped_range()
> > - don't use pte_entry()
> > 
> > ChangeLog v2:
> > - change type of args of callbacks to void *
> > - move definition of mincore_walk to the start of the function to fix compiler
> >   warning
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Trinity crases this implementation of mincore pretty easily:
> 
> [   42.775369] BUG: unable to handle kernel paging request at ffff88007bb61000
> [   42.776656] IP: [<ffffffff81126f8f>] mincore_unmapped_range+0xdf/0x100

Thanks for your testing/reporting.

...
> 
> Looks like 'vec' overflow. I don't see what could prevent do_mincore() to
> write more than PAGE_SIZE to 'vec'.

I found the miscalculation of walk->private (vec) on thp and hugetlbfs.
I confirmed that the reported problem is fixed (I checked that trinity
never triggers the reported BUG) with the following changes on this patch.

diff --git a/mm/mincore.c b/mm/mincore.c
index 3c64dcbcb3e2..9eb10d867a6f 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -34,7 +34,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 	present = pte && !huge_pte_none(huge_ptep_get(pte));
 	for (; addr != end; vec++, addr += PAGE_SIZE)
 		*vec = present;
-	walk->private += (end - addr) >> PAGE_SHIFT;
+	walk->private = vec;
 #else
 	BUG();
 #endif
@@ -118,8 +118,10 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		return 0;
 	}
 
-	if (pmd_trans_unstable(pmd))
+	if (pmd_trans_unstable(pmd)) {
+		walk->private += (end - addr) >> PAGE_SHIFT;
 		return 0;
+	}
 
 	ptep = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; ptep++, addr += PAGE_SIZE) {

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
