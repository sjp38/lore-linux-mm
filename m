Received: from [192.168.184.142]([192.168.184.142]) (1062 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m19RnGY-00001KC@megami>
	for <linux-mm@kvack.org>; Sun, 15 Jun 2003 23:14:54 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 16 Jun 2003 07:16:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: use_mm/unuse_mm correctness
In-Reply-To: <20030616092944.A10463@in.ibm.com>
Message-ID: <Pine.LNX.4.44.0306160714360.1524-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Suparna Bhattacharya <suparna@in.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jun 2003, Suparna Bhattacharya wrote:
> Can anyone spot a problem in the following routines ?

If CONFIG_PREEMPT=y, then this might help:

--- 2.5.71-mm1/fs/aio.c	Sun Jun 15 12:36:09 2003
+++ linux/fs/aio.c	Mon Jun 16 07:05:53 2003
@@ -582,7 +582,8 @@ void unuse_mm(struct mm_struct *mm)
 {
 	current->mm = NULL;
 	/* active_mm is still 'mm' */
-	enter_lazy_tlb(mm, current, smp_processor_id());
+	enter_lazy_tlb(mm, current, get_cpu());
+	put_cpu();
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
