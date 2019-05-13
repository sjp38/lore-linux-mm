Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73DBEC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 295982084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="z6slNgJ9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 295982084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89A576B0272; Mon, 13 May 2019 10:39:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8255F6B0273; Mon, 13 May 2019 10:39:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64F906B0274; Mon, 13 May 2019 10:39:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA9A6B0272
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:41 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e126so10001391ioa.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=+MaSC7D5NYyFHcoLlt21rqwn+ky+e8tS8duegev3cnQ=;
        b=KkgIVfnbAFe051tkHrnXaKXf457PsKzxnWgSeVM+31XRSDXtkugXHiaOPKbH3XMRuf
         7AUNaa/uEMTgEnWoMxHe6KTJa5d4Jkp/X4peYYBRAfa/Um8jFgSDBtxW+J9k9388xxPZ
         tFZX3w/QUT7srqqGBqJOsN8zBBjY9ZXCkFYcMYXJ8OcOKH8NBdXjY7RL305VVSKtUnhu
         2jznaZybx0yLilhlKr5YMy+qupFtKTCGqRnNRc0ZLFSGRhdvHUrod5XWvUDpi3Lq6xkY
         VErK71riFO5fJ+jN18BczGd7JD/Y2o/Y31+zNJBX5m2QSz4C0rqdwALhae6tiOdJSml7
         eI1g==
X-Gm-Message-State: APjAAAUKrM64rfyH5q2T1winQPRShYRUaqHnUlIRI9YvYl5C9xMEIf1L
	U7kSiwS7rizmWsm+ovdkdFa6J7f7oz4oJV8B2SK4yblWHeLUMlLfNe8rdp/w+LjY4eenv+0rYte
	kGqaRluxyxt4x+7LkCLd2mdflr+mtOuMJa5auVJNrn7+gvS6TyRqSFAhX3On5dAz4ZQ==
X-Received: by 2002:a24:4d1:: with SMTP id 200mr12654563itb.92.1557758380961;
        Mon, 13 May 2019 07:39:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaZLboFPbkYyt7Ssz3BnwPe4ie2rJj0JtHP/Kxi/vfR20A5on/PfVY91i7nTMDFE1ZOUSw
X-Received: by 2002:a24:4d1:: with SMTP id 200mr12654510itb.92.1557758380133;
        Mon, 13 May 2019 07:39:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758380; cv=none;
        d=google.com; s=arc-20160816;
        b=UgB/Ey/4XBY3hBBnkt9bR/cmXzydQslMOSZdZO/uR0bO3lRSpiOwVSChIG1V92wZ04
         nKod0VK3SpFsunbuOqbVwU42ZB7iWH+2SxqxSrdL7rCAT04636MrhKmYmTPGt6R5xjFm
         6o8K44wGmA9ApGf8uR1ZUTL6LX5rt3gjsfBdJIetCAoZd8e46dtnilDeQ1zCu1+vm+06
         Hj4huYpGRU5FU/AlnRf+VLB9SJWcj3kDu68ej90jWgC9rKrEHy4POXNbQdCYSQjAakje
         q+RSg1uQRJqBxDJ/E9xh8qRletnbGNQO3Fno0Gy9CWr8svMywXnwvGcLzJgz/pLYTlqb
         bcXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=+MaSC7D5NYyFHcoLlt21rqwn+ky+e8tS8duegev3cnQ=;
        b=LNARPmmFElAlU0rxdecCFGlNTqtzjrHJ+6am7f6V67EBaUhVM5Pdu0jwK2Ia9SwR2h
         FbbMX3sY8a1k5w2UTe6Gs6V4pTbHlMGhNQ0Ina597C27flccWGpBBHHZ99uLMTXDmtGt
         1A4Ogyf6VwuWyF7S0ijWFDqXws3qtGSBDSgO6MUylF+R1qpQb4H66CP5y+X+LHqLmau9
         CGWNS6Sgp/79mXFLSF172SyU99uGMgzhWsRFHPyQvFPysPVFQTws9QsdFGu7fWC4cOVQ
         io5scaxE+FcFPiym39DFgnrhhRrOClyYwa/MFZhOd8ce30v/ZLoa9umdn276tz8qz37g
         M/cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z6slNgJ9;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b64si8275836iti.113.2019.05.13.07.39.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z6slNgJ9;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2Gn194925;
	Mon, 13 May 2019 14:39:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=+MaSC7D5NYyFHcoLlt21rqwn+ky+e8tS8duegev3cnQ=;
 b=z6slNgJ9MrFp8uPsBPJmJU6GEaQ8wt3ZidHa0OAjWLM8dA3+hvZO3Q2zqNmvKu+Qfvha
 f39YKjJiNdGzsIVZtiZmHgCAk3/RyTNp7XRWQJE/vV0AXPAhhrT+G+j8gHuyTYUQNX0f
 AIhcCp0PH4W5K5mBi7O15eBaUEQLLjjyWKwdghJjGta7Pwvvxw11nROudMT9WBKTJRLS
 bc5hFg0tiztOk+LrZZH2/SQPAOQVHBG6LvLcBcZDJcfhj/iVjW1L4APtEZtPI5sxvMGw
 RUUksDo71NnDOv56zatbXlgzV01aZsNu7msINVw4f0f0NjXKNnCv8fOY+KxWkWNogtPN 5Q== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7axg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:31 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQK022780;
	Mon, 13 May 2019 14:39:28 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 17/27] kvm/isolation: improve mapping copy when mapping is already present
Date: Mon, 13 May 2019 16:38:25 +0200
Message-Id: <1557758315-12667-18-git-send-email-alexandre.chartre@oracle.com>
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

A mapping can already exist if a buffer was mapped in the KVM
address space, and then the buffer was freed but there was no
request to unmap from the KVM address space. In that case, clear
the existing mapping before mapping the new buffer.

Also if the new mapping is a subset of an already larger mapped
range, then remap the entire larger map.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   67 +++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 63 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index e494a15..539e287 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -88,6 +88,9 @@ struct mm_struct kvm_mm = {
 DEFINE_STATIC_KEY_FALSE(kvm_isolation_enabled);
 EXPORT_SYMBOL(kvm_isolation_enabled);
 
+static void kvm_clear_mapping(void *ptr, size_t size,
+			      enum page_table_level level);
+
 /*
  * When set to true, KVM #VMExit handlers run in isolated address space
  * which maps only KVM required code and per-VM information instead of
@@ -721,6 +724,7 @@ static int kvm_copy_mapping(void *ptr, size_t size, enum page_table_level level)
 {
 	unsigned long addr = (unsigned long)ptr;
 	unsigned long end = addr + ((unsigned long)size);
+	unsigned long range_addr, range_end;
 	struct kvm_range_mapping *range_mapping;
 	bool subset;
 	int err;
@@ -728,22 +732,77 @@ static int kvm_copy_mapping(void *ptr, size_t size, enum page_table_level level)
 	BUG_ON(current->mm == &kvm_mm);
 	pr_debug("KERNMAP COPY addr=%px size=%lx level=%d\n", ptr, size, level);
 
-	range_mapping = kmalloc(sizeof(struct kvm_range_mapping), GFP_KERNEL);
-	if (!range_mapping)
-		return -ENOMEM;
+	mutex_lock(&kvm_range_mapping_lock);
+
+	/*
+	 * A mapping can already exist if the buffer was mapped and then
+	 * freed but there was no request to unmap it. We might also be
+	 * trying to map a subset of an already mapped buffer.
+	 */
+	range_mapping = kvm_get_range_mapping_locked(ptr, &subset);
+	if (range_mapping) {
+		if (subset) {
+			pr_debug("range %px/%lx/%d is a subset of %px/%lx/%d already mapped, remapping\n",
+				 ptr, size, level, range_mapping->ptr,
+				 range_mapping->size, range_mapping->level);
+			range_addr = (unsigned long)range_mapping->ptr;
+			range_end = range_addr +
+				((unsigned long)range_mapping->size);
+			err = kvm_copy_pgd_range(&kvm_mm, current->mm,
+						 range_addr, range_end,
+						 range_mapping->level);
+			if (end <= range_end) {
+				/*
+				 * We effectively have a subset, fully contained
+				 * in the superset. So we are done.
+				 */
+				mutex_unlock(&kvm_range_mapping_lock);
+				return err;
+			}
+			/*
+			 * The new range is larger than the existing mapped
+			 * range. So we need an extra mapping to map the end
+			 * of the range.
+			 */
+			addr = range_end;
+			range_mapping = NULL;
+			pr_debug("adding extra range %lx-%lx (%d)\n", addr,
+				 end, level);
+		} else {
+			pr_debug("range %px size=%lx level=%d already mapped, clearing\n",
+				 range_mapping->ptr, range_mapping->size,
+				 range_mapping->level);
+			kvm_clear_mapping(range_mapping->ptr,
+					  range_mapping->size,
+					  range_mapping->level);
+			list_del(&range_mapping->list);
+		}
+	}
+
+	if (!range_mapping) {
+		range_mapping = kmalloc(sizeof(struct kvm_range_mapping),
+		    GFP_KERNEL);
+		if (!range_mapping) {
+			mutex_unlock(&kvm_range_mapping_lock);
+			return -ENOMEM;
+		}
+		INIT_LIST_HEAD(&range_mapping->list);
+	}
 
 	err = kvm_copy_pgd_range(&kvm_mm, current->mm, addr, end, level);
 	if (err) {
+		mutex_unlock(&kvm_range_mapping_lock);
 		kfree(range_mapping);
 		return err;
 	}
 
-	INIT_LIST_HEAD(&range_mapping->list);
 	range_mapping->ptr = ptr;
 	range_mapping->size = size;
 	range_mapping->level = level;
 	list_add(&range_mapping->list, &kvm_range_mapping_list);
 
+	mutex_unlock(&kvm_range_mapping_lock);
+
 	return 0;
 }
 
-- 
1.7.1

