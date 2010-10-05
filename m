Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB79A6B0085
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:54:03 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o957s16f023273
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:54:01 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe14.cbf.corp.google.com with ESMTP id o957s01Y031398
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:54:00 -0700
Received: by pvh1 with SMTP id 1so1936407pvh.23
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 00:54:00 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/3] access_error API cleanup
Date: Tue,  5 Oct 2010 00:53:35 -0700
Message-Id: <1286265215-9025-4-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-1-git-send-email-walken@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

access_error() already takes error_code as an argument, so there is
no need for an additional write flag.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/mm/fault.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index b355b92..844d46f 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -915,9 +915,9 @@ spurious_fault(unsigned long error_code, unsigned long address)
 int show_unhandled_signals = 1;
 
 static inline int
-access_error(unsigned long error_code, int write, struct vm_area_struct *vma)
+access_error(unsigned long error_code, struct vm_area_struct *vma)
 {
-	if (write) {
+	if (error_code & PF_WRITE) {
 		/* write, present and write, not present: */
 		if (unlikely(!(vma->vm_flags & VM_WRITE)))
 			return 1;
@@ -1110,7 +1110,7 @@ retry:
 	 * we can handle it..
 	 */
 good_area:
-	if (unlikely(access_error(error_code, write, vma))) {
+	if (unlikely(access_error(error_code, vma))) {
 		bad_area_access_error(regs, error_code, address);
 		return;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
