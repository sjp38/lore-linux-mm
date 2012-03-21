Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A99316B007E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:57:01 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:01 -0700 (PDT)
Subject: [PATCH 11/16] mm/s390: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:56:58 +0400
Message-ID: <20120321065658.13852.52636.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-s390@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
---
 arch/s390/mm/fault.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index b17c42d..f8909e5 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -260,7 +260,7 @@ static noinline void do_fault_error(struct pt_regs *regs, int fault)
  *   11       Page translation     ->  Not present       (nullification)
  *   3b       Region third trans.  ->  Not present       (nullification)
  */
-static inline int do_exception(struct pt_regs *regs, int access)
+static inline int do_exception(struct pt_regs *regs, vm_flags_t access)
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -399,7 +399,8 @@ void __kprobes do_protection_exception(struct pt_regs *regs)
 
 void __kprobes do_dat_exception(struct pt_regs *regs)
 {
-	int access, fault;
+	int fault;
+	vm_flags_t access;
 
 	access = VM_READ | VM_EXEC | VM_WRITE;
 	fault = do_exception(regs, access);
@@ -441,7 +442,8 @@ no_context:
 int __handle_fault(unsigned long uaddr, unsigned long pgm_int_code, int write)
 {
 	struct pt_regs regs;
-	int access, fault;
+	int fault;
+	vm_flags_t access;
 
 	regs.psw.mask = psw_kernel_bits | PSW_MASK_DAT | PSW_MASK_MCHECK;
 	if (!irqs_disabled())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
