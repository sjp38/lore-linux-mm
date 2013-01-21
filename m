Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 63CE86B0010
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:53:00 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 12:52:59 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E106638C801C
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:48 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LHqm9w310888
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:48 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LHqm77011768
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 15:52:48 -0200
Subject: [PATCH 3/5] use new pagetable helpers in try_preserve_large_page()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 09:52:47 -0800
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
In-Reply-To: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
Message-Id: <20130121175247.76641034@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


try_preserve_large_page() can be slightly simplified by using
the new page_level_*() helpers.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/mm/pageattr.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff -puN arch/x86/mm/pageattr.c~use-new-pagetable-helpers arch/x86/mm/pageattr.c
--- linux-2.6.git/arch/x86/mm/pageattr.c~use-new-pagetable-helpers	2013-01-17 10:22:26.282431407 -0800
+++ linux-2.6.git-dave/arch/x86/mm/pageattr.c	2013-01-17 10:22:26.286431442 -0800
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
