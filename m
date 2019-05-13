Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BA3EC04AB4
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33242133F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="F3ixlg5D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33242133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EF986B0283; Mon, 13 May 2019 10:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A2086B0284; Mon, 13 May 2019 10:40:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F4CE6B0285; Mon, 13 May 2019 10:40:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 098EB6B0283
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:40:11 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id z125so12373934itf.4
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=WgSqF1N9AL8OkCOWJMjKijUQDrf/NZQ7sjOAy3KvX18=;
        b=m3QJnF/Rnvx0k+Zj7UTgzqxu0A1xm8FqueJXM0c67+GjhRIApbCJtJSdq0FfkNEu54
         1AAuKStShGfvOp2XCdo7CzEPXOTp7eGtxVN7q1YpyyyxtDUVFyIIgicPVPAKzzxh9Ltt
         9ICWkzkeJU73En1FUZ0pHu7Ll0yUZpo54qp4BG+v7fwg1P1GoppD8X9TbTW7WU7klzhk
         +zip7QVEKqMHWoLjJLME94x3BnL928GwrQ2AjL8JJZsLxVWC1Fjx2EsdMfmE4r7zkvdn
         GrgJS9QxiMWxxMWbexaMGgQ41xraSjUvXTpY1GBSF+33lXPHJnIZZ9kJz4oj9WmwwxHb
         qxzQ==
X-Gm-Message-State: APjAAAUaK5M5ZHIfoN4vrMlNsHVlgWWRrzz/38zyT2xsj7ah42Sr2d0W
	1ladJw194faQlce8xBloBET1Q/K3nJEv3IhTXkBnSpGGNx3EPSMUK9bmLebWgiHKj6vyq+5Qu1Y
	qTC3HbtzWqOtzI5HBvlW0LWvAFE5z9UJAGVgq0+QgXp3loxr3WHRRlvoy2VKuIlT/jg==
X-Received: by 2002:a24:5491:: with SMTP id t139mr16658022ita.173.1557758410782;
        Mon, 13 May 2019 07:40:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVeLKx6PSPjXJYh1mLwqv2jmFke6Ov7fkO1P29FGmUxTc+YY3OfkU7+29bwYawV6lNgGhs
X-Received: by 2002:a24:5491:: with SMTP id t139mr16657965ita.173.1557758409915;
        Mon, 13 May 2019 07:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758409; cv=none;
        d=google.com; s=arc-20160816;
        b=J1a/UvLzTlbzkX/1+MMO3XBUBjAT+iFgnHkRXjifSqc5JY/YHYDO5Prdt+1FlzZsq9
         XXp+1fFVitopNOOVhgXdxPwrc/gpcP/vx4bMohyhgFRRkPKT9fwxl9r0RUEDL0TIbZnD
         DjGA0Rm7kWiJGAZHNigetGDBe1U75ZKpuBZwZ7jfpRJ8Ovmt+oAchCoe1fcANSdgEogM
         uDYgwMSSczEvnn27TYH+bGuXJ6f2c+GXYzYM/9BoKQ4UvlSY15fZUqHThBOuWdAbcz0+
         hbqjGsEKxikMv4Mw7/23JZQRE42Nl31a+ZEDqqtVoh8ZH4QVZY2IYO0yruMOV3lPu6VT
         NZOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=WgSqF1N9AL8OkCOWJMjKijUQDrf/NZQ7sjOAy3KvX18=;
        b=rw0omjBWxhCwHjV9ahae/FcRtvBVQVlo7VgULxMpwRHLfpnbQLE5pnr3x3N6g7ZQkf
         HV0/mW3WvBRn1i4eY+PP4LQvVj4mAGBQxt5aAhRbn1R1X2NoFmsGICxk2t3YIBe2J3k7
         yYvMHhv+xLJw0Pd9bgxv7UnL8k4FF56uryeY0bvvGrwesM9W17lz0TvNdpl9Aq09Rjei
         xRXgI4Io5WkR9a7o8KV9zWCKe9gRRZ09LnUwBYKpjegqe/xyaG1K6cGhcxMpNHHZ8cjk
         ldl/zkjKylr4slBPFhivITqMINdk/gyDwpDieWEfe8jZwgZJxP+m7E2NIXWkz9HL7XFP
         loag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=F3ixlg5D;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x15si8372480jaf.51.2019.05.13.07.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=F3ixlg5D;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEdhZc193417;
	Mon, 13 May 2019 14:40:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=WgSqF1N9AL8OkCOWJMjKijUQDrf/NZQ7sjOAy3KvX18=;
 b=F3ixlg5Del/kZFpkm5V339YqcYZIvytCmmZa2JMsPdT9dTNJdzNgJr2su3ZaFPX7+xSo
 OgE5doXVsWLJE6lg24N70KQRsqrw7KDlX0Lmv11xaiukFvSmC1PL9Z+pb6KOsPd3f9/Q
 TysNHNbYW17DUsb88Xzm+0xLKL38OFY7GPCscqM5Sr2RGXWabgevtm0BY8LIkE1hebHi
 ZDG3ZUmmf/4/2FsM+aInuyKqWofpo40CdOK/HySYEBTuzbf6QiQlJM7oxHIAKfyG/xd8
 7z7TkAUzLmadWyiur41dp0GSyhTRruaBBuRMWSLXH6YSLiSP0FUqhXsgwlGrUBetwxxp pQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfm1k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:40:01 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQT022780;
	Mon, 13 May 2019 14:39:53 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 26/27] kvm/isolation: initialize the KVM page table with KVM memslots
Date: Mon, 13 May 2019 16:38:34 +0200
Message-Id: <1557758315-12667-27-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=970
 adultscore=15 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

KVM memslots can change after they have been created so new memslots
have to be mapped when they are created.

TODO: we currently don't unmapped old memslots, they should be unmapped
when they are freed.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   39 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h |    1 +
 arch/x86/kvm/x86.c       |    3 +++
 3 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index b0c789f..255b2da 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -1593,13 +1593,45 @@ static void kvm_isolation_clear_handlers(void)
 	kvm_page_fault_handler = NULL;
 }
 
+void kvm_isolation_check_memslots(struct kvm *kvm)
+{
+	struct kvm_range_mapping *rmapping;
+	int i, err;
+
+	if (!kvm_isolation())
+		return;
+
+	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++) {
+		rmapping = kvm_get_range_mapping(kvm->memslots[i], NULL);
+		if (rmapping)
+			continue;
+		pr_debug("remapping kvm memslots[%d]\n", i);
+		err = kvm_copy_ptes(kvm->memslots[i],
+		    sizeof(struct kvm_memslots));
+		if (err)
+			pr_debug("failed to map kvm memslots[%d]\n", i);
+	}
+
+}
+
 int kvm_isolation_init_vm(struct kvm *kvm)
 {
+	int err, i;
+
 	if (!kvm_isolation())
 		return 0;
 
 	kvm_clear_page_fault();
 
+	pr_debug("mapping kvm memslots\n");
+
+	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++) {
+		err = kvm_copy_ptes(kvm->memslots[i],
+		    sizeof(struct kvm_memslots));
+		if (err)
+			return err;
+	}
+
 	pr_debug("mapping kvm srcu sda\n");
 
 	return (kvm_copy_percpu_mapping(kvm->srcu.sda,
@@ -1608,9 +1640,16 @@ int kvm_isolation_init_vm(struct kvm *kvm)
 
 void kvm_isolation_destroy_vm(struct kvm *kvm)
 {
+	int i;
+
 	if (!kvm_isolation())
 		return;
 
+	pr_debug("unmapping kvm memslots\n");
+
+	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++)
+		kvm_clear_range_mapping(kvm->memslots[i]);
+
 	pr_debug("unmapping kvm srcu sda\n");
 
 	kvm_clear_percpu_mapping(kvm->srcu.sda);
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index 2d7d016..1e55799 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -32,6 +32,7 @@ static inline bool kvm_isolation(void)
 extern void kvm_clear_range_mapping(void *ptr);
 extern int kvm_copy_percpu_mapping(void *percpu_ptr, size_t size);
 extern void kvm_clear_percpu_mapping(void *percpu_ptr);
+extern void kvm_isolation_check_memslots(struct kvm *kvm);
 extern int kvm_add_task_mapping(struct task_struct *tsk);
 extern void kvm_cleanup_task_mapping(struct task_struct *tsk);
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e1cc3a6..7d98e9f 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9438,6 +9438,7 @@ void kvm_arch_memslots_updated(struct kvm *kvm, u64 gen)
 	 * mmio generation may have reached its maximum value.
 	 */
 	kvm_mmu_invalidate_mmio_sptes(kvm, gen);
+	kvm_isolation_check_memslots(kvm);
 }
 
 int kvm_arch_prepare_memory_region(struct kvm *kvm,
@@ -9537,6 +9538,8 @@ void kvm_arch_commit_memory_region(struct kvm *kvm,
 	 */
 	if (change != KVM_MR_DELETE)
 		kvm_mmu_slot_apply_flags(kvm, (struct kvm_memory_slot *) new);
+
+	kvm_isolation_check_memslots(kvm);
 }
 
 void kvm_arch_flush_shadow_all(struct kvm *kvm)
-- 
1.7.1

