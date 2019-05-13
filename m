Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7130BC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 208AF2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Jr5TCZD/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 208AF2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47BB56B0269; Mon, 13 May 2019 10:39:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC2D6B026A; Mon, 13 May 2019 10:39:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20A1D6B026B; Mon, 13 May 2019 10:39:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8BFB6B026A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:20 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id m20so6803168itn.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=lqyn+UMxH2H0mFstbeYlyK/O28QxJu29o92QL7NqRo0=;
        b=oMBvnk3WW+IFxibxIHG2zxvtzWyK1FeS8ZELKRWLpSUpywjtDY9w5tWhS12KxIJLZC
         MgSapfhrqjJ71t3X3W7+NYj+i18JGGG/fabtXkcGJUFE590EnaLPQXg4KF1RHtRRjYJ/
         AIVaWsqkEm/Qy/hmEVPNRtLc3cvWOYxsgWtESc28g26Tz1e0ZOtrDNQy+jVqqUfKfSHc
         0XvYChYXY4xHYyCEsnLns7bMFpz4i63xmB8nGojiv9Tm1B9TMBSg2QPbsvb4pjUs7so8
         39eeU2fvkNYFHn4RDXGg+b4IXgBhjJoVL4cQGs/qrpibSLtwd5ajFO0pIhjSeUi9goIN
         Gvig==
X-Gm-Message-State: APjAAAVjQpbMYWyD6RHyg2RewLIy1SF1z04pr1wrJqP6NrmHbNjV+5IW
	5vO1IryuhOHhYDbbLpatxYRf1iwsJFjaOuXEj204FMEle/sIjXtOE/P/bL3t5tgCi5Pc1BVPp0M
	Tw1ZGfcgVrbiKjZcoihrKAuhd7x0jO53eQtXg97bUc9BQpk95jMd1KtGZGC9OTz2gvA==
X-Received: by 2002:a24:56c7:: with SMTP id o190mr18572988itb.120.1557758360664;
        Mon, 13 May 2019 07:39:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCyBpbZ+ZUQa8HX1Woieu8tdY2X5ppMZzvd3aAtzO2LdJtrYB+9iWF3+6w/qTfEvq6XMyX
X-Received: by 2002:a24:56c7:: with SMTP id o190mr18572906itb.120.1557758359640;
        Mon, 13 May 2019 07:39:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758359; cv=none;
        d=google.com; s=arc-20160816;
        b=BxxeQma1NwlN36teOC8SFulbshrmo/3MpLWtP7zA1PDRW5hEwkCjnBzYZL1UmXErAx
         CY2dxHSoZrJjyvQID0DRTiVtP6pQWkqBguIHRpVyJq+YxrdceG6sNIvZZdwm+NVyKd03
         Vj2OBxyz9QwwsiH3VulfcA2z+MD3yIqhjVaKqXihwbfsO4HGs9Aa0Qtmtm8O7dlh6T1S
         fPVy09DXoyf2bhVBjcIyFo8Fi4v3vxuS5zHlabpQ2JfnoqipB3KGyu8OqlsXVXtWSBE2
         Jxd17+c9zweB6GodnnLru694jeP/Kx2nT5/xd1OYJIvwhzObF2Vrz9EW2Z4mO9HD3f3N
         f82w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=lqyn+UMxH2H0mFstbeYlyK/O28QxJu29o92QL7NqRo0=;
        b=QwNdhxvUwMENZT/jP3G7nfnJh/ror0dQJ5/JGiMedFR65AR8qsKbIUkaSG6/pjjQ5d
         zZ+ZB5rmsXiTDfHUqjQNxHhyaVaYOURlULwsoRtopgNB30B0g2lVNKDaOAW29qROsfPJ
         CVA6iYVqu7exBMwbao1W0RfJNxnQQqX1l0Ekp3xZTa38dvS7zZnduVaTbOxUJGZPQByx
         Y2rTbKr1GN+DdDGCb856zv5x8xr6A2ve4xW3Qy9MUHfiNwlvd6TkKcuIBGTtOY2Iy6rp
         wLHEu0CRuBBxuApp00ed0FbnMBnmajC3G5c63NEX+t763MSltU3Io/o/NXJh468NucXd
         CKhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Jr5TCZD/";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m69si8151116itb.96.2019.05.13.07.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Jr5TCZD/";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2hT193056;
	Mon, 13 May 2019 14:39:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=lqyn+UMxH2H0mFstbeYlyK/O28QxJu29o92QL7NqRo0=;
 b=Jr5TCZD/u/xNJPZvrSFuZJzX/+fkjXUeKcGKj+LAFsPLKhL5qgqU35GRnUUc8xQu8pLv
 kJ2cgm2Uaj8fWZEV+R26AC0h34/IHr0xch9O9VC8DBfJZs45MDHArPHOrKH2BZgkZn0g
 Vo1Qsw+WtWbru1nSWeUWRDzk0S8BMwbmJOSxY9hDJpCKuZ4Rjcl9KR+8ZAUPwwUnSucl
 F6NkZr7jZnrzkGGfd72bek1kv1u5Rb/uWnD+/v6jia+yUhHtbKzvABFRbX3KACRbuEhG
 GYu3aCArrPJv0oQqS9LptBfUuYpEaXqIKNe+OKRLzFVYsoDNcshbQCQH2UMO7meQY53G qQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfkvq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:08 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQC022780;
	Mon, 13 May 2019 14:39:05 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 09/27] kvm/isolation: function to track buffers allocated for the KVM page table
Date: Mon, 13 May 2019 16:38:17 +0200
Message-Id: <1557758315-12667-10-git-send-email-alexandre.chartre@oracle.com>
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

The KVM page table will have direct references to the kernel page table,
at different levels (PGD, P4D, PUD, PMD). When freeing the KVM page table,
we should make sure that we free parts actually allocated for the KVM
page table, and not parts of the kernel page table referenced from the
KVM page table. To do so, we will keep track of buffers when building
the KVM page table.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |  119 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 43fd924..1efdab1 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -8,12 +8,60 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/printk.h>
+#include <linux/slab.h>
 
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 
 #include "isolation.h"
 
+
+enum page_table_level {
+	PGT_LEVEL_PTE,
+	PGT_LEVEL_PMD,
+	PGT_LEVEL_PUD,
+	PGT_LEVEL_P4D,
+	PGT_LEVEL_PGD
+};
+
+/*
+ * The KVM page table can have direct references to the kernel page table,
+ * at different levels (PGD, P4D, PUD, PMD). When freeing the KVM page
+ * table, we should make sure that we free parts actually allocated for
+ * the KVM page table, and not parts of the kernel page table referenced
+ * from the KVM page table.
+ *
+ * To do so, page table directories (struct pgt_directory) are used to keep
+ * track of buffers allocated when building the KVM page table. Also, as
+ * a page table can have many buffers, page table directory groups (struct
+ * (pgt_directory_group) are used to group page table directories and save
+ * some space (instead of allocating each directory individually).
+ */
+
+#define PGT_DIRECTORY_GROUP_SIZE	64
+
+struct pgt_directory {
+	enum page_table_level level;
+	void *ptr;
+};
+
+struct pgt_directory_group {
+	struct list_head list;
+	int count;
+	struct pgt_directory directory[PGT_DIRECTORY_GROUP_SIZE];
+};
+
+static LIST_HEAD(kvm_pgt_dgroup_list);
+static DEFINE_MUTEX(kvm_pgt_dgroup_lock);
+
+/*
+ * Get the pointer to the beginning of a page table directory from a page
+ * table directory entry.
+ */
+#define PGTD_ALIGN(entry)	\
+	((typeof(entry))(((unsigned long)(entry)) & PAGE_MASK))
+
+
 struct mm_struct kvm_mm = {
 	.mm_rb			= RB_ROOT,
 	.mm_users		= ATOMIC_INIT(2),
@@ -43,6 +91,77 @@ struct mm_struct kvm_mm = {
 static bool __read_mostly address_space_isolation;
 module_param(address_space_isolation, bool, 0444);
 
+
+static struct pgt_directory_group *pgt_directory_group_create(void)
+{
+	struct pgt_directory_group *dgroup;
+
+	dgroup = kzalloc(sizeof(struct pgt_directory_group), GFP_KERNEL);
+	if (!dgroup)
+		return NULL;
+
+	INIT_LIST_HEAD(&dgroup->list);
+	dgroup->count = 0;
+
+	return dgroup;
+}
+
+static bool kvm_add_pgt_directory(void *ptr, enum page_table_level level)
+{
+	struct pgt_directory_group *dgroup;
+	int index;
+
+	mutex_lock(&kvm_pgt_dgroup_lock);
+
+	if (list_empty(&kvm_pgt_dgroup_list))
+		dgroup = NULL;
+	else
+		dgroup = list_entry(kvm_pgt_dgroup_list.next,
+				    struct pgt_directory_group, list);
+
+	if (!dgroup || dgroup->count >= PGT_DIRECTORY_GROUP_SIZE) {
+		dgroup = pgt_directory_group_create();
+		if (!dgroup) {
+			mutex_unlock(&kvm_pgt_dgroup_lock);
+			return false;
+		}
+		list_add_tail(&dgroup->list, &kvm_pgt_dgroup_list);
+	}
+
+	index = dgroup->count;
+	dgroup->directory[index].level = level;
+	dgroup->directory[index].ptr = PGTD_ALIGN(ptr);
+	dgroup->count = index + 1;
+
+	mutex_unlock(&kvm_pgt_dgroup_lock);
+
+	return true;
+}
+
+static bool kvm_valid_pgt_entry(void *ptr)
+{
+	struct pgt_directory_group *dgroup;
+	int i;
+
+	mutex_lock(&kvm_pgt_dgroup_lock);
+
+	ptr = PGTD_ALIGN(ptr);
+	list_for_each_entry(dgroup, &kvm_pgt_dgroup_list, list) {
+		for (i = 0; i < dgroup->count; i++) {
+			if (dgroup->directory[i].ptr == ptr) {
+				mutex_unlock(&kvm_pgt_dgroup_lock);
+				return true;
+			}
+		}
+	}
+
+	mutex_unlock(&kvm_pgt_dgroup_lock);
+
+	return false;
+
+}
+
+
 static int kvm_isolation_init_mm(void)
 {
 	pgd_t *kvm_pgd;
-- 
1.7.1

