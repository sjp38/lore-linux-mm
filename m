Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7222F6B0008
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:35 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 18:01:31 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 84B352CE802D
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:30 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7qr5L9109808
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:52:54 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85Sf4007386
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:29 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 02/24] powerpc: Save DAR and DSISR in pt_regs on MCE
Date: Tue, 26 Feb 2013 13:34:52 +0530
Message-Id: <1361865914-13911-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We were not saving DAR and DSISR on MCE. Save then and also print the values
along with exception details in xmon.

Acked-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/kernel/exceptions-64s.S |    9 +++++++++
 arch/powerpc/xmon/xmon.c             |    2 +-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/exceptions-64s.S b/arch/powerpc/kernel/exceptions-64s.S
index 0e9c48c..d02e730 100644
--- a/arch/powerpc/kernel/exceptions-64s.S
+++ b/arch/powerpc/kernel/exceptions-64s.S
@@ -640,9 +640,18 @@ slb_miss_user_pseries:
 	.align	7
 	.globl machine_check_common
 machine_check_common:
+
+	mfspr	r10,SPRN_DAR
+	std	r10,PACA_EXGEN+EX_DAR(r13)
+	mfspr	r10,SPRN_DSISR
+	stw	r10,PACA_EXGEN+EX_DSISR(r13)
 	EXCEPTION_PROLOG_COMMON(0x200, PACA_EXMC)
 	FINISH_NAP
 	DISABLE_INTS
+	ld	r3,PACA_EXGEN+EX_DAR(r13)
+	lwz	r4,PACA_EXGEN+EX_DSISR(r13)
+	std	r3,_DAR(r1)
+	std	r4,_DSISR(r1)
 	bl	.save_nvgprs
 	addi	r3,r1,STACK_FRAME_OVERHEAD
 	bl	.machine_check_exception
diff --git a/arch/powerpc/xmon/xmon.c b/arch/powerpc/xmon/xmon.c
index 1f8d2f1..a72e490 100644
--- a/arch/powerpc/xmon/xmon.c
+++ b/arch/powerpc/xmon/xmon.c
@@ -1423,7 +1423,7 @@ static void excprint(struct pt_regs *fp)
 	printf("    sp: %lx\n", fp->gpr[1]);
 	printf("   msr: %lx\n", fp->msr);
 
-	if (trap == 0x300 || trap == 0x380 || trap == 0x600) {
+	if (trap == 0x300 || trap == 0x380 || trap == 0x600 || trap == 0x200) {
 		printf("   dar: %lx\n", fp->dar);
 		if (trap != 0x380)
 			printf(" dsisr: %lx\n", fp->dsisr);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
