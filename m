Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E22BC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4344821473
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NPL0tURB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4344821473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 822FC6B0273; Mon, 13 May 2019 10:39:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D50C6B0274; Mon, 13 May 2019 10:39:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 626906B0275; Mon, 13 May 2019 10:39:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABD96B0273
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:47 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id h189so10041930ioa.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=l5aKMAk3Fh+gtpNvYGvrecFqK8ir23pbpb3HmvcDshc=;
        b=iWw4x9LAEYYPqYI8++QiuoGNSi8rtFuqXyctEJ3urSw8Wf66aNV8fsRSFrSZBnweTM
         sYKo4ZmxRxoloUBihkPsbZ218pZWTY0T86e/FJbDyfbfRcPzBudGjjwIP+aiU2ZaV73C
         6tACvDSvcj5GKiYCgFvxQ+468h/Rp2n2157Htzsmkv226bgGPRQFUC2GKInR6Ak24aFi
         BfYdaQVfACtMS4nrheE2k9A1NBUyU5WTMhx/KnbkMlYkAxTFJES7mvtJJqbhQUzP/r5q
         icj0692Ss8fuqS3LMJHT63rtk+ek+3pukESXX0Gj9BfkN+PumWsUTfrLkulH0EmzWMda
         IFfw==
X-Gm-Message-State: APjAAAUX4YkKbYZhxVZClBvFsTkiMwYA1ANAphUuLm6e0HB6TpnnUwwx
	rRwn2kysLpD58k2tGkcn/uN7i0vsNz5OxfCDogZ554ORnZPVP7E9cxt1+wWCDa4XWAN4IRKW0ho
	TwW0lYSoZ1JaN416iRDqyQjGgvhy8iIIAJlpzLkmxKiS88Ht+mCLo43/SPBgUCQhOXQ==
X-Received: by 2002:a24:edcb:: with SMTP id r194mr18444148ith.164.1557758386965;
        Mon, 13 May 2019 07:39:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygEQrhf27FYMiIZFm4DqTBSODe3d70r6ad5hPNBj55bZKU/VyilK8D+eiWp7lHYrN0+eYM
X-Received: by 2002:a24:edcb:: with SMTP id r194mr18444086ith.164.1557758385964;
        Mon, 13 May 2019 07:39:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758385; cv=none;
        d=google.com; s=arc-20160816;
        b=HewYbC9+iD4iKtC6Rqv5ppvgbrPFOkOzEVzNZix3HOr3PbDZFbUX1HHq5+QZBhuTRk
         i1vRDYDvLzP9CjYD3s7fqtf6DJ3xT+pM1YHee0lxEKyRIK5Zw25Onna4ylxQiOViUjLc
         Oof68FyhHW54FaS5iBh7Oxe3YKwKhC6RQlNr7pWA55r1qm5gSjnXDrZZFGl9yE4NKnRw
         2WiHkLpr74v1esrDu7wc0XPfoWbgP1NS3R75seUhfeWHdVVcnvcUXwAF2ETSEXdmRbU5
         Y1Q6P3wniphUji838j4iEgrohEBm2NhMqeqO1L3so2mER7tOsGWS7MJr0pRkNVMFwn3s
         9UMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=l5aKMAk3Fh+gtpNvYGvrecFqK8ir23pbpb3HmvcDshc=;
        b=tLpRFpr7b86rPV03yZQ5puQjOeIuyRoVhPOMCD8wR+VmuD793Z8dZi8DvaYAZi+eqK
         Vf3OB0hTLcZ6CU+KWE6OXm89jhCiAsiVmTbfDr6IjRnWk7gh7ZPI+B+Tr9U3fc+TcVGS
         j8NEICas0uCPfChezGIg8nWGSaVVE1GDT3Y016UMH/h5RCRDiZYUDaSkEX9fXIjna7xV
         KY/YiID0DD9XD7nzLjIcGxLHKCirBnuZi8tbwiq4wksh0tXCKdZmYYdu+NmkxKL0kZWR
         iWWvkYjQ6w72OV6qK0QHb0xwtEfTTMmIQhcek21DlFwEoNCJ86wqOKAAG35p6OtGH3W0
         NoDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NPL0tURB;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q129si7546890jaq.37.2019.05.13.07.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NPL0tURB;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd28I193025;
	Mon, 13 May 2019 14:39:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=l5aKMAk3Fh+gtpNvYGvrecFqK8ir23pbpb3HmvcDshc=;
 b=NPL0tURBc+BNNRYWXut9QJPxP0shoD0HzAqoBR5E6EV0J0revf1EigBcQsuJWtb30CCC
 upBrgbB61tjujiQwsK2QAD4JDlF2ymOmSTZCeesv44XBs0QlN2E2lJ976YC4UOUGYYBG
 yj4HV+wTXtHjArhgs933THSajLYTjqu3Pm7eFTZXAp/pY1YUghyA/Rlag0ritPGg8VZh
 0vV3GFARwn18IkWwCCTC4TZudBcx6LFynGTBEWs9PS6Pa3VOJP3RXhwmMCToyY+MwubI
 lgNu9vsCkFz4pSpo1VcWzLZNKsLSUinM/ps8GUa/cBmdF5gC/ozgE5MprNsOpOKW+J8h TA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfkye-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:36 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQM022780;
	Mon, 13 May 2019 14:39:33 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 19/27] kvm/isolation: initialize the KVM page table with core mappings
Date: Mon, 13 May 2019 16:38:27 +0200
Message-Id: <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The KVM page table is initialized with adding core memory mappings:
the kernel text, the per-cpu memory, the kvm module, the cpu_entry_area,
%esp fixup stacks, IRQ stacks.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kernel/cpu/common.c |    2 +
 arch/x86/kvm/isolation.c     |  131 ++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h     |   10 +++
 include/linux/percpu.h       |    2 +
 mm/percpu.c                  |    6 +-
 5 files changed, 149 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 3764054..0fa44b1 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1511,6 +1511,8 @@ static __init int setup_clearcpuid(char *arg)
 EXPORT_PER_CPU_SYMBOL(current_task);
 
 DEFINE_PER_CPU(struct irq_stack *, hardirq_stack_ptr);
+EXPORT_PER_CPU_SYMBOL_GPL(hardirq_stack_ptr);
+
 DEFINE_PER_CPU(unsigned int, irq_count) __visible = -1;
 
 DEFINE_PER_CPU(int, __preempt_count) = INIT_PREEMPT_COUNT;
diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 2052abf..cf5ee0d 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -10,6 +10,8 @@
 #include <linux/printk.h>
 #include <linux/slab.h>
 
+#include <asm/cpu_entry_area.h>
+#include <asm/processor.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 
@@ -88,6 +90,8 @@ struct mm_struct kvm_mm = {
 DEFINE_STATIC_KEY_FALSE(kvm_isolation_enabled);
 EXPORT_SYMBOL(kvm_isolation_enabled);
 
+static void kvm_isolation_uninit_page_table(void);
+static void kvm_isolation_uninit_mm(void);
 static void kvm_clear_mapping(void *ptr, size_t size,
 			      enum page_table_level level);
 
@@ -1024,10 +1028,130 @@ int kvm_copy_percpu_mapping(void *percpu_ptr, size_t size)
 EXPORT_SYMBOL(kvm_copy_percpu_mapping);
 
 
+static int kvm_isolation_init_page_table(void)
+{
+	void *stack;
+	int cpu, rv;
+
+	/*
+	 * Copy the mapping for all the kernel text. We copy at the PMD
+	 * level since the PUD is shared with the module mapping space.
+	 */
+	rv = kvm_copy_mapping((void *)__START_KERNEL_map, KERNEL_IMAGE_SIZE,
+	     PGT_LEVEL_PMD);
+	if (rv)
+		goto out_uninit_page_table;
+
+	/* copy the mapping of per cpu memory */
+	rv = kvm_copy_mapping(pcpu_base_addr, pcpu_unit_size * pcpu_nr_units,
+	     PGT_LEVEL_PMD);
+	if (rv)
+		goto out_uninit_page_table;
+
+	/*
+	 * Copy the mapping for cpu_entry_area and %esp fixup stacks
+	 * (this is based on the PTI userland address space, but probably
+	 * not needed because the KVM address space is not directly
+	 * enterered from userspace). They can both be copied at the P4D
+	 * level since they each have a dedicated P4D entry.
+	 */
+	rv = kvm_copy_mapping((void *)CPU_ENTRY_AREA_PER_CPU, P4D_SIZE,
+	     PGT_LEVEL_P4D);
+	if (rv)
+		goto out_uninit_page_table;
+
+#ifdef CONFIG_X86_ESPFIX64
+	rv = kvm_copy_mapping((void *)ESPFIX_BASE_ADDR, P4D_SIZE,
+	     PGT_LEVEL_P4D);
+	if (rv)
+		goto out_uninit_page_table;
+#endif
+
+#ifdef CONFIG_VMAP_STACK
+	/*
+	 * Interrupt stacks are vmap'ed with guard pages, so we need to
+	 * copy mappings.
+	 */
+	for_each_possible_cpu(cpu) {
+		stack = per_cpu(hardirq_stack_ptr, cpu);
+		pr_debug("IRQ Stack %px\n", stack);
+		if (!stack)
+			continue;
+		rv = kvm_copy_ptes(stack - IRQ_STACK_SIZE, IRQ_STACK_SIZE);
+		if (rv)
+			goto out_uninit_page_table;
+	}
+
+#endif
+
+	/* copy mapping of the current module (kvm) */
+	rv = kvm_copy_module_mapping();
+	if (rv)
+		goto out_uninit_page_table;
+
+	return 0;
+
+out_uninit_page_table:
+	kvm_isolation_uninit_page_table();
+	return rv;
+}
+
+/*
+ * Free all buffers used by the kvm page table. These buffers are stored
+ * in the kvm_pgt_dgroup_list.
+ */
+static void kvm_isolation_uninit_page_table(void)
+{
+	struct pgt_directory_group *dgroup, *dgroup_next;
+	enum page_table_level level;
+	void *ptr;
+	int i;
+
+	mutex_lock(&kvm_pgt_dgroup_lock);
+
+	list_for_each_entry_safe(dgroup, dgroup_next,
+				 &kvm_pgt_dgroup_list, list) {
+
+		for (i = 0; i < dgroup->count; i++) {
+			ptr = dgroup->directory[i].ptr;
+			level = dgroup->directory[i].level;
+
+			switch (dgroup->directory[i].level) {
+
+			case PGT_LEVEL_PTE:
+				kvm_pte_free(NULL, ptr);
+				break;
+
+			case PGT_LEVEL_PMD:
+				kvm_pmd_free(NULL, ptr);
+				break;
+
+			case PGT_LEVEL_PUD:
+				kvm_pud_free(NULL, ptr);
+				break;
+
+			case PGT_LEVEL_P4D:
+				kvm_p4d_free(NULL, ptr);
+				break;
+
+			default:
+				pr_err("unexpected page directory %d for %px\n",
+				       level, ptr);
+			}
+		}
+
+		list_del(&dgroup->list);
+		kfree(dgroup);
+	}
+
+	mutex_unlock(&kvm_pgt_dgroup_lock);
+}
+
 static int kvm_isolation_init_mm(void)
 {
 	pgd_t *kvm_pgd;
 	gfp_t gfp_mask;
+	int rv;
 
 	gfp_mask = GFP_KERNEL | __GFP_ZERO;
 	kvm_pgd = (pgd_t *)__get_free_pages(gfp_mask, PGD_ALLOCATION_ORDER);
@@ -1054,6 +1178,12 @@ static int kvm_isolation_init_mm(void)
 	mm_init_cpumask(&kvm_mm);
 	init_new_context(NULL, &kvm_mm);
 
+	rv = kvm_isolation_init_page_table();
+	if (rv) {
+		kvm_isolation_uninit_mm();
+		return rv;
+	}
+
 	return 0;
 }
 
@@ -1065,6 +1195,7 @@ static void kvm_isolation_uninit_mm(void)
 
 	destroy_context(&kvm_mm);
 
+	kvm_isolation_uninit_page_table();
 	kvm_free_all_range_mapping();
 
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index 3ef2060..1f79e28 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -3,6 +3,16 @@
 #define ARCH_X86_KVM_ISOLATION_H
 
 #include <linux/kvm_host.h>
+#include <linux/export.h>
+
+/*
+ * Copy the memory mapping for the current module. This is defined as a
+ * macro to ensure it is expanded in the module making the call so that
+ * THIS_MODULE has the correct value.
+ */
+#define kvm_copy_module_mapping()			\
+	(kvm_copy_ptes(THIS_MODULE->core_layout.base,	\
+	    THIS_MODULE->core_layout.size))
 
 DECLARE_STATIC_KEY_FALSE(kvm_isolation_enabled);
 
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 70b7123..fb0ab9a 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -70,6 +70,8 @@
 
 extern void *pcpu_base_addr;
 extern const unsigned long *pcpu_unit_offsets;
+extern int pcpu_unit_size;
+extern int pcpu_nr_units;
 
 struct pcpu_group_info {
 	int			nr_units;	/* aligned # of units */
diff --git a/mm/percpu.c b/mm/percpu.c
index 68dd2e7..b68b3d8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -119,8 +119,10 @@
 #endif	/* CONFIG_SMP */
 
 static int pcpu_unit_pages __ro_after_init;
-static int pcpu_unit_size __ro_after_init;
-static int pcpu_nr_units __ro_after_init;
+int pcpu_unit_size __ro_after_init;
+EXPORT_SYMBOL(pcpu_unit_size);
+int pcpu_nr_units __ro_after_init;
+EXPORT_SYMBOL(pcpu_nr_units);
 static int pcpu_atom_size __ro_after_init;
 int pcpu_nr_slots __ro_after_init;
 static size_t pcpu_chunk_struct_size __ro_after_init;
-- 
1.7.1

