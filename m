Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel7.hp.com (Postfix) with ESMTP id D0AD5348E3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:23:33 -0400 (EDT)
Received: from ldl.fc.hp.com (linux-bugs.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id 5CCEEAC66
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:23:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 22C5F134250
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:23:33 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 21417-05 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:23:31 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id E523E134225
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:23:30 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 4/6] Migrate-on-fault - handle misplaced
	anon pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:24:55 -0400
Message-Id: <1144441495.5198.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Migrate-on-fault prototype 4/6 V0.2 - handle misplaced anon pages

V0.2 -- refreshed against 2.6.16-mm2 [no changes for 2.6.17-rc1-mm1]

This patch simply hooks the anon page fault handler [do_swap_page()]
to check for and migrate misplaced pages.

File and shmem fault paths will be addressed in separate patches.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm2/mm/memory.c
===================================================================
--- linux-2.6.16-mm2.orig/mm/memory.c	2006-03-28 12:00:46.000000000 -0500
+++ linux-2.6.16-mm2/mm/memory.c	2006-03-28 12:01:07.000000000 -0500
@@ -48,6 +48,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/mempolicy.h>	/* check_migrate_misplaced_page() */
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -1924,6 +1925,8 @@ again:
 
 	/* The page isn't present yet, go ahead with the fault. */
 
+	page = check_migrate_misplaced_page(page, vma, address);
+
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
