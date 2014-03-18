Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA8C6B00FD
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 08:41:15 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id bs8so2726986wib.5
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 05:41:14 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id eo11si12108347wjd.21.2014.03.18.05.41.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 05:41:14 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 18 Mar 2014 12:41:13 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id AA3E517D805C
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 12:41:52 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2ICewpu59375648
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 12:40:58 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2ICf8Ga002044
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 06:41:09 -0600
Date: Tue, 18 Mar 2014 13:41:07 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [BUG -next] "mm: per-thread vma caching fix 5" breaks s390
Message-ID: <20140318124107.GA24890@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hi Andrew,

your patch "mm-per-thread-vma-caching-fix-5" in linux-next (see below) breaks s390:

[   10.101173] kernel BUG at mm/vmacache.c:76!
[   10.101206] illegal operation: 0001 [#1] SMP DEBUG_PAGEALLOC
[   10.101210] Modules linked in:
[   10.101212] CPU: 3 PID: 2286 Comm: ifup-eth Not tainted 3.14.0-rc6-00193-g7f31667faba3 #20
[   10.101214] task: 000000003f65cb90 ti: 000000003db30000 task.ti: 000000003db30000
[   10.101220] Krnl PSW : 0704d00180000000 000000000025df40 (vma_interval_tree_augment_rotate+0x0/0x64)
[   10.101222]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
               Krnl GPRS: 0000000000000000 0000000000000018 000000003a42cfd0 00000000800fb000
[   10.101225]            0000000000000001 000000003f65cb90 0000000000000000 000000003dbacba8
[   10.101226]            0705100180000000 000000003dbacb00 000000003f65cb90 000000003dbacb00
[   10.101227]            000000003a42cfd0 00000000800fb000 0000000000269e54 000000003db33d80
[   10.101235] Krnl Code: 000000000025df32: e3b0c0400020        cg      %r11,64(%r12)
                          000000000025df38: a784ffd1            brc     8,25deda
                         #000000000025df3c: a7f40001            brc     15,25df3e
                         >000000000025df40: e31020180004        lg      %r1,24(%r2)
                          000000000025df46: e31030180024        stg     %r1,24(%r3)
                          000000000025df4c: e3302fb0ff04        lg      %r3,-80(%r2)
                          000000000025df52: e31020400004        lg      %r1,64(%r2)
                          000000000025df58: e3302fa8ff09        sg      %r3,-88(%r2)
[   10.101251] Call Trace:
[   10.101253] ([<000000003dbacb00>] 0x3dbacb00)
[   10.101256]  [<00000000007a62da>] do_protection_exception+0x12a/0x3b4
[   10.101258]  [<00000000007a4862>] pgm_check_handler+0x17a/0x17e
[   10.101259]  [<0000000080086806>] 0x80086806
[   10.101260] INFO: lockdep is turned off.
[   10.101261] Last Breaking-Event-Address:
[   10.101262]  [<000000000025df3c>] vmacache_find+0x80/0x84
[   10.101264]  
[   10.101265] Kernel panic - not syncing: Fatal exception: panic_on_oops

Given that this is just an addon patch to Davidlohr's "mm: per-thread
vma caching" patch I was wondering if something in there is architecture
specific.
But it doesn't look like that. So I'm wondering if this only breaks on
s390?

commit 7f31667faba32a4cf1e20d042c17783168c95f1b
Author: Andrew Morton <akpm@linux-foundation.org>
Date:   Mon Mar 17 11:23:53 2014 +1100

    mm-per-thread-vma-caching-fix-5
    
    a sanity check
    
    Cc: Davidlohr Bueso <davidlohr@hp.com>
    Cc: Sasha Levin <sasha.levin@oracle.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/vmacache.c b/mm/vmacache.c
index add3162bf735..a265dd338228 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -72,8 +72,10 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
        for (i = 0; i < VMACACHE_SIZE; i++) {
                struct vm_area_struct *vma = current->vmacache[i];
 
-               if (vma && vma->vm_start <= addr && vma->vm_end > addr)
+               if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
+                       BUG_ON(vma->vm_mm != mm);
                        return vma;
+               }
        }
 
        return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
