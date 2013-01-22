Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id ADF0A6B0008
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:24:42 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 16:24:41 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AC90D38C8056
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:24:34 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0MLOXpx61014144
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:24:33 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0MLOWTU030480
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 19:24:33 -0200
Subject: [PATCH 3/5] use new pagetable helpers in try_preserve_large_page()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Tue, 22 Jan 2013 13:24:32 -0800
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
In-Reply-To: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
Message-Id: <20130122212432.14F3D993@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


try_preserve_large_page() can be slightly simplified by using
the new page_level_*() helpers.  This also moves the 'level'
over to the new pg_level enum type.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/mm/pageattr.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff -puN arch/x86/mm/pageattr.c~use-new-pagetable-helpers arch/x86/mm/pageattr.c
--- linux-2.6.git/arch/x86/mm/pageattr.c~use-new-pagetable-helpers	2013-01-22 13:17:15.792312210 -0800
+++ linux-2.6.git-dave/arch/x86/mm/pageattr.c	2013-01-22 13:17:15.796312243 -0800
@@ -396,7 +396,7 @@ try_preserve_large_page(pte_t *kpte, uns
 	pte_t new_pte, old_pte, *tmp;
 	pgprot_t old_prot, new_prot, req_prot;
 	int i, do_split = 1;
-	unsigned int level;
+	enum pg_level level;
 
 	if (cpa->force_split)
 		return 1;
@@ -412,15 +412,12 @@ try_preserve_large_page(pte_t *kpte, uns
 
 	switch (level) {
 	case PG_LEVEL_2M:
-		psize = PMD_PAGE_SIZE;
-		pmask = PMD_PAGE_MASK;
-		break;
 #ifdef CONFIG_X86_64
 	case PG_LEVEL_1G:
-		psize = PUD_PAGE_SIZE;
-		pmask = PUD_PAGE_MASK;
-		break;
 #endif
+		psize = page_level_size(level);
+		pmask = page_level_mask(level);
+		break;
 	default:
 		do_split = -EINVAL;
 		goto out_unlock;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
