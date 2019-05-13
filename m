Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84A23C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39B3B2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m4RXoI1f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39B3B2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDFF86B0270; Mon, 13 May 2019 10:39:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C69356B0271; Mon, 13 May 2019 10:39:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0CCA6B0272; Mon, 13 May 2019 10:39:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE776B0270
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:35 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s16so4234557ioe.22
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=bWRO35KV4FFQ3ievQKGZUgx84GSk+HyQdow97r7zwRo=;
        b=Js76tlH/DOubF1QxoOSPElcuDoIto+/8mfO9+o6RoMhGX4RLEHytnB+z14R4d5ToSv
         e7hrYsTd2O7sHgV3HWrkDUUt4Gz6pOf7Lrw00y73T0jI+6IW224TogLB9RM6G8XxOlM9
         NwHbbPNmXlHm0mqnzMp1e+vAzI9tm6trnykrAIcpJV+18+qMwoNRRRE/qIFbHhJc9Kjl
         qnuT6It+Y+c9mi8fWkQHTfMq7Gmq9nJOK/X0AhLxxmmJpopd4YMM0VabyqBPbStdOrTZ
         nlOtQ9R0BVfqHRhAWGhbYzozILZ8CGnKWaplVTJG3mr4VhnB8Sr/wc1pwhApSxq1Nsgl
         xZtg==
X-Gm-Message-State: APjAAAUsWvGY8GOBNRRA9dePaEJQL3isPZW9KEB5F1UXyt/IsZsFFXqh
	Gh9ex6AFApNoPBSE+cz9ob4gnCE173yq/f54qtQef2wWavXoFCTHRPEMgXGPwWDPx8vXarJHctc
	jKFuKFAZrXGgahkO/GC+rsCC33w0phmlPmVAqlBoauwe6omWwlkbQohdajHH7o4ZQSw==
X-Received: by 2002:a6b:6619:: with SMTP id a25mr15889849ioc.131.1557758375294;
        Mon, 13 May 2019 07:39:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+E1gvQJxoObq4NNNB9Vdx/wTnS4lNxJkOG5Z5SU7wyoo7yPtnUuGBA6ceN7dJojbAkySg
X-Received: by 2002:a6b:6619:: with SMTP id a25mr15889800ioc.131.1557758374483;
        Mon, 13 May 2019 07:39:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758374; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5rY7r9pfL/zdRi27+7G3TLHLcPcIt+YLNXKDwdVidmrj5Avcj+MyWiwuzRm3bn4WT
         LzivXgNLYQ5I4CabRybVwD+qrc3mwLKFEkVbwQN0jjesRPAT4qG+DZgPVfaWds39LrSd
         gHvzOMW7UdlYj/XwTOxbMOX3isNrb/SHUrlLL33/7ZlbmHIrHXdGcRYrjn2cFzmfkpox
         8VTieLEa0zVdgGKOSeWv38TM6jCAlqMusQRirWD+qvsCOVxKe5DX16lqJxoaSD4zE85b
         7iB9TEAMddoGBr+FMMlK8LqJpfFV/7KEdoUIyuihRdM1YRi8POdQJoueV8NLyVan0aVy
         XYyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=bWRO35KV4FFQ3ievQKGZUgx84GSk+HyQdow97r7zwRo=;
        b=a8PY4rHSQZFxbCssC2ux8ZYOa4fbk25Adg2aPhk2M/Qrb4cpxkwHedlrsZoEUcCxO3
         nzu1DA5UDGfLzpeCXI71k/X2ApM2pqacdbtt/EITcfet4BmBuLC3QJQC69m8uqfQw2am
         BvUbUsMM+kwxjLS5D4CKQRF82UuWE+Krr8iklkH3funcF3aUbfBFXnilUZOOTIaeAAYC
         ZpEeZfPrqYtH3AKO60OeneP3q1y86RJYYEAeWF6H9yzc+GDjUQcFvKUEjpbqagGYUw/0
         B/D2zy6Bm6UPSZEQA9lnpwvGLc1YRmz7XFAiwAJinaumdlAL+Jh4WvwR8C+t55MqqGlm
         6VUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m4RXoI1f;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f17si8580946itk.6.2019.05.13.07.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m4RXoI1f;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd3Xk181510;
	Mon, 13 May 2019 14:39:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=bWRO35KV4FFQ3ievQKGZUgx84GSk+HyQdow97r7zwRo=;
 b=m4RXoI1fsAKJ65HwcxYTTiRielpSLksHyApCP0jeXXPvtewp5rwRVYDUYtxPM3t1rURV
 OUQPSWm2qaD3jmmQMsTFovUD4DnaSZ9GrLWp+D/fBi4LLvQVebxgVSc9OJHFf2CRAqzr
 jMs2DWV9OiHzkIdKAyWvrDZ3MS42p42Wdt2fSuBYwE1/w/asqQj5umS4w9GtEYvIA23u
 3rWtsxf8YqaVnsN0/d1amhOkTseV2bABVDPs67GwZ9yZi2jVBvqt2G58KXhAHzSc5cet
 2eTD9xR3JIRNVohIEeFBP6T1HxJGuEpp2qFDS0MQNFcDFncFDyVl1u6MqmF255tAofwm Xw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2sdnttfeh6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:25 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQI022780;
	Mon, 13 May 2019 14:39:22 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 15/27] kvm/isolation: keep track of VA range mapped in KVM address space
Date: Mon, 13 May 2019 16:38:23 +0200
Message-Id: <1557758315-12667-16-git-send-email-alexandre.chartre@oracle.com>
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

This will be used when we have to clear mappings to ensure the same
range is cleared at the same page table level it was copied.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   86 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 4f1b511..c8358a9 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -61,6 +61,20 @@ struct pgt_directory_group {
 #define PGTD_ALIGN(entry)	\
 	((typeof(entry))(((unsigned long)(entry)) & PAGE_MASK))
 
+/*
+ * Variables to keep track of address ranges mapped into the KVM
+ * address space.
+ */
+struct kvm_range_mapping {
+	struct list_head list;
+	void *ptr;
+	size_t size;
+	enum page_table_level level;
+};
+
+static LIST_HEAD(kvm_range_mapping_list);
+static DEFINE_MUTEX(kvm_range_mapping_lock);
+
 
 struct mm_struct kvm_mm = {
 	.mm_rb			= RB_ROOT,
@@ -91,6 +105,52 @@ struct mm_struct kvm_mm = {
 static bool __read_mostly address_space_isolation;
 module_param(address_space_isolation, bool, 0444);
 
+static struct kvm_range_mapping *kvm_get_range_mapping_locked(void *ptr,
+							      bool *subset)
+{
+	struct kvm_range_mapping *range;
+
+	list_for_each_entry(range, &kvm_range_mapping_list, list) {
+		if (range->ptr == ptr) {
+			if (subset)
+				*subset = false;
+			return range;
+		}
+		if (ptr > range->ptr && ptr < range->ptr + range->size) {
+			if (subset)
+				*subset = true;
+			return range;
+		}
+	}
+
+	return NULL;
+}
+
+static struct kvm_range_mapping *kvm_get_range_mapping(void *ptr, bool *subset)
+{
+	struct kvm_range_mapping *range;
+
+	mutex_lock(&kvm_range_mapping_lock);
+	range = kvm_get_range_mapping_locked(ptr, subset);
+	mutex_unlock(&kvm_range_mapping_lock);
+
+	return range;
+}
+
+static void kvm_free_all_range_mapping(void)
+{
+	struct kvm_range_mapping *range, *range_next;
+
+	mutex_lock(&kvm_range_mapping_lock);
+
+	list_for_each_entry_safe(range, range_next,
+				 &kvm_range_mapping_list, list) {
+		list_del(&range->list);
+		kfree(range);
+	}
+
+	mutex_unlock(&kvm_range_mapping_lock);
+}
 
 static struct pgt_directory_group *pgt_directory_group_create(void)
 {
@@ -661,10 +721,30 @@ static int kvm_copy_mapping(void *ptr, size_t size, enum page_table_level level)
 {
 	unsigned long addr = (unsigned long)ptr;
 	unsigned long end = addr + ((unsigned long)size);
+	struct kvm_range_mapping *range_mapping;
+	bool subset;
+	int err;
 
 	BUG_ON(current->mm == &kvm_mm);
-	pr_debug("KERNMAP COPY addr=%px size=%lx\n", ptr, size);
-	return kvm_copy_pgd_range(&kvm_mm, current->mm, addr, end, level);
+	pr_debug("KERNMAP COPY addr=%px size=%lx level=%d\n", ptr, size, level);
+
+	range_mapping = kmalloc(sizeof(struct kvm_range_mapping), GFP_KERNEL);
+	if (!range_mapping)
+		return -ENOMEM;
+
+	err = kvm_copy_pgd_range(&kvm_mm, current->mm, addr, end, level);
+	if (err) {
+		kfree(range_mapping);
+		return err;
+	}
+
+	INIT_LIST_HEAD(&range_mapping->list);
+	range_mapping->ptr = ptr;
+	range_mapping->size = size;
+	range_mapping->level = level;
+	list_add(&range_mapping->list, &kvm_range_mapping_list);
+
+	return 0;
 }
 
 
@@ -720,6 +800,8 @@ static void kvm_isolation_uninit_mm(void)
 
 	destroy_context(&kvm_mm);
 
+	kvm_free_all_range_mapping();
+
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	/*
 	 * With PTI, the KVM address space is defined in the user
-- 
1.7.1

