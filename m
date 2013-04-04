Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id B2F236B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:23:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BDA1DE0059
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:29:56 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345w7nP8520098
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:07 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wCPi026407
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:12 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 02/25] powerpc: Save DAR and DSISR in pt_regs on MCE
Date: Thu,  4 Apr 2013 11:27:40 +0530
Message-Id: <1365055083-31956-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
