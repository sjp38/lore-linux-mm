Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BE2B6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 04:56:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n149uCJb010891
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Feb 2009 18:56:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 45D0D45DD75
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 18:56:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 271AE45DD74
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 18:56:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 255E81DB803F
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 18:56:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3781DB803A
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 18:56:11 +0900 (JST)
Date: Wed, 4 Feb 2009 18:55:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] release mmap_sem before starting migration (Was Re:
 Need to take mmap_sem lock in move_pages.
Message-Id: <20090204185501.837ff5d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090204184028.09a4bbae.kamezawa.hiroyu@jp.fujitsu.com>
References: <28631E6913C8074E95A698E8AC93D091B21561@caexch1.virident.info>
	<20090204183600.f41e8b7e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090204184028.09a4bbae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Swamy Gowda <swamy@virident.com>, linux-kernel@vger.kernel.org, cl@linux-foundation.org, Brice.Goglin@inria.fr, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2009 18:40:28 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 4 Feb 2009 18:36:00 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>       Maybe up_read() can be moved before do_migrate_pages(), I think.
> 
How about this ?
==

mmap_sem can be released after page table walk ends.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/migrate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-2.6.29-Feb03/mm/migrate.c
===================================================================
--- mmotm-2.6.29-Feb03.orig/mm/migrate.c
+++ mmotm-2.6.29-Feb03/mm/migrate.c
@@ -875,13 +875,13 @@ put_and_set:
 set_status:
 		pp->status = err;
 	}
+	up_read(&mm->mmap_sem);
 
 	err = 0;
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
 
-	up_read(&mm->mmap_sem);
 	return err;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
