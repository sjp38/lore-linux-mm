Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44DC6C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED62F2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="phOTgVyR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED62F2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5B946B0293; Mon, 13 May 2019 10:40:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD9196B0294; Mon, 13 May 2019 10:40:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95BB76B0295; Mon, 13 May 2019 10:40:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 754896B0293
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:40:14 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id p23so12279171itc.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:40:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=bVamqx26WofIGHx47Rok5tY+OeXg0YuA7C3C4gCjugU=;
        b=PcM0BrtnaYJPauU4M+QPFzHRSVHOMi9HhalkOvPQ+dsvJPACHAmLGkvgYUibRS6pDu
         4IvzvjRBgo97H8RolSeegzyTd7/ifFUIln9HODzgWodr3luN+dV9wiuXmLg7y4Qb5PGe
         CLlFv9Ucyu2Ri2kRhN4xKradq2FaplcJbiy5d0hxHpSaA8qHRg7Dle0qn5j1iLxPLqUr
         Om5Y5qBQpJzpjzG+45TV1kwV1l3JCY+XqvVMFQ54ig7CCJu9tSuFghutNqKoTB+joTR9
         xMOvKHL27ZbHRxI1Vk1G3nage7BXg2gp8pCvcXSc0+CHNg9aTnumlWqH7Fg7aHwFUC/z
         a7zA==
X-Gm-Message-State: APjAAAUMO4IB6+6tl9lruLttMi35xrkr7Da9JdR8E7HX15JLri6+HJIb
	0ObZ3YXq/Y6X70K+i9S76vWh/bTntz9AzcJZHxQpmSILdvybRqK8XnhYCiR9826hRVzv4NaPr68
	8eTfCLMuJbTexhHW3UOsWAiTf9KN2d1t26K8AMBtJCxjryD6SwOAPrPaE2Zw1102MPg==
X-Received: by 2002:a24:a088:: with SMTP id o130mr10510858ite.86.1557758414216;
        Mon, 13 May 2019 07:40:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj5Ku0wlF057h5m6/H1UZiEKJu5IcutsDURxLQ8fcqi2GI6hAyObuoRS9dstQ0NTHALuwx
X-Received: by 2002:a24:a088:: with SMTP id o130mr10510790ite.86.1557758413386;
        Mon, 13 May 2019 07:40:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758413; cv=none;
        d=google.com; s=arc-20160816;
        b=0Iwo/+tsGDDwMNP/cmgFnGXqzXDpbq2ks/O5IeT7PTxof/WbCiLXxN1AqRsKRTFvnG
         cXeechGbeEIxiL/TUM9tAElQr19ASzG45+GO7Aduqqmwvk3SbZKBeYQ8RofvNVeCL+np
         iCX+EhNU4iApwWj/SAVHokc6A20jOSgMsE+y3hMbLlOKKuTHiDnVHQjg/YnNu1d1j5V5
         8N+3qSHEIg93eZeqFSVsJI4jHMovDhHD3QBpPYc6BVQ2D8iv4HmT/KEQrUMmf+pn9I+U
         qjHDw8m1t13HEUHl/V1jsSe8DbuB8mkNQhQPpw56/uE14D8dA/M4SkDwlvjmd3mVb9ku
         91bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=bVamqx26WofIGHx47Rok5tY+OeXg0YuA7C3C4gCjugU=;
        b=L+3cpjyNOx0/4mdQlOZXsjLTWweay5qF9VWhzNiD42jTrHNAIZZ+iy5i/OVwU/IX+S
         E9+Kk4y1XE1/T5mGIS369+JVDVdt0nW9TtJaayJtfOXDV1Teoj1Ri7vAAoyZ6SaAx1K3
         OM374jMDi0JuvPkbM3eJUkEB/f7dw7Gqu9IK4iEwO35exnZP7ch3TyXwOBK1+rux62oG
         1yOQZd0A4VQVr+dhWCt3lQxanMmZRacbvMQEz6hekzoVJ+vLZITC2Dyqt2vG6jMQ2bG4
         J7esZ++vLa7OI/BLHE6EtPdh7KzJzDN5zm6wGsznRy4sO3usPvk4isPTHMe1yvCLmHWI
         qSgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=phOTgVyR;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j63si8776272itb.19.2019.05.13.07.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:40:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=phOTgVyR;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2K2181455;
	Mon, 13 May 2019 14:40:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=bVamqx26WofIGHx47Rok5tY+OeXg0YuA7C3C4gCjugU=;
 b=phOTgVyRSmfJlShasjXR81DKx3htuPesB+i0d59gwRf4Pvj7Dim335VGDly6TaryasbH
 p79YnJpLHxV6ux2E6qwXe0qzqxgl9bjTmvmDzhmAzNh5lJ8rrhJ6ObfkWiFmfAq3lRJz
 K05CgDIVBI1/f6xo2nFMOruVDoE6XxhauS8j3PiqHmyqCTNH4xnpgnaVEUHrFTBXW7f2
 VLrhtdpEyD7KijA3Esx4FX4nbFn/WkBHai46PD3BIoP4/Hkwmpdc6QjQUAlSMhB2yCbA
 Ui+mFwRtvI4wzRar5LmOK42XboaGtSbIhchHkhsgVIP9GVewhcqNUP1Lh2Qu6jIn+TwR /w== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2sdnttfemt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:40:04 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQU022780;
	Mon, 13 May 2019 14:39:56 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 27/27] kvm/isolation: initialize the KVM page table with KVM buses
Date: Mon, 13 May 2019 16:38:35 +0200
Message-Id: <1557758315-12667-28-git-send-email-alexandre.chartre@oracle.com>
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

KVM buses can change after they have been created so new buses
have to be mapped when they are created.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   37 +++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h |    1 +
 arch/x86/kvm/x86.c       |   13 ++++++++++++-
 include/linux/kvm_host.h |    1 +
 virt/kvm/kvm_main.c      |    2 ++
 5 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 255b2da..329e769 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -1614,6 +1614,29 @@ void kvm_isolation_check_memslots(struct kvm *kvm)
 
 }
 
+void kvm_isolation_check_buses(struct kvm *kvm)
+{
+	struct kvm_range_mapping *rmapping;
+	struct kvm_io_bus *bus;
+	int i, err;
+
+	if (!kvm_isolation())
+		return;
+
+	for (i = 0; i < KVM_NR_BUSES; i++) {
+		bus = kvm->buses[i];
+		rmapping = kvm_get_range_mapping(bus, NULL);
+		if (rmapping)
+			continue;
+		pr_debug("remapping kvm buses[%d]\n", i);
+		err = kvm_copy_ptes(bus, sizeof(*bus) + bus->dev_count *
+		    sizeof(struct kvm_io_range));
+		if (err)
+			pr_debug("failed to map kvm buses[%d]\n", i);
+	}
+
+}
+
 int kvm_isolation_init_vm(struct kvm *kvm)
 {
 	int err, i;
@@ -1632,6 +1655,15 @@ int kvm_isolation_init_vm(struct kvm *kvm)
 			return err;
 	}
 
+	pr_debug("mapping kvm buses\n");
+
+	for (i = 0; i < KVM_NR_BUSES; i++) {
+		err = kvm_copy_ptes(kvm->buses[i],
+		    sizeof(struct kvm_io_bus));
+		if (err)
+			return err;
+	}
+
 	pr_debug("mapping kvm srcu sda\n");
 
 	return (kvm_copy_percpu_mapping(kvm->srcu.sda,
@@ -1650,6 +1682,11 @@ void kvm_isolation_destroy_vm(struct kvm *kvm)
 	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++)
 		kvm_clear_range_mapping(kvm->memslots[i]);
 
+	pr_debug("unmapping kvm buses\n");
+
+	for (i = 0; i < KVM_NR_BUSES; i++)
+		kvm_clear_range_mapping(kvm->buses[i]);
+
 	pr_debug("unmapping kvm srcu sda\n");
 
 	kvm_clear_percpu_mapping(kvm->srcu.sda);
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index 1e55799..b048946 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -33,6 +33,7 @@ static inline bool kvm_isolation(void)
 extern int kvm_copy_percpu_mapping(void *percpu_ptr, size_t size);
 extern void kvm_clear_percpu_mapping(void *percpu_ptr);
 extern void kvm_isolation_check_memslots(struct kvm *kvm);
+extern void kvm_isolation_check_buses(struct kvm *kvm);
 extern int kvm_add_task_mapping(struct task_struct *tsk);
 extern void kvm_cleanup_task_mapping(struct task_struct *tsk);
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 7d98e9f..3ba1996 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9253,6 +9253,13 @@ void kvm_arch_sync_events(struct kvm *kvm)
 	cancel_delayed_work_sync(&kvm->arch.kvmclock_sync_work);
 	cancel_delayed_work_sync(&kvm->arch.kvmclock_update_work);
 	kvm_free_pit(kvm);
+	/*
+	 * Note that kvm_isolation_destroy_vm() has to be called from
+	 * here, and not from kvm_arch_destroy_vm() because it will unmap
+	 * buses which are already destroyed when kvm_arch_destroy_vm()
+	 * is invoked.
+	 */
+	kvm_isolation_destroy_vm(kvm);
 }
 
 int __x86_set_memory_region(struct kvm *kvm, int id, gpa_t gpa, u32 size)
@@ -9331,7 +9338,6 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
 		x86_set_memory_region(kvm, IDENTITY_PAGETABLE_PRIVATE_MEMSLOT, 0, 0);
 		x86_set_memory_region(kvm, TSS_PRIVATE_MEMSLOT, 0, 0);
 	}
-	kvm_isolation_destroy_vm(kvm);
 	if (kvm_x86_ops->vm_destroy)
 		kvm_x86_ops->vm_destroy(kvm);
 	kvm_pic_destroy(kvm);
@@ -9909,6 +9915,11 @@ bool kvm_vector_hashing_enabled(void)
 }
 EXPORT_SYMBOL_GPL(kvm_vector_hashing_enabled);
 
+void kvm_arch_buses_updated(struct kvm *kvm, struct kvm_io_bus *bus)
+{
+	kvm_isolation_check_buses(kvm);
+}
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_exit);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_fast_mmio);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_inj_virq);
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index ad24d9e..1291d8d 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -199,6 +199,7 @@ void kvm_io_bus_unregister_dev(struct kvm *kvm, enum kvm_bus bus_idx,
 			       struct kvm_io_device *dev);
 struct kvm_io_device *kvm_io_bus_get_dev(struct kvm *kvm, enum kvm_bus bus_idx,
 					 gpa_t addr);
+void kvm_arch_buses_updated(struct kvm *kvm, struct kvm_io_bus *bus);
 
 #ifdef CONFIG_KVM_ASYNC_PF
 struct kvm_async_pf {
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 3c0c3db..374e79f 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3749,6 +3749,8 @@ int kvm_io_bus_register_dev(struct kvm *kvm, enum kvm_bus bus_idx, gpa_t addr,
 	synchronize_srcu_expedited(&kvm->srcu);
 	kfree(bus);
 
+	kvm_arch_buses_updated(kvm, new_bus);
+
 	return 0;
 }
 
-- 
1.7.1

