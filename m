Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D60F6B025F
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:01:50 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id q83so82470385iod.3
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:01:50 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id 19si6876466ity.19.2016.08.04.23.54.38
        for <linux-mm@kvack.org>;
        Thu, 04 Aug 2016 23:54:40 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: shmem: Are we accounting block right?
Date: Fri, 05 Aug 2016 14:54:23 +0800
Message-ID: <006b01d1eee6$338c0c40$9aa424c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org

Hi all

Currently in mainline we do block account if the flags parameter 
carries VM_NORESERVE. 

But blocks should be accounted if reserved, as shown by the
following diff.

Am I missing anything?

thanks
Hillf

--- a/mm/shmem.c	Fri Aug  5 14:01:59 2016
+++ b/mm/shmem.c	Fri Aug  5 14:36:31 2016
@@ -168,7 +168,7 @@ static inline int shmem_reacct_size(unsi
  */
 static inline int shmem_acct_block(unsigned long flags, long pages)
 {
-	if (!(flags & VM_NORESERVE))
+	if (flags & VM_NORESERVE)
 		return 0;
 
 	return security_vm_enough_memory_mm(current->mm,
@@ -177,7 +177,7 @@ static inline int shmem_acct_block(unsig
 
 static inline void shmem_unacct_blocks(unsigned long flags, long pages)
 {
-	if (flags & VM_NORESERVE)
+	if (!(flags & VM_NORESERVE))
 		vm_unacct_memory(pages * VM_ACCT(PAGE_SIZE));
 }
 
--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
