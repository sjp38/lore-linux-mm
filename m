Message-ID: <48C63E28.6060605@evidence.eu.com>
Date: Tue, 09 Sep 2008 11:13:12 +0200
From: Claudio Scordino <claudio@evidence.eu.com>
MIME-Version: 1.0
Subject: Remove warning in compilation of ioremap
Content-Type: multipart/mixed;
 boundary="------------050208090704040707070105"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arm-kernel@lists.arm.linux.org.uk
Cc: linux-mm@kvack.org, "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>, Phil Blundell <philb@gnu.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050208090704040707070105
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi all.

[We already discussed this issue in linux-mm ML, but people suggested 
to post to linux-arm-kernel...]

When compiling Linux (latest kernel from Linus' git) on ARM, I noticed
the following warning:

CC      arch/arm/mm/ioremap.o
arch/arm/mm/ioremap.c: In function '__arm_ioremap_pfn':
arch/arm/mm/ioremap.c:83: warning: control may reach end of non-void
function 'remap_area_pte' being inlined

If you look at the code, the problem is in a path including a BUG().

AFAIK, on ARM the code following BUG() is never executed: it's a NULL
pointer dereference, so the handler of pagefault eventually calls
do_exit(). Therefore, we may want to remove the goto as shown in the
patch in attachment.

It's obviously a minor issue. But I don't like having meaningless
warnings during compilation: they just confuse output, and developers 
may miss some important warning message...

The need for the goto exists only if BUG() can return. If it doesn't,
we can safely remove it as shown in the patch.

Is this possible ? Should we update this piece of code ? Who's in
charge of maintaining it ?

Many thanks,

           Claudio






--------------050208090704040707070105
Content-Type: text/x-diff;
 name="0001-Fix-compilation-warning-in-remap_area_pte.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-Fix-compilation-warning-in-remap_area_pte.patch"

>From 08d2e6f14230bf2252c54f5421d92def5e70f6dc Mon Sep 17 00:00:00 2001
From: Claudio Scordino <claudio@evidence.eu.com>
Date: Mon, 8 Sep 2008 16:03:38 +0200
Subject: [PATCH 1/1] Fix compilation warning in remap_area_pte


Signed-off-by: Claudio Scordino <claudio@evidence.eu.com>
---
 arch/arm/mm/ioremap.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index b81dbf9..bc6eca0 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -52,18 +52,15 @@ static int remap_area_pte(pmd_t *pmd, unsigned long addr, unsigned long end,
 		return -ENOMEM;
 
 	do {
-		if (!pte_none(*pte))
-			goto bad;
-
+		if (unlikely(!pte_none(*pte))){
+			printk(KERN_CRIT "%s: page already exists\n", __FUNCTION__);
+			BUG();
+		}
 		set_pte_ext(pte, pfn_pte(phys_addr >> PAGE_SHIFT, prot),
 			    type->prot_pte_ext);
 		phys_addr += PAGE_SIZE;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	return 0;
-
- bad:
-	printk(KERN_CRIT "remap_area_pte: page already exists\n");
-	BUG();
 }
 
 static inline int remap_area_pmd(pgd_t *pgd, unsigned long addr,
-- 
1.5.4.3




--------------050208090704040707070105--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
