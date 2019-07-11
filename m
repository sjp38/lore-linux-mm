Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73265C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DF712166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EUNz/kVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DF712166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E67A98E00D8; Thu, 11 Jul 2019 10:27:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D79958E00C4; Thu, 11 Jul 2019 10:27:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF4838E00D8; Thu, 11 Jul 2019 10:27:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9755A8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:05 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k21so6990854ioj.3
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=/gc70sOJB+vK9w9Yd0bv1jRw7Ga4U07eYdWLQD2PoZs=;
        b=rq3N//33YUWn7UazwDkM09Q6NTq4Vfvtgk5LuOtucd2ICpqtXy6etisgpwCJ1sHnh/
         36OjvcGoHLoO7AZVrIXqzFnsImAn7mMfCHoSt2/Z4KaL7BpYb40aWtx95kx6LDBCEHmi
         03XFiuzOg7KP0mv4sRZubF3uNB6gHJ7zeo9KsMg5w9q6VYcoBMBbu2D0ozjdAR4xdDyZ
         NUCmW1EHNPrkORSYU+0Rk9tactln26j4M5RX+8Jq909OTNg6uH2tA1F27KkEJBupfl04
         /7BMkM5NS6i0+J497mk3i6jpoygaXk8CLf+vdTJlp33mJKKBYYWo/7B+hDAXk869tMxm
         n2Cg==
X-Gm-Message-State: APjAAAWN5Aq9ZI8Rp7c/cqj17HEri4Ym4gZ6rXf4A20DGxfMkJ9oFG7K
	IDXl0kUiHsxQLJecERdR1jNa79lQkCwd+zh5WvwZfOnVJzj7lD5kRR2OwIJbSyDGD8fN7ecctdp
	R5gedoBndL2CONYWYbW4D2VQpmbvikRZkiRuErhzoCjOKo8lioF8rsLW1lzlkL9jChA==
X-Received: by 2002:a05:6602:219a:: with SMTP id b26mr4702134iob.55.1562855225412;
        Thu, 11 Jul 2019 07:27:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8W2dwSQPiNSE8DAE9H308CD25jD55MvxpK3PHCJ0niK/nrlVNjZWR7lG2+/x4+1snCE3v
X-Received: by 2002:a05:6602:219a:: with SMTP id b26mr4702065iob.55.1562855224655;
        Thu, 11 Jul 2019 07:27:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855224; cv=none;
        d=google.com; s=arc-20160816;
        b=TGc/JhYQW+wKJ5joyxHGJ58nSFPU7c27RwuUvqzad3j7aDRdk3DDl4yN/HXNWgdH2L
         tjNqCIfSRhhvQbcpIS+UjkuDhGH6r4NK5hAo64EoglijNQjz5Tg/QL/OjkLC5KeQ+/EO
         bSZPBdIfVeuQRXlyBq0eQYDi3dT37igceeikIIeSvFFv1t6MkZuTfhk0SM4YFZrS8Naf
         +smqvP3Q8V77hsz0gTIuAyxflIjvkBs7BodFujbfWixVk8sjYL9wRH6kJi8yc50L8C0e
         hztUWfJhyPud7HUnqquZ4EbEO4gngHKOfHG+hOX8h3HjBThOCAGe1KUp82hb9UVxCWPR
         /O1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=/gc70sOJB+vK9w9Yd0bv1jRw7Ga4U07eYdWLQD2PoZs=;
        b=gM4OaJ9amzON8DmmU1M/MAP2T1fJUjmEFT3sioPq6R0Geyjqk4TYQpHD8vrMyFDHEl
         UVqMqZmh5QZWko1CBn+/x1HHJiZ+XnyOSErC7SZ3bkrMwYNNmhlyfs6+NC5Hl+l7laa6
         I+tUuLJdIWHqQbvkRpQL6ZIxehkMtrHf073A9Lpvudo7hGPgVlk4a/JzajuI1vhsscla
         Pw9qjF1PZljnmzDWBHpIBprGK+AvwHdjvM2PqSLyACyHVKCna4IEwJgRHTt93t5YaiTS
         YXOBOeIZbHf3s1+vXntR8Ivjrr8hsMS3oj2gXFjVuSKSlZ1xakL0Pu6K/J/vKyd3ARzo
         CItQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="EUNz/kVV";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r17si8721748jao.29.2019.07.11.07.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:27:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="EUNz/kVV";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO7iI013253;
	Thu, 11 Jul 2019 14:26:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=/gc70sOJB+vK9w9Yd0bv1jRw7Ga4U07eYdWLQD2PoZs=;
 b=EUNz/kVVuwEftp1KU5qURSDwp+TGdX5vvQ5vTvYLS3DXTF1MuLYbqn75wFx41g9hyOGh
 RM9we7oEvKnvKWG/vpmQwbpaiu20SQ1RssVY5TTvMhrnQ8jKRj/CsRaQfpMKJY/qrm/1
 LbhGJOplC+6BG/nJHq9sTPd5TIz1YACiQ9xWzDt1BtXTgliVimphNKiT1UU38OYP7oSW
 ELLA9E7UVvNKoLW2OQtdqbwZk0J9ufJIiTIIREI+9J5HCJcDTctrZalqmR+lSizxjXTr
 S4aV0Cb5jllRnc+3jSzNcfsprSQmpSqw2GObGMXoLB3Fng/zJt5MeVYf3wZ0eH8MRSjK eQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2tjm9r0btb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:54 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuE021444;
	Thu, 11 Jul 2019 14:26:50 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 21/26] mm/asi: Make functions to read cr3/cr4 ASI aware
Date: Thu, 11 Jul 2019 16:25:33 +0200
Message-Id: <1562855138-19507-22-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When address space isolation is active, cpu_tlbstate isn't necessarily
mapped in the ASI page-table, this would cause ASI to fault. Instead of
just mapping cpu_tlbstate, update __get_current_cr3_fast() and
cr4_read_shadow() by caching the cr3/cr4 values in the ASI session
when ASI is active.

Note that the cached cr3 value is the ASI cr3 value (i.e. the current
CR3 value when ASI is active). The cached cr4 value is the cr4 value
when isolation was entered (ASI doesn't change cr4).

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h         |    2 ++
 arch/x86/include/asm/mmu_context.h |   20 ++++++++++++++++++--
 arch/x86/include/asm/tlbflush.h    |   10 ++++++++++
 arch/x86/mm/asi.c                  |    3 +++
 4 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index f489551..07c2b50 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -73,7 +73,9 @@ struct asi_session {
 	enum asi_session_state	state;		/* state of ASI session */
 	bool			retry_abort;	/* always retry abort */
 	unsigned int		abort_depth;	/* abort depth */
+	unsigned long		isolation_cr3;	/* cr3 when ASI is active */
 	unsigned long		original_cr3;	/* cr3 before entering ASI */
+	unsigned long		original_cr4;	/* cr4 before entering ASI */
 	struct task_struct	*task;		/* task during isolation */
 } __aligned(PAGE_SIZE);
 
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 9024236..8cec983 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -14,6 +14,7 @@
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
 #include <asm/debugreg.h>
+#include <asm/asi.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -347,8 +348,23 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
  */
 static inline unsigned long __get_current_cr3_fast(void)
 {
-	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd,
-		this_cpu_read(cpu_tlbstate.loaded_mm_asid));
+	unsigned long cr3;
+
+#ifdef CONFIG_ADDRESS_SPACE_ISOLATION
+	/*
+	 * If isolation is active, cpu_tlbstate isn't necessarily mapped
+	 * in the ASI page-table (and it doesn't have the current pgd anyway).
+	 * The current CR3 is cached in the CPU ASI session.
+	 */
+	if (this_cpu_read(cpu_asi_session.state) == ASI_SESSION_STATE_ACTIVE)
+		cr3 = this_cpu_read(cpu_asi_session.isolation_cr3);
+	else
+		cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd,
+				this_cpu_read(cpu_tlbstate.loaded_mm_asid));
+#else
+	cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd,
+			this_cpu_read(cpu_tlbstate.loaded_mm_asid));
+#endif
 
 	/* For now, be very restrictive about when this can be called. */
 	VM_WARN_ON(in_nmi() || preemptible());
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index dee3758..917f9a5 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -12,6 +12,7 @@
 #include <asm/invpcid.h>
 #include <asm/pti.h>
 #include <asm/processor-flags.h>
+#include <asm/asi.h>
 
 /*
  * The x86 feature is called PCID (Process Context IDentifier). It is similar
@@ -324,6 +325,15 @@ static inline void cr4_toggle_bits_irqsoff(unsigned long mask)
 /* Read the CR4 shadow. */
 static inline unsigned long cr4_read_shadow(void)
 {
+#ifdef CONFIG_ADDRESS_SPACE_ISOLATION
+	/*
+	 * If isolation is active, cpu_tlbstate isn't necessarily mapped
+	 * in the ASI page-table. The CR4 value is cached in the CPU
+	 * ASI session.
+	 */
+	if (this_cpu_read(cpu_asi_session.state) == ASI_SESSION_STATE_ACTIVE)
+		return this_cpu_read(cpu_asi_session.original_cr4);
+#endif
 	return this_cpu_read(cpu_tlbstate.cr4);
 }
 
diff --git a/arch/x86/mm/asi.c b/arch/x86/mm/asi.c
index d488704..4a5a4ba 100644
--- a/arch/x86/mm/asi.c
+++ b/arch/x86/mm/asi.c
@@ -23,6 +23,7 @@
 
 /* ASI sessions, one per cpu */
 DEFINE_PER_CPU_PAGE_ALIGNED(struct asi_session, cpu_asi_session);
+EXPORT_SYMBOL(cpu_asi_session);
 
 struct asi_map_option {
 	int	flag;
@@ -291,6 +292,8 @@ int asi_enter(struct asi *asi)
 		goto err_unmap_task;
 	}
 	asi_session->original_cr3 = original_cr3;
+	asi_session->original_cr4 = cr4_read_shadow();
+	asi_session->isolation_cr3 = __sme_pa(asi->pgd);
 
 	/*
 	 * Use ASI barrier as we are setting CR3 with the ASI page-table.
-- 
1.7.1

