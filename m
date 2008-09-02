Message-ID: <48BCED2A.6030109@evidence.eu.com>
Date: Tue, 02 Sep 2008 09:37:14 +0200
From: Claudio Scordino <claudio@evidence.eu.com>
MIME-Version: 1.0
Subject: Warning message when compiling ioremap.c
Content-Type: multipart/mixed;
 boundary="------------070009080409050505040203"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: philb@gnu.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070009080409050505040203
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

       I'm not skilled with MM at all, so sorry if I'm saying something
stupid.

When compiling Linux (latest kernel from Linus' git) on ARM, I noticed 
the following warning:

CC      arch/arm/mm/ioremap.o
arch/arm/mm/ioremap.c: In function '__arm_ioremap_pfn':
arch/arm/mm/ioremap.c:83: warning: control may reach end of non-void
function 'remap_area_pte' being inlined

According to the message in the printk, we go to "bad" when the page
already exists.

So, I'm wondering if we shouldn't return a -EEXIST (see the patch
attached). This would remove that annoying warning message during
compilation...

Is it a good/bad idea ?

Regards,

              Claudio





--------------070009080409050505040203
Content-Type: text/x-diff;
 name="0001-Fix-compilation-warning-related-to-return-value-in-r.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-Fix-compilation-warning-related-to-return-value-in-r.pa";
 filename*1="tch"

>From 6ebc8f240bb8ca1cd640994ddb9280fb450f3f04 Mon Sep 17 00:00:00 2001
From: Claudio Scordino <claudio@evidence.eu.com>
Date: Mon, 1 Sep 2008 11:30:55 +0200
Subject: [PATCH 1/1] Fix compilation warning related to return value in remap_area_pte(...).


Signed-off-by: Claudio Scordino <claudio@evidence.eu.com>
---
 arch/arm/mm/ioremap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index b81dbf9..1e59a03 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -64,6 +64,7 @@ static int remap_area_pte(pmd_t *pmd, unsigned long addr, unsigned long end,
  bad:
 	printk(KERN_CRIT "remap_area_pte: page already exists\n");
 	BUG();
+	return -EEXIST;
 }
 
 static inline int remap_area_pmd(pgd_t *pgd, unsigned long addr,
-- 
1.5.4.3





--------------070009080409050505040203--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
