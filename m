Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97744C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E9E621019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MARahqNw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E9E621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9380B8E00CE; Thu, 11 Jul 2019 10:26:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8705C8E00C4; Thu, 11 Jul 2019 10:26:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69E528E00CE; Thu, 11 Jul 2019 10:26:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 410548E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:34 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id m26so6944794ioh.17
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=d9A9L3caok6Qomoe3AKAL7r9AlPWZpUNUtRWqLcduag=;
        b=BRsXY9kBDHERV6pMxPMGsuj4iwbAox9XsuY3UI/OLwLZ3od3+XGmxPh3ySVFi4Lua3
         HDcQWt3EGSsmh3H3BLLfU+aChtrDJa2FYEZ/yDcsB17GWuC1kfE5PrfHxWU/7s8nsJmJ
         AUwQYvJf/DB2Zrd6yskERdjfmffomV01rc6eGlkFF0MvR795bRaoo8JGG1+NoNiDX8jW
         mL9CiaftuVDbnblZSM33rgDtWyOLInm9EFawvj1m64bNd8d8R8vaTvlPmoKXyyCKmyJC
         nmyPTK6bFrxKhzAsFT7Coy4+lrZTx6CbwMxOurVHDi1tTAC/Yoqu/O4JnlKCcGiVHYc2
         caDg==
X-Gm-Message-State: APjAAAUzWNfltG4z+JFK8BAwaGpX5uo5JuuG0hlt49vFiq/FW3onF20T
	bZ4+QC7nsHOPHPOdTsqVTLBNF9/tY0p1MK4SzaMTCfQQjYxUk+BlFQ/bYFFaZa+Gc+V5FnNQnpJ
	ylcIohW+6s07LxKo7UGYrz1kB4vmuIe5c9XCVWJ9Mwa82rVfPux5GHdGP5T8wWkhrtQ==
X-Received: by 2002:a5d:94d0:: with SMTP id y16mr4260572ior.123.1562855194028;
        Thu, 11 Jul 2019 07:26:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDDl+yxbju+f8xOK1eSi7OK9Wm9bRbZsN4qar0H7pM/cArVt8t1Rk4jxjxSntbqDDkPjFa
X-Received: by 2002:a5d:94d0:: with SMTP id y16mr4260482ior.123.1562855193060;
        Thu, 11 Jul 2019 07:26:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855193; cv=none;
        d=google.com; s=arc-20160816;
        b=F4qDNJ2JACur4/gwrG/BMUkOzqn2+XUfWQKFX5VYafVm2c+78E+KhvbB14bTEbVpcT
         IaOp5Y/7hsPCYn7nSSu3DQFLkcsF7/VeFUHVF++OgP0x9gTHeXloyfOo9xLnwQiPOE/p
         8lwOABNeA2lHVtmMXc+jVdtSjtxoG2b0vY1DiILMQ0LyPau5cglQlpziBIHbpekYEVD8
         ye20ZPvgIQNzatni66GB9Ir1U2K6F4zX5Dhn9HdZHG0UgC4ak0Buwvdkq5eeefj5Jrfg
         LTUSlb99Mge/l2pmkgykAHc7jNnnvmg5d2RKMmai/tGtYKVd0s9PPj3EVhNvcTa8jEmS
         vEGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=d9A9L3caok6Qomoe3AKAL7r9AlPWZpUNUtRWqLcduag=;
        b=C9w4a2V9X/fzKryFvQ2KkN5CR66/VuEwdsOZoAsFLAFzrtmTLa703RJa42dEpwAb5b
         bwFXwCY1Viq3+tfu+/m2aKua8F0vgNzn0XNCmYPSx8JCVqDMaV8mveTuXQW4tx5zlZuP
         7lEbKDvSiEWzeBzk9079BTiJdt1a/AcLeCB1/u2Cmi/SruA7xAFqYcJFTB94LTZu+JdC
         ULS/G5osTnqVVW5szZWacbJMhnvRReXpzWYne9Ayj6ZfiSfTTHri54OcOv57uaPc6JyE
         nhaXEqiN7Jq1TN5xFvpyFciWQwVk0bqz06wo6jpN8r4yznkRXC6E8qPa/sTascnVLjYp
         BUJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MARahqNw;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y8si9041733jae.39.2019.07.11.07.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MARahqNw;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO7gN100410;
	Thu, 11 Jul 2019 14:26:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=d9A9L3caok6Qomoe3AKAL7r9AlPWZpUNUtRWqLcduag=;
 b=MARahqNw+qo/sURXfHbD3S/83gqCOgFJ/swtRFnPmTZXmwoCOVR/N/i1pIKlToYWY/Ri
 k2aBJrN9/v+khzouzf0G9zHxuoQwHwjL5cB4NqEmK6LZPn4Du9L8R3LvRixNs0Ek2k51
 TpfCDdoT/V5OQHZtXE2PjUdEaibVkBeu3OSq6a2iDA4XeaUx9Z+Ps6cN0b9Yifm/yA4j
 Iy9lSi7ma1G+usDIN0MJA79lNYFYSEqhzzbTW8owPRRK6v2c+xTImcLNpv1ndNvar4Yf
 gffkGfUVZ70Om45QblhdamFaGWrmGQZSauAg6M3MpWqBnQzN6fxwcMN6Aymg/BBEx4rs vQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2tjkkq0c8w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:23 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu3021444;
	Thu, 11 Jul 2019 14:26:15 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 10/26] mm/asi: Keep track of VA ranges mapped in ASI page-table
Date: Thu, 11 Jul 2019 16:25:22 +0200
Message-Id: <1562855138-19507-11-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=882 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add functions to keep track of VA ranges mapped in an ASI page-table.
This will be used when unmapping to ensure the same range is unmapped,
at the same page-table level. This is also be used to handle mapping
and unmapping of overlapping VA ranges.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    3 ++
 arch/x86/mm/asi.c           |    3 ++
 arch/x86/mm/asi_pagetable.c |   71 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index b5dbc49..be1c190 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -24,6 +24,7 @@ enum page_table_level {
 struct asi {
 	spinlock_t		lock;		/* protect all attributes */
 	pgd_t			*pgd;		/* ASI page-table */
+	struct list_head	mapping_list;	/* list of VA range mapping */
 
 	/*
 	 * An ASI page-table can have direct references to the full kernel
@@ -69,6 +70,8 @@ struct asi_session {
 
 void asi_init_backend(struct asi *asi);
 void asi_fini_backend(struct asi *asi);
+void asi_init_range_mapping(struct asi *asi);
+void asi_fini_range_mapping(struct asi *asi);
 
 extern struct asi *asi_create(void);
 extern void asi_destroy(struct asi *asi);
diff --git a/arch/x86/mm/asi.c b/arch/x86/mm/asi.c
index dfde245..25633a6 100644
--- a/arch/x86/mm/asi.c
+++ b/arch/x86/mm/asi.c
@@ -104,6 +104,8 @@ struct asi *asi_create(void)
 	if (!asi)
 		return NULL;
 
+	asi_init_range_mapping(asi);
+
 	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
 	if (!page)
 		goto error;
@@ -133,6 +135,7 @@ void asi_destroy(struct asi *asi)
 	if (asi->pgd)
 		free_page((unsigned long)asi->pgd);
 
+	asi_fini_range_mapping(asi);
 	asi_fini_backend(asi);
 
 	kfree(asi);
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index 0169395..a09a22d 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -5,10 +5,21 @@
  */
 
 #include <linux/mm.h>
+#include <linux/slab.h>
 
 #include <asm/asi.h>
 
 /*
+ * Structure to keep track of address ranges mapped into an ASI.
+ */
+struct asi_range_mapping {
+	struct list_head list;
+	void *ptr;			/* range start address */
+	size_t size;			/* range size */
+	enum page_table_level level;	/* mapping level */
+};
+
+/*
  * Get the pointer to the beginning of a page table directory from a page
  * table directory entry.
  */
@@ -75,6 +86,39 @@ void asi_fini_backend(struct asi *asi)
 	}
 }
 
+void asi_init_range_mapping(struct asi *asi)
+{
+	INIT_LIST_HEAD(&asi->mapping_list);
+}
+
+void asi_fini_range_mapping(struct asi *asi)
+{
+	struct asi_range_mapping *range, *range_next;
+
+	list_for_each_entry_safe(range, range_next, &asi->mapping_list, list) {
+		list_del(&range->list);
+		kfree(range);
+	}
+}
+
+/*
+ * Return the range mapping starting at the specified address, or NULL if
+ * no such range is found.
+ */
+static struct asi_range_mapping *asi_get_range_mapping(struct asi *asi,
+						       void *ptr)
+{
+	struct asi_range_mapping *range;
+
+	lockdep_assert_held(&asi->lock);
+	list_for_each_entry(range, &asi->mapping_list, list) {
+		if (range->ptr == ptr)
+			return range;
+	}
+
+	return NULL;
+}
+
 /*
  * Check if an offset in the address space isolation page-table is valid,
  * i.e. check that the offset is on a page effectively belonging to the
@@ -574,6 +618,7 @@ static int asi_copy_pgd_range(struct asi *asi,
 int asi_map_range(struct asi *asi, void *ptr, size_t size,
 		  enum page_table_level level)
 {
+	struct asi_range_mapping *range_mapping;
 	unsigned long addr = (unsigned long)ptr;
 	unsigned long end = addr + ((unsigned long)size);
 	unsigned long flags;
@@ -582,8 +627,34 @@ int asi_map_range(struct asi *asi, void *ptr, size_t size,
 	pr_debug("ASI %p: MAP %px/%lx/%d\n", asi, ptr, size, level);
 
 	spin_lock_irqsave(&asi->lock, flags);
+
+	/* check if the range is already mapped */
+	range_mapping = asi_get_range_mapping(asi, ptr);
+	if (range_mapping) {
+		pr_debug("ASI %p: MAP %px/%lx/%d already mapped\n",
+			 asi, ptr, size, level);
+		err = -EBUSY;
+		goto done;
+	}
+
+	/* map new range */
+	range_mapping = kmalloc(sizeof(*range_mapping), GFP_KERNEL);
+	if (!range_mapping) {
+		err = -ENOMEM;
+		goto done;
+	}
+
 	err = asi_copy_pgd_range(asi, asi->pgd, current->mm->pgd,
 				 addr, end, level);
+	if (err)
+		goto done;
+
+	INIT_LIST_HEAD(&range_mapping->list);
+	range_mapping->ptr = ptr;
+	range_mapping->size = size;
+	range_mapping->level = level;
+	list_add(&range_mapping->list, &asi->mapping_list);
+done:
 	spin_unlock_irqrestore(&asi->lock, flags);
 
 	return err;
-- 
1.7.1

