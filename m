Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 565E1C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:25:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FD5B21897
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:25:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FD5B21897
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A15286B0006; Fri, 30 Aug 2019 09:25:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99CD16B0008; Fri, 30 Aug 2019 09:25:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B31C6B000A; Fri, 30 Aug 2019 09:25:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 645D66B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:25:44 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 088411E086
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:25:44 +0000 (UTC)
X-FDA: 75879166608.20.trade16_4f07064190722
X-HE-Tag: trade16_4f07064190722
X-Filterd-Recvd-Size: 3583
Received: from huawei.com (szxga04-in.huawei.com [45.249.212.190])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:25:42 +0000 (UTC)
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 14283D940CB8D64295D9;
	Fri, 30 Aug 2019 21:25:33 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS410-HUB.china.huawei.com (10.3.19.210) with Microsoft SMTP Server id
 14.3.439.0; Fri, 30 Aug 2019 21:25:24 +0800
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
To: <linux@armlinux.org.uk>, <ebiederm@xmission.com>,
	<kstewart@linuxfoundation.org>, <gregkh@linuxfoundation.org>,
	<gustavo@embeddedor.com>, <bhelgaas@google.com>, <jingxiangfeng@huawei.com>,
	<tglx@linutronix.de>, <sakari.ailus@linux.intel.com>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>
Subject: [PATCH] arm: fix page faults in do_alignment
Date: Fri, 30 Aug 2019 21:31:17 +0800
Message-ID: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The function do_alignment can handle misaligned address for user and
kernel space. If it is a userspace access, do_alignment may fail on
a low-memory situation, because page faults are disabled in
probe_kernel_address.

Fix this by using __copy_from_user stead of probe_kernel_address.

Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
---
 arch/arm/mm/alignment.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index 04b3643..2ccabd3 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -774,6 +774,7 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
 	unsigned long instr = 0, instrptr;
 	int (*handler)(unsigned long addr, unsigned long instr, struct pt_regs *regs);
 	unsigned int type;
+	mm_segment_t fs;
 	unsigned int fault;
 	u16 tinstr = 0;
 	int isize = 4;
@@ -784,16 +785,22 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
 
 	instrptr = instruction_pointer(regs);
 
+	fs = get_fs();
+	set_fs(KERNEL_DS);
 	if (thumb_mode(regs)) {
 		u16 *ptr = (u16 *)(instrptr & ~1);
-		fault = probe_kernel_address(ptr, tinstr);
+		fault = __copy_from_user(tinstr,
+				(__force const void __user *)ptr,
+				sizeof(tinstr));
 		tinstr = __mem_to_opcode_thumb16(tinstr);
 		if (!fault) {
 			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
 			    IS_T32(tinstr)) {
 				/* Thumb-2 32-bit */
 				u16 tinst2 = 0;
-				fault = probe_kernel_address(ptr + 1, tinst2);
+				fault = __copy_from_user(tinst2,
+						(__force const void __user *)(ptr+1),
+						sizeof(tinst2));
 				tinst2 = __mem_to_opcode_thumb16(tinst2);
 				instr = __opcode_thumb32_compose(tinstr, tinst2);
 				thumb2_32b = 1;
@@ -803,10 +810,13 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
 			}
 		}
 	} else {
-		fault = probe_kernel_address((void *)instrptr, instr);
+		fault = __copy_from_user(instr,
+				(__force const void __user *)instrptr,
+				sizeof(instr));
 		instr = __mem_to_opcode_arm(instr);
 	}
 
+	set_fs(fs);
 	if (fault) {
 		type = TYPE_FAULT;
 		goto bad_or_fault;
-- 
1.8.3.1


