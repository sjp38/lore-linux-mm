Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADF3EC74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67BD221019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="keVQsRLh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67BD221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9366A8E00D0; Thu, 11 Jul 2019 10:26:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 871DF8E00C4; Thu, 11 Jul 2019 10:26:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA4C8E00D0; Thu, 11 Jul 2019 10:26:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4865B8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:39 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so6955921iob.14
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Ag0k+tMlXoCUCjgmP3NxD1Cl4FnNgcaLg1SLsqSglmA=;
        b=sAJGt/5QBTvFocxxinOowTIVs/HeK+Ofru8WFiVm2G/oINKg7+dvDmBF89SJSRATX4
         O32Ly01Kuh8beaQ9aR8KB2BOp0DKwG2ujvV/dGjdVahk9rcxosLsQ0+d5BxMh9Xab5pc
         mFFGyIMV2Ei2im0D59uhDh3v5wm8L+/u0RqmuVHHYVwcExkxDUDK80dRsfpeWvQjS13V
         NkQlU6s4qUCpJgqhlCC8yNYHMidvle0hN0c2wSPhd//M/uhwv7DwGEZCgw4KKtfmDwmg
         iGQdGj2PWUQBTN63gWC+ejP8WfmJ5qVdiyOxIqISMknypnFji0bbuvNB1T60GPPG4C1+
         xdDg==
X-Gm-Message-State: APjAAAXLjmN/2V33KbMSz1HtHmtKEhTxTBNVqV9sh57SRq579h7vd23Q
	UeBOs3mCkg100u27buAYkClD+t6Zt10gBdMwFWGnZ6TJXhXBuX6o7yjZ2f9En/3jMmkvcE/5ibt
	W+oXzzXdCg66iNvGxOVtXPSQaOLND4gEWE2Es819M4qL8qGIBkgt0fYYe9Fc4c/NI2g==
X-Received: by 2002:a6b:5115:: with SMTP id f21mr4752023iob.173.1562855199091;
        Thu, 11 Jul 2019 07:26:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8t0ZRyRV502o/BpWpsPvHc0IuQoI0KYc8bn3Y37gjQbnB8wrcrbDQXrgCEIzfwLhObNq1
X-Received: by 2002:a6b:5115:: with SMTP id f21mr4751956iob.173.1562855198449;
        Thu, 11 Jul 2019 07:26:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855198; cv=none;
        d=google.com; s=arc-20160816;
        b=QzXMnhK5FWYqhImBVF+jJHDD/nZTjl565FfhEnpv/XEHIO4igz4KwWJshR7+kgVz5z
         35ZFKhXD3pIXEanmGMAtWe14j5LsZ+bPChm6j3R6g/LXVncSbzdvNH4hKas3W5ixLBeN
         xIFV9rLsyhFIIUbgooBHPMjwf0N/cCkjbh3OPD+kFzSKRxV2YztydRzm+G8zMgtCSw0k
         I/V/P0EqiyrAcirYbt4GfWEb7z1k50iFKGTHpSbtEfWRV2jOWhd/swFz+sFwuqAfmqF0
         TyuQjzEtbGCe8gIPMmSDQRAEp9xOfVZX5N0u4yAKUoiGew7+k1LqK6rvAPKKDq9HMq6r
         Q1Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Ag0k+tMlXoCUCjgmP3NxD1Cl4FnNgcaLg1SLsqSglmA=;
        b=QZbV0ei2gVRcX5sUOURklQFzrAVvKnw+yUtAoFfzBwjyi+cHPDPMiGxb0JqMNmMqhr
         /9YKMV5pafgR2J6uwQMaUPmwxywJmfw+hqDHY7jVrQAMU3bXXdXUEiDxEmAf0WZoic4u
         gAQch9ti3ltDs90/Rs7q++gLMjObzZAOiN46Kip4JtwwC6D54iuqz7DiLSYdbqWqFgbi
         uy/9EvX26AQXeTjrKC4CEcEAHufqzgdG/L5QEqp9f0Uh9REuYNHBMK06Es6eYe7RY6pE
         vMpBy/euXNNaFt7eCUUB9qWtP56e1dr3xVkYVEC5T6Nfye5704khyHnVCzbse7xWqQiw
         BRpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=keVQsRLh;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id y14si10133684jan.93.2019.07.11.07.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=keVQsRLh;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOAvB001518;
	Thu, 11 Jul 2019 14:26:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=Ag0k+tMlXoCUCjgmP3NxD1Cl4FnNgcaLg1SLsqSglmA=;
 b=keVQsRLhZyNb/dFJnnzguyu+6Vl7qT1iW80eQJUi6p8HUYNezOn2M6QRB0NcNQhQI7JT
 5HACwzQ7vK/fKkmWqNIFxS0mv8uBEA1J5s9pHNXY/wHvMqw/x77ya8pCk5djXXg3w8tA
 Y+DFHNzDwpT4d81yj2dhIMIFubn8ssOAMPMn8hTz8Cg2l5maUEKHDpqBF2nYVJbVIius
 zq+q7wJ21XaxrzeREUMqbHN8popuelxmyOtwjWh5plKHWNmsE8C4KEMn9NIt7tf3KMir
 nsOpTlKGCKH8e0WHGLCVGvgf9UFWaCxJYPAxRKOlsGhf5idexkvlsNaYd43tN8SZVOoQ SA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0dyw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:28 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu6021444;
	Thu, 11 Jul 2019 14:26:25 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 13/26] mm/asi: Add asi_remap() function
Date: Thu, 11 Jul 2019 16:25:25 +0200
Message-Id: <1562855138-19507-14-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=832 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a function to remap an already mapped buffer with a new address
in an ASI page-table: the already mapped buffer is unmapped, and a
new mapping is added for the specified new address.

This is useful to track and remap a buffer which can be freed and
then reallocated.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    1 +
 arch/x86/mm/asi_pagetable.c |   25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index 912b6a7..cf5d198 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -84,6 +84,7 @@ extern int asi_map_range(struct asi *asi, void *ptr, size_t size,
 			 enum page_table_level level);
 extern int asi_map(struct asi *asi, void *ptr, unsigned long size);
 extern void asi_unmap(struct asi *asi, void *ptr);
+extern int asi_remap(struct asi *asi, void **mapping, void *ptr, size_t size);
 
 /*
  * Copy the memory mapping for the current module. This is defined as a
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index a4fe867..1ff0c47 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -842,3 +842,28 @@ int asi_map_percpu(struct asi *asi, void *percpu_ptr, size_t size)
 	return 0;
 }
 EXPORT_SYMBOL(asi_map_percpu);
+
+int asi_remap(struct asi *asi, void **current_ptrp, void *new_ptr, size_t size)
+{
+	void *current_ptr = *current_ptrp;
+	int err;
+
+	if (current_ptr == new_ptr) {
+		/* no change, already mapped */
+		return 0;
+	}
+
+	if (current_ptr) {
+		asi_unmap(asi, current_ptr);
+		*current_ptrp = NULL;
+	}
+
+	err = asi_map(asi, new_ptr, size);
+	if (err)
+		return err;
+
+	*current_ptrp = new_ptr;
+
+	return 0;
+}
+EXPORT_SYMBOL(asi_remap);
-- 
1.7.1

