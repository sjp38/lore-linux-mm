Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94B5FC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 493B02084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IIHbvoJP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 493B02084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00DD46B000A; Mon, 13 May 2019 10:39:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8B786B000C; Mon, 13 May 2019 10:39:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB6F06B000D; Mon, 13 May 2019 10:39:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E52C6B000A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:10 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id t7so9968082iof.21
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=1/A8dPg6N3BCp1dVVHZldE7IkiS+8kPsjdwBuin2g4s=;
        b=ERTGHeUuiioq1OWvXy6sEDTDYd7llPdRfyr9iKsmfOKLYWUUAeircmg8EHe+QaSFJM
         1kDlA7L7tbhamUCF36fiQOh3jDH6Jff8U9qsYhA9K0B8zCeAdeyDcOXWrXQkL7ah98Cm
         3Ru+qn3IsMt19KemE46PB5ryXppc3TEjdYfTV720QsT4tjWQiyiflSl99wq7MTQ9BSCX
         HmPqC06ivWBXkly3Zrptzy2f5xhqcz2hL0Y2gs8lVNFJsfzBl/HrInyn/QP4T00sWX+h
         gMb37R9//Cy6+KEFPDEhwtOGNWxZ3kNd6eoKnbntVkZDzVxM488p3E5afMJxlCf7de7N
         /rPQ==
X-Gm-Message-State: APjAAAXd8pWjJyx2iYh0t+w2j5pwBP+4Fv6ooZEnjYU+sJV/Ej9oVfJ9
	jfqn3eC2Ksr0gqWs+TMWCpVtmvJcbO4A0nZ8neL2+bmSZJkCLe4CkeTW2yytApcE035KNI7ECl+
	z+hLYy/WtTCYTOMbaIlkD2cWAShUhlQNGrSIkeqvdtLRsXfJIRIvQF3xR1q5SL3pL7Q==
X-Received: by 2002:a5e:cb47:: with SMTP id h7mr13273714iok.69.1557758350389;
        Mon, 13 May 2019 07:39:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQRIyc6T+QCpSHaHEnXG902/BpiESTYryP4+wPP4TN7G+goh2cLkfWU/YrGAHTV+W+gnzq
X-Received: by 2002:a5e:cb47:: with SMTP id h7mr13273671iok.69.1557758349703;
        Mon, 13 May 2019 07:39:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758349; cv=none;
        d=google.com; s=arc-20160816;
        b=XbeooR9vGBUgnKe+RMnUiRuxBB0pQJVJe/iW5VKViCGZ2s/2II5sqnmaDyV8UQm6tc
         ju90yF5zO8fUhDVEPbVZZ/GsuXDurv6F+nU8BLmiVe2geImFkBEZA6hNASKscOvqUh1+
         eZ5/qgpkCgjq62o+9DkhggNn0C+AKeEI3Ny1xtYmlsLbZKphQ9z5jzoIjLbQPv/h+vK1
         fQN6FAZBzeGheTHyI/tjoowENreeRYDBNoWT9YkJuOxH5BU8EF5n560KJT9Xgc81EFyk
         tjIBCNwqiPJP2nPUfA5RCbSOyZrsYq9xPkO751UjSlDiijA0tfP7Lurd5V0D1T9JxKYZ
         ORbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=1/A8dPg6N3BCp1dVVHZldE7IkiS+8kPsjdwBuin2g4s=;
        b=qoEYpSZd0TTjq1dNK3yNuzXxIZkC7S5UpKQIzFYrydEirbvDBGVvIb8iBxkh3MVy02
         pMeB/yFnsjhXIuvrw/XNhOTavS8qF0vp7qXYI1tgaLGTDNzhCqTRizNyGvE6DXaQd3ys
         ucQF3ufGIjnM1ZJx3ZZRhtbv637eEGsWPK1BqgCAqXcnmMmLEwnZW4i186gN8RmmWbVK
         6FKgQZs2SDJalK3T6tZO7e12JMycCwViyibKz8pe0yhZ3M05wbTAjSRLdgVwmKToftK8
         rYbGZmf5/hvqDwj5WQ8B63iVdyHWdsrqOduoHgk0yTe+Ztc0dF4iWgTIW6gfr8ob3TPx
         BpQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IIHbvoJP;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h1si8195330itl.18.2019.05.13.07.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IIHbvoJP;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DESwxh183032;
	Mon, 13 May 2019 14:38:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=1/A8dPg6N3BCp1dVVHZldE7IkiS+8kPsjdwBuin2g4s=;
 b=IIHbvoJP5+K/6hJmjo6mwDCr+XYe5WkcmTj/jZgsHQd++1A3nrRugabuYhfepHXTNKMa
 V+W5LQ4oABEgMC2/bRAoDFfs1URTJrv1FkjV3nZfJhEh3aTydJM7O9zVMLE+XCLnCNo0
 mgaCYQLJsGwxxqQvTsOBwgrZT+TlGys5Y+xXj8Q2b2tjQKrJs5qkBiGxQsdVfxbT4cvm
 AvsvkAn4MmTs1z4WmXxi/1KuzDaA9HLi5wH7yN5hYhVDuggPf0x5mUO+bX8AKL3WJ1Pd
 Vh+iMejI0gUwJY+npXZCvzmO6WQnPg//1CrX7b7e8J9CRrNauyV7gxxNmcg6wsYTegjc qw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfksf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:38:50 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQ4022780;
	Mon, 13 May 2019 14:38:42 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 01/27] kernel: Export memory-management symbols required for KVM address space isolation
Date: Mon, 13 May 2019 16:38:09 +0200
Message-Id: <1557758315-12667-2-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Export symbols needed to create, manage, populate and switch
a mm from a kernel module (kvm in this case).

This is a hacky way for now to start.
This should be changed to some suitable memory-management API.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kernel/ldt.c |    1 +
 arch/x86/mm/tlb.c     |    3 ++-
 mm/memory.c           |    5 +++++
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index b2463fc..19a86e0 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -401,6 +401,7 @@ void destroy_context_ldt(struct mm_struct *mm)
 	free_ldt_struct(mm->context.ldt);
 	mm->context.ldt = NULL;
 }
+EXPORT_SYMBOL_GPL(destroy_context_ldt);
 
 void ldt_arch_exit_mmap(struct mm_struct *mm)
 {
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 7f61431..a4db7f5 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -70,7 +70,7 @@ static void clear_asid_other(void)
 }
 
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
-
+EXPORT_SYMBOL_GPL(last_mm_ctx_id);
 
 static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
 			    u16 *new_asid, bool *need_flush)
@@ -159,6 +159,7 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	switch_mm_irqs_off(prev, next, tsk);
 	local_irq_restore(flags);
 }
+EXPORT_SYMBOL_GPL(switch_mm);
 
 static void sync_current_stack_to_mm(struct mm_struct *mm)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 36aac68..ede9335 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -434,6 +434,7 @@ int __pte_alloc(struct mm_struct *mm, pmd_t *pmd)
 		pte_free(mm, new);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__pte_alloc);
 
 int __pte_alloc_kernel(pmd_t *pmd)
 {
@@ -453,6 +454,7 @@ int __pte_alloc_kernel(pmd_t *pmd)
 		pte_free_kernel(&init_mm, new);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__pte_alloc_kernel);
 
 static inline void init_rss_vec(int *rss)
 {
@@ -4007,6 +4009,7 @@ int __p4d_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__p4d_alloc);
 #endif /* __PAGETABLE_P4D_FOLDED */
 
 #ifndef __PAGETABLE_PUD_FOLDED
@@ -4039,6 +4042,7 @@ int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address)
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__pud_alloc);
 #endif /* __PAGETABLE_PUD_FOLDED */
 
 #ifndef __PAGETABLE_PMD_FOLDED
@@ -4072,6 +4076,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 	spin_unlock(ptl);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__pmd_alloc);
 #endif /* __PAGETABLE_PMD_FOLDED */
 
 static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-- 
1.7.1

