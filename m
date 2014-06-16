Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7356B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:44:54 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id hw13so6508709qab.17
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:44:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c10si13908797qab.7.2014.06.16.09.44.53
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 09:44:54 -0700 (PDT)
Date: Mon, 16 Jun 2014 12:44:49 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 7/7] mincore: apply page table walker on do_mincore()
Message-ID: <20140616164449.GB13264@nhori.bos.redhat.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1402095520-10109-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <539F0C20.10101@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539F0C20.10101@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>

Hi Sasha,

Thanks for bug reporting.

On Mon, Jun 16, 2014 at 11:24:16AM -0400, Sasha Levin wrote:
> On 06/06/2014 06:58 PM, Naoya Horiguchi wrote:
> > This patch makes do_mincore() use walk_page_vma(), which reduces many lines
> > of code by using common page table walk code.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Hi Naoya,
> 
> This patch is causing a few issues on -next:
> 
> [  367.679282] BUG: sleeping function called from invalid context at mm/mincore.c:37

cond_resched() in mincore_hugetlb() triggered this. This is done in common
pagewalk code, so I should have removed it.

...
> And:
> 
> [  391.118663] BUG: unable to handle kernel paging request at ffff880142aca000
> [  391.118663] IP: mincore_hole (mm/mincore.c:99 (discriminator 2))

walk->pte_hole cannot assume walk->vma != NULL, so I should've checked it
in mincore_hole() before using walk->vma.

Could you try the following fixes?

Thanks,
Naoya Horiguchi
---
diff --git a/mm/mincore.c b/mm/mincore.c
index d8a5e9f62268..3261788369bd 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -34,7 +34,6 @@ static int mincore_hugetlb(pte_t *pte, unsigned long addr,
 	present = pte && !huge_pte_none(huge_ptep_get(pte));
 	for (; addr != end; vec++, addr += PAGE_SIZE)
 		*vec = present;
-	cond_resched();
 	walk->private += (end - addr) >> PAGE_SHIFT;
 #else
 	BUG();
@@ -91,7 +90,7 @@ static int mincore_hole(unsigned long addr, unsigned long end,
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
 
-	if (vma->vm_file) {
+	if (vma && vma->vm_file) {
 		pgoff_t pgoff;
 
 		pgoff = linear_page_index(vma, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
