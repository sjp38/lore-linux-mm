Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D972C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E894F21019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Xw8imofO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E894F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D54E48E00D3; Thu, 11 Jul 2019 10:26:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDD678E00C4; Thu, 11 Jul 2019 10:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE0F28E00D3; Thu, 11 Jul 2019 10:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83F5B8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:51 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id r27so6956401iob.14
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=tktXu8oSlvrRNi4oCpkMHKHtnQ30RjQ+vGHk9xchmuI=;
        b=NmgiiCVDY/CXc+dqNO6k1DiChJ0MHMxHRc7at+5fqJSzftUN0CrgBF4DEkJVsSF298
         XtKoxfw5k8rwsQ2Ufc6oMkhxdTggDoTdFNO2cl/yHatSiLg6xMGMsXG1tVzgwzLjxxrb
         ibNDZUUfBklTKiF4KEbKhfznTwk5J3RGObripr5z+sNMEZRKBRG0Ch3pQBNIkj4OMupx
         DZrLLyaSLvTwmnaOlU2eBR5ZCXnsMcMucvLsaHl/CQ0ym2D3QgRhCkvIbPG0wMoQ8WNk
         J4Z0dJvmG12QQ2kCt+F4Mt8gh4RthoaeagmkzsWtEVsN9prgLvKkjfa2bh6nRefkR05v
         af+w==
X-Gm-Message-State: APjAAAXBuJZhaScE++KwKhk8zF88mNQ0ml8NdYBeRLICDyo8c2Ynh8G5
	fZdU9R/en1N6GKdD46jva/UHgZ3pvtiyWbQ0tEtBni9bThj2YVaormLDdeKg3G2PjEmTgpQDAzY
	IsiNrQhanVG2OChk85FSOofZ/hui4Jve+IU453PYwbjjvCZ2Lao1xcCW08o7KVGbcYQ==
X-Received: by 2002:a6b:5a17:: with SMTP id o23mr1380557iob.41.1562855211306;
        Thu, 11 Jul 2019 07:26:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxefB5i5iJd9boZTrhUTRwU6ho7S2GkDPgbrT5ZNEHRzHnsfrSBthvIOXHU8vwyja8bWJZL
X-Received: by 2002:a6b:5a17:: with SMTP id o23mr1380480iob.41.1562855210497;
        Thu, 11 Jul 2019 07:26:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855210; cv=none;
        d=google.com; s=arc-20160816;
        b=Qb3cmQvau/o/7bxXksz+8JmUdv7AQ8fYXWtYWFI/aIxUxsGwH7AChvEyEbivxvOXBi
         Of/VQw71rnlZ3s7BLrEAqjeizsojim8YAKQOj3xDUpBKPK7mdtFveCbcgDJe192mGBkm
         eAiVoqGxfU9BG6cUudyCFh3I/6O2B4i8tQ2I5mNmPUgZmXtyNEeNjPL7ZH6uo7gD4Cof
         70wEM2Use8qEJjnCYJgGdgAs2xGELiAbUxWW2kt+Ku5tkCPPfgpWOVPAEGMhf9GVIg9S
         OHRelHEZizMZVNsUqvfryw1ahwuOnb+4qhMsJY/NWWlYVqpFyNc0Vp04ioHr45C8EguI
         +spw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=tktXu8oSlvrRNi4oCpkMHKHtnQ30RjQ+vGHk9xchmuI=;
        b=a5AG9S6RrIyOq01iYu9ueH75xIn/v77hIXPG1b/AGVH27Wz9TuSlx7JtepchLBMKue
         qkxgD0hUvMAH3/xz1YSDh1oEx+lY1SHqzwJ+IRSymZahtjKxoyIP2haPLAFLTq65g7A2
         tsOKIV5wN2CyEQdxOVq1y7bkhFD0rPSB6HDVFogiSN7AIV+eAsCvBzGQg2cj5dLprL2O
         AoJvelA+PQq9mx1VZIfQwrp2AyTK/ZVOQqi5izqVn0dAbZCOr8PYrVA8DfOg8Sgx78ig
         kALaEvfXTfGP7Uaki71viAcesSIirk1xN3fmQN0snNueD5uC2RyXg5cnW++NvDFr5qCB
         +PcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Xw8imofO;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z9si9291957iof.139.2019.07.11.07.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Xw8imofO;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO7gP100410;
	Thu, 11 Jul 2019 14:26:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=tktXu8oSlvrRNi4oCpkMHKHtnQ30RjQ+vGHk9xchmuI=;
 b=Xw8imofO8fKNfBvyII53RRKIWPHJ/UdjgH1ZSaBocnV0EADrjb1GTZYN4HsE7xrVPRc/
 TEHR2f4ozNEvHmT4xkzmrRWShe8NJkdGTGU5UyvTwwVLuobGplkQYt22venKGQfjZsCi
 BuPNZ1Zy1I5Lm3q4cyPwf0rvVmiPcVoh9A/tJ1V5PFUsSDajeMDtZazluCVycnUMAv6u
 /YyGN39NkO9rtwovlVRiIRORlVYEoHIigSvvQZaOjXC7B6+jVAU9bBj+zUDnf/Rei8Mf
 yGpCGEFGnOwzX/ATnI3MWljtUlcXz+wMpxZcI3AhvYUC5PX/005SgrPaW6hQhMYqVhz6 ew== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2tjkkq0cat-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:39 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu8021444;
	Thu, 11 Jul 2019 14:26:31 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 15/26] mm/asi: Initialize the ASI page-table with core mappings
Date: Thu, 11 Jul 2019 16:25:27 +0200
Message-Id: <1562855138-19507-16-git-send-email-alexandre.chartre@oracle.com>
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

Core mappings are the minimal mappings we need to be able to
enter isolation and handle an isolation abort or exit. This
includes the kernel code, the GDT and the percpu ASI sessions.
We also need a stack so we map the current stack when entering
isolation and unmap it on exit/abort.

Optionally, additional mappins can be added like the stack canary
or the percpu offset to be able to use get_cpu_var()/this_cpu_ptr()
when isolation is active.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    9 ++++-
 arch/x86/mm/asi.c           |   75 +++++++++++++++++++++++++++++++++++++++---
 arch/x86/mm/asi_pagetable.c |   30 ++++++++++++----
 3 files changed, 99 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index cf5d198..1ac8fd3 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -11,6 +11,13 @@
 #include <asm/pgtable.h>
 #include <linux/xarray.h>
 
+/*
+ * asi_create() map flags. Flags are used to map optional data
+ * when creating an ASI.
+ */
+#define ASI_MAP_STACK_CANARY	0x01	/* map stack canary */
+#define ASI_MAP_CPU_PTR		0x02	/* for get_cpu_var()/this_cpu_ptr() */
+
 enum page_table_level {
 	PGT_LEVEL_PTE,
 	PGT_LEVEL_PMD,
@@ -73,7 +80,7 @@ struct asi_session {
 void asi_init_range_mapping(struct asi *asi);
 void asi_fini_range_mapping(struct asi *asi);
 
-extern struct asi *asi_create(void);
+extern struct asi *asi_create(int map_flags);
 extern void asi_destroy(struct asi *asi);
 extern int asi_enter(struct asi *asi);
 extern void asi_exit(struct asi *asi);
diff --git a/arch/x86/mm/asi.c b/arch/x86/mm/asi.c
index 25633a6..f049438 100644
--- a/arch/x86/mm/asi.c
+++ b/arch/x86/mm/asi.c
@@ -19,6 +19,17 @@
 /* ASI sessions, one per cpu */
 DEFINE_PER_CPU_PAGE_ALIGNED(struct asi_session, cpu_asi_session);
 
+struct asi_map_option {
+	int	flag;
+	void	*ptr;
+	size_t	size;
+};
+
+struct asi_map_option asi_map_percpu_options[] = {
+	{ ASI_MAP_STACK_CANARY, &fixed_percpu_data, sizeof(fixed_percpu_data) },
+	{ ASI_MAP_CPU_PTR, &this_cpu_off, sizeof(this_cpu_off) },
+};
+
 static void asi_log_fault(struct asi *asi, struct pt_regs *regs,
 			  unsigned long error_code, unsigned long address)
 {
@@ -85,16 +96,55 @@ bool asi_fault(struct pt_regs *regs, unsigned long error_code,
 	return true;
 }
 
-static int asi_init_mapping(struct asi *asi)
+static int asi_init_mapping(struct asi *asi, int flags)
 {
+	struct asi_map_option *option;
+	int i, err;
+
+	/*
+	 * Map the kernel.
+	 *
+	 * XXX We should check if we can map only kernel text, i.e. map with
+	 * size = _etext - _text
+	 */
+	err = asi_map(asi, (void *)__START_KERNEL_map, KERNEL_IMAGE_SIZE);
+	if (err)
+		return err;
+
 	/*
-	 * TODO: Populate the ASI page-table with minimal mappings so
-	 * that we can at least enter isolation and abort.
+	 * Map the cpu_entry_area because we need the GDT to be mapped.
+	 * Not sure we need anything else from cpu_entry_area.
 	 */
+	err = asi_map_range(asi, (void *)CPU_ENTRY_AREA_PER_CPU, P4D_SIZE,
+			    PGT_LEVEL_P4D);
+	if (err)
+		return err;
+
+	/*
+	 * Map the percpu ASI sessions. This is used by interrupt handlers
+	 * to figure out if we have entered isolation and switch back to
+	 * the kernel address space.
+	 */
+	err = ASI_MAP_CPUVAR(asi, cpu_asi_session);
+	if (err)
+		return err;
+
+	/*
+	 * Optional percpu mappings.
+	 */
+	for (i = 0; i < ARRAY_SIZE(asi_map_percpu_options); i++) {
+		option = &asi_map_percpu_options[i];
+		if (flags & option->flag) {
+			err = asi_map_percpu(asi, option->ptr, option->size);
+			if (err)
+				return err;
+		}
+	}
+
 	return 0;
 }
 
-struct asi *asi_create(void)
+struct asi *asi_create(int map_flags)
 {
 	struct page *page;
 	struct asi *asi;
@@ -115,7 +165,7 @@ struct asi *asi_create(void)
 	spin_lock_init(&asi->fault_lock);
 	asi_init_backend(asi);
 
-	err = asi_init_mapping(asi);
+	err = asi_init_mapping(asi, map_flags);
 	if (err)
 		goto error;
 
@@ -159,6 +209,7 @@ int asi_enter(struct asi *asi)
 	struct asi *current_asi;
 	struct asi_session *asi_session;
 	unsigned long original_cr3;
+	int err;
 
 	state = this_cpu_read(cpu_asi_session.state);
 	/*
@@ -190,6 +241,13 @@ int asi_enter(struct asi *asi)
 	WARN_ON(asi_session->abort_depth > 0);
 
 	/*
+	 * We need a stack to run with isolation, so map the current stack.
+	 */
+	err = asi_map(asi, current->stack, PAGE_SIZE << THREAD_SIZE_ORDER);
+	if (err)
+		goto err_clear_asi;
+
+	/*
 	 * Instructions ordering is important here because we should be
 	 * able to deal with any interrupt/exception which will abort
 	 * the isolation and restore CR3 to its original value:
@@ -211,7 +269,7 @@ int asi_enter(struct asi *asi)
 	if (!original_cr3) {
 		WARN_ON(1);
 		err = -EINVAL;
-		goto err_clear_asi;
+		goto err_unmap_stack;
 	}
 	asi_session->original_cr3 = original_cr3;
 
@@ -228,6 +286,8 @@ int asi_enter(struct asi *asi)
 
 	return 0;
 
+err_unmap_stack:
+	asi_unmap(asi, current->stack);
 err_clear_asi:
 	asi_session->asi = NULL;
 	asi_session->task = NULL;
@@ -284,6 +344,9 @@ void asi_exit(struct asi *asi)
 	 * exit isolation before abort_depth reaches 0.
 	 */
 	asi_session->abort_depth = 0;
+
+	/* unmap stack */
+	asi_unmap(asi, current->stack);
 }
 EXPORT_SYMBOL(asi_exit);
 
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index f1ee65b..bcc95f2 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -710,12 +710,20 @@ int asi_map_range(struct asi *asi, void *ptr, size_t size,
 	map_addr = round_down(addr, page_dir_size);
 	map_end = round_up(end, page_dir_size);
 
-	pr_debug("ASI %p: MAP %px/%lx/%d -> %lx-%lx\n", asi, ptr, size, level,
-		 map_addr, map_end);
-	if (map_addr < addr)
-		pr_debug("ASI %p: MAP LEAK %lx-%lx\n", asi, map_addr, addr);
-	if (map_end > end)
-		pr_debug("ASI %p: MAP LEAK %lx-%lx\n", asi, end, map_end);
+	/*
+	 * Don't log info the current stack because it is mapped/unmapped
+	 * everytime we enter/exit isolation.
+	 */
+	if (ptr != current->stack) {
+		pr_debug("ASI %p: MAP %px/%lx/%d -> %lx-%lx\n",
+			 asi, ptr, size, level, map_addr, map_end);
+		if (map_addr < addr)
+			pr_debug("ASI %p: MAP LEAK %lx-%lx\n",
+				 asi, map_addr, addr);
+		if (map_end > end)
+			pr_debug("ASI %p: MAP LEAK %lx-%lx\n",
+				 asi, end, map_end);
+	}
 
 	spin_lock_irqsave(&asi->lock, flags);
 
@@ -989,8 +997,14 @@ void asi_unmap(struct asi *asi, void *ptr)
 
 	addr = (unsigned long)range_mapping->ptr;
 	end = addr + range_mapping->size;
-	pr_debug("ASI %p: UNMAP %px/%lx/%d\n", asi, ptr,
-		 range_mapping->size, range_mapping->level);
+	/*
+	 * Don't log info the current stack because it is mapped/unmapped
+	 * everytime we enter/exit isolation.
+	 */
+	if (ptr != current->stack) {
+		pr_debug("ASI %p: UNMAP %px/%lx/%d\n", asi, ptr,
+			 range_mapping->size, range_mapping->level);
+	}
 	list_del(&range_mapping->list);
 	asi_unmap_overlap(asi, range_mapping);
 	kfree(range_mapping);
-- 
1.7.1

