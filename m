Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5976B0032
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 05:08:13 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so617221pbc.32
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 02:08:12 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 9 Oct 2013 10:08:06 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 413B217D8068
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 10:08:24 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9996ZZv57606184
	for <linux-mm@kvack.org>; Wed, 9 Oct 2013 09:06:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9996jpl013276
	for <linux-mm@kvack.org>; Wed, 9 Oct 2013 03:06:47 -0600
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 2/2] s390/mmap: randomize mmap base for bottom up direction
Date: Wed,  9 Oct 2013 11:06:43 +0200
Message-Id: <1381309603-19570-2-git-send-email-heiko.carstens@de.ibm.com>
In-Reply-To: <1381309603-19570-1-git-send-email-heiko.carstens@de.ibm.com>
References: <1381309603-19570-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Radu Caragea <sinaelgl@gmail.com>, Michel Lespinasse <walken@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Heiko Carstens <heiko.carstens@de.ibm.com>

Implement mmap base randomization for the bottom up direction, so ASLR works
for both mmap layouts on s390.
See also df54d6fa54 "x86 get_unmapped_area(): use proper mmap base for
bottom-up direction".

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/mm/mmap.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index 4002329..7110c0f 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -64,6 +64,11 @@ static unsigned long mmap_rnd(void)
 	return (get_random_int() & 0x7ffUL) << PAGE_SHIFT;
 }
 
+static unsigned long mmap_base_legacy(void)
+{
+	return TASK_UNMAPPED_BASE + mmap_rnd();
+}
+
 static inline unsigned long mmap_base(void)
 {
 	unsigned long gap = rlimit(RLIMIT_STACK);
@@ -89,7 +94,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * bit is set, or if the expected stack growth is unlimited:
 	 */
 	if (mmap_is_legacy()) {
-		mm->mmap_base = TASK_UNMAPPED_BASE;
+		mm->mmap_base = mmap_base_legacy();
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
 		mm->mmap_base = mmap_base();
@@ -172,7 +177,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 	 * bit is set, or if the expected stack growth is unlimited:
 	 */
 	if (mmap_is_legacy()) {
-		mm->mmap_base = TASK_UNMAPPED_BASE;
+		mm->mmap_base = mmap_base_legacy();
 		mm->get_unmapped_area = s390_get_unmapped_area;
 	} else {
 		mm->mmap_base = mmap_base();
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
