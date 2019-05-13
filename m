Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AC89C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DA582084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m2arcl/O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DA582084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D21F6B027F; Mon, 13 May 2019 10:40:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 082176B0281; Mon, 13 May 2019 10:40:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF1086B0282; Mon, 13 May 2019 10:40:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9F896B027F
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:40:03 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y15so9987135iod.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:40:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=LfHNGKdGVZ8SXafCfcR3Zof+WadTo/bKWh5zIaesw/M=;
        b=EWcqFMyoNVU3seUxHOCJtm95pI5i2CKxh700IW/ksVSZp4pWpMUepPfNzJ3kR1TvwG
         K1IDUUdXfJco47K8DxIoMhLvT4/EJRuLbHJXfhZX28sZqJfMJYBueGPJpMrw2oZ535g1
         V5cScC1dhKAxUX8TRYZTyhZmJdzXv/lsYXpYSZc1mDJHt2riAe5dGUCZ8ycitKYmv7XM
         0GxhSbeiAxN/OSSqPSMGXzz+pjo2QXuMC3mEAkzq5Th40iGMI/tR2Q2T+ieaJQY0Gt6y
         fyI3dckDnebNKTGRCJ1pnL8rW+m/8Eb72Q5vqKF2f1AKafmW+jtRfCfkH7+ueXsY5pZJ
         2BBw==
X-Gm-Message-State: APjAAAXQIhaFvr2KPJusonnWQ6GF9hnX9lULjhHseUVDTsT56IzEWObM
	tVf3KP76WDfk8pw8A8BtuWNMW7m+zUb8AOfI7saRc1NtzP0N/gxrs1gO3xtcR763xA7WooOHOE2
	kCdcsHJsDXtESxtrnIlbyni43RaVB6iBqulQ0Dob+XikTasOFCziZxelNxxHPqdLwow==
X-Received: by 2002:a24:fe0b:: with SMTP id w11mr13264438ith.6.1557758403510;
        Mon, 13 May 2019 07:40:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwj2j+fJMr/ZBCFPplBnrlnPf/ooYu4wBVgxBuLWTsHUYTazyz3RmVW9SBPfVbkgQtI619I
X-Received: by 2002:a24:fe0b:: with SMTP id w11mr13264372ith.6.1557758402788;
        Mon, 13 May 2019 07:40:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758402; cv=none;
        d=google.com; s=arc-20160816;
        b=cR0GL47AVI1uO/rxwitokhBjUHNpPb7C246Mhelr17Jpj0Xd5uLxf1uEJaclGNbU5Y
         MBHafXTTSEcJ/bUObDXNhheTdEXWHeR88tdGNObCcVGzwr4uYCxpeEQRs7LG/9zEPNTW
         8ejV2KYWU0wLrB/8219Gi9qWpjHGhZBgIlLFGgHhELRkvNG3qbPP32upx9tfTExYOkYJ
         fie8HEgaIeRVZMQFxVNAV5Wf5Tp16fpVZw42CyOMsPO9Zo5Vb383FD7auOO5OeI5CX+O
         FzhQiWfbG/gwWgYLHgvqdi0T4s0vKOjf/NYdFjOz5ki9J04tS+rJF5Qa4RqyPUh6MoTK
         NY7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=LfHNGKdGVZ8SXafCfcR3Zof+WadTo/bKWh5zIaesw/M=;
        b=cwX3B/VC4JlX6z4qZL4OVNbzRt5Fii/z5fOF9rAhacWza4YJKyhBQDqm0mZbkf3HZF
         g05pfZI44kNacfuFCyfvMaG6GtchPFC0X+p0JTnS4Pi1kA7C0IU3lKteVFBJGIhCBSZ1
         CVlK/qLDdc+2O/M+0WNZWEXzGfmFuWFD+LaS6PVaZS5yZF3GdCwDrubTcZ2sh8CFcD6S
         1YKwY5Dl/zVTdJCNAw/RZeTR8+SAutbSa7RTkfTOErPZa/41Gw9dJHfAsVpuynkjE6R2
         Jwb16YjMYxZ2IQWqMXqtXzXj4ZB69C7NadqSw2UtUeof4Xv7vOODdvC7mye5rgDbAfrn
         sKaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="m2arcl/O";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c17si83681itc.40.2019.05.13.07.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:40:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="m2arcl/O";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEdHlv193231;
	Mon, 13 May 2019 14:39:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=LfHNGKdGVZ8SXafCfcR3Zof+WadTo/bKWh5zIaesw/M=;
 b=m2arcl/OoSz25ufQlPkSDyXa5f1frMRq2QeB0JzA4PV/uhaSpAPsJfmP6YeH0R+Y7+PC
 50HJ+Yx7Z8gUn3m69WqI9tJvyt5ZPxzpbW+60gErtelRwYfFJw+X3V78E3pi6uU708Zl
 uEVUq4MhUxXUf1DFx84dYgGV/93RXZwfztVCXTVvknZhM6YZw2KSvN8qBdHsbd2ELVmx
 /7qs4qjDnvxh+fcskoo9PGQvTX2vY0RinWTrcvKjzeXlWoP9/wWiom7xFgGIssxbulhP
 IvPfd4bMncK92V8msleNSWffh5EcxE1AX3Pw6AsvfuevV3vA7E7XlcOF1Gt+oJHTRqAq Ww== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfm13-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:53 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQS022780;
	Mon, 13 May 2019 14:39:50 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 25/27] kvm/isolation: implement actual KVM isolation enter/exit
Date: Mon, 13 May 2019 16:38:33 +0200
Message-Id: <1557758315-12667-26-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

KVM isolation enter/exit is done by switching between the KVM address
space and the kernel address space.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   30 ++++++++++++++++++++++++------
 arch/x86/mm/tlb.c        |    1 +
 include/linux/sched.h    |    1 +
 3 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index db0a7ce..b0c789f 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -1383,11 +1383,13 @@ static bool kvm_page_fault(struct pt_regs *regs, unsigned long error_code,
 	printk(KERN_DEFAULT "KVM isolation: page fault %ld at %pS on %lx (%pS) while switching mm\n"
 	       "  cr3=%lx\n"
 	       "  kvm_mm=%px pgd=%px\n"
-	       "  active_mm=%px pgd=%px\n",
+	       "  active_mm=%px pgd=%px\n"
+	       "  kvm_prev_mm=%px pgd=%px\n",
 	       error_code, (void *)regs->ip, address, (void *)address,
 	       cr3,
 	       &kvm_mm, kvm_mm.pgd,
-	       active_mm, active_mm->pgd);
+	       active_mm, active_mm->pgd,
+	       current->kvm_prev_mm, current->kvm_prev_mm->pgd);
 	dump_stack();
 
 	return false;
@@ -1649,11 +1651,27 @@ void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu)
 	kvm_isolation_exit();
 }
 
+static void kvm_switch_mm(struct mm_struct *mm)
+{
+	unsigned long flags;
+
+	/*
+	 * Disable interrupt before updating active_mm, otherwise if an
+	 * interrupt occurs during the switch then the interrupt handler
+	 * can be mislead about the mm effectively in use.
+	 */
+	local_irq_save(flags);
+	current->kvm_prev_mm = current->active_mm;
+	current->active_mm = mm;
+	switch_mm_irqs_off(current->kvm_prev_mm, mm, NULL);
+	local_irq_restore(flags);
+}
+
 void kvm_isolation_enter(void)
 {
 	int err;
 
-	if (kvm_isolation()) {
+	if (kvm_isolation() && current->active_mm != &kvm_mm) {
 		/*
 		 * Switches to kvm_mm should happen from vCPU thread,
 		 * which should not be a kernel thread with no mm
@@ -1666,14 +1684,14 @@ void kvm_isolation_enter(void)
 			       current);
 			return;
 		}
-		/* TODO: switch to kvm_mm */
+		kvm_switch_mm(&kvm_mm);
 	}
 }
 
 void kvm_isolation_exit(void)
 {
-	if (kvm_isolation()) {
+	if (kvm_isolation() && current->active_mm == &kvm_mm) {
 		/* TODO: Kick sibling hyperthread before switch to host mm */
-		/* TODO: switch back to original mm */
+		kvm_switch_mm(current->kvm_prev_mm);
 	}
 }
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index a4db7f5..7ad5ad1 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -444,6 +444,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		switch_ldt(real_prev, next);
 	}
 }
+EXPORT_SYMBOL_GPL(switch_mm_irqs_off);
 
 /*
  * Please ignore the name of this function.  It should be called
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 80e1d75..b03680d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1202,6 +1202,7 @@ struct task_struct {
 #ifdef CONFIG_HAVE_KVM
 	/* Is the task mapped into the KVM address space? */
 	bool				kvm_mapped;
+	struct mm_struct		*kvm_prev_mm;
 #endif
 
 	/*
-- 
1.7.1

