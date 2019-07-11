Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C030CC74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E9A92166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PEK1VY+3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E9A92166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC93C8E00D6; Thu, 11 Jul 2019 10:26:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D53A18E00C4; Thu, 11 Jul 2019 10:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF6148E00D6; Thu, 11 Jul 2019 10:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1F28E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:57 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s83so6957571iod.13
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=2d2Yv2y5zLW9fLZ4ZOO2tadSx6yS9UU2pD1uUkqP2I4=;
        b=S2koVFlXQLVeeIXDsSk+KOxPkmr7NVC/4/WNIiYcDhMeQ3MopJrwsgwjeQDADtDXxf
         esT8he/pA8KHS4XjSwr+2qpMwuHtoCvDib4jdyYEInK9swwqWgAqKb8fOBo8bK+f44ov
         dp2STZ+HffK8/ixjA2TTZnSZB9AEQpxWuWlwNqMq4bzAEvVLhJCvkqR3wlUYSfVYcUUA
         SVjmUiiVzGZgXARB+qFHYKFiGMCneCkaBe7mWD8setR+KCMYm60O1fkS2HGigFDUN5/R
         VzeP6gMlinxchl+8USaSfs+8t4RyTPMjN9JkRA8WT+XJGDwrz3jleKPfVR9d9tRybbxp
         Hc7Q==
X-Gm-Message-State: APjAAAUCX16wau4ucfWsVBEEzg9nbKQ3/rI4vIqWZREWWYfB7R8SRUY8
	+Y3Lx0MAT1pAZht2oEwp8fu2eL9zNdz4Is9D+OiXSoHy5t8ehFRgb4jKJ+GHJzYJcWhQhHnBhtl
	EaA20s5fHrjZPaSrbQXRZsgpPUHFnGczKickDjLuYrrKtDyKxDc1VNFj/ztQnAtIkzw==
X-Received: by 2002:a02:c65a:: with SMTP id k26mr4946560jan.18.1562855217318;
        Thu, 11 Jul 2019 07:26:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDjUgGt+CeojedCZJ6snqYdC29L32sFFsg7wreWm44hf7GEBmSUd3fW2Wzz6+5qisTGpwZ
X-Received: by 2002:a02:c65a:: with SMTP id k26mr4946509jan.18.1562855216724;
        Thu, 11 Jul 2019 07:26:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855216; cv=none;
        d=google.com; s=arc-20160816;
        b=VdwC/nlViLFtdph8m957S7Wuac3KaLVeDNLLbIHTVJbVbYYEJx/SmtXY00JWcwuI0N
         mnVNO570/eqkAUlhiVEIN1eBkXhBs6s8q3zp+y2/VB61tOkWxvBYk8jOZQ9/wK+oQuyh
         KpSZGD0rfA9i1R1HsVw1BHtj+PUO8+Oqoo8yh2w5h8BQojV+MdHz7i5OBfY+faYe5xeq
         P+Ra4rrga4tpXqXOHZR4gyxt4tboV43FKcvWppqU1mryjJ4Peqgruz/0OKZmChpP+1/k
         wXRIZp6jpa4LOD9o7V4o7JEBz6JCd+bL+XHMASRC9BARCdSccYXXaenXWRH1G9sfKKIB
         EMFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=2d2Yv2y5zLW9fLZ4ZOO2tadSx6yS9UU2pD1uUkqP2I4=;
        b=GbvKdnfH6A/ZYAsvwlXm80qJKjcn1g591lDoW0oYG4LXY/nOP9SxAvm99oxGzNV3J/
         haMZS5XuRVE3BPdC+qdh6K9ZO57mmuLoOrWwe1LL1jELsW8J9K8tdAPSM7+ELFbQTsjX
         MMrY5UuYtySJ+OBd2Z28/INp8dhPVWfKZLFI3p1joyoKTiP59kDCtq4bR1+nGGA2pVIq
         YJAUonA0wKaHHJ41mLNF/N6EZ2kVZVpR7bkQhFrQxCK2nGSkuots9PpG/5KBhGX67Yye
         I5syywcAxi9XBD0qUB6j6haLM2jiXtHF7do7G9iw5jegztd7HOVskg7DDyubMEYqK9o5
         nVgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PEK1VY+3;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j2si7727545iog.116.2019.07.11.07.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PEK1VY+3;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO8vO001464;
	Thu, 11 Jul 2019 14:26:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=2d2Yv2y5zLW9fLZ4ZOO2tadSx6yS9UU2pD1uUkqP2I4=;
 b=PEK1VY+3UVMeYt+RB002bYINLbdCxWtdVaXXuLcUErNmdDVQeXpj0b9OMDpmCIqqZa4Y
 9PvB0Lnb9b0uhxGmrMFXcR44+qa8LQlt1HNPX0Dv/WgAESNOrwyxaWcdUWdyw5aYvMo9
 6hMEg+A/C1vRmGh2CVcZaeUmibNGRM+Z0ynXpbec7GOZxoWF9wbcV+Bk5OzwKInmLI0/
 2E7YCwLLpvnIvEy49dwDdr51/iqNr/GOk+NSxBuovD4OQOPclLfLK8Qy+EAEEUquuZ8L
 HADMT7wC0JoiunyhO1kAnDjpVZAnFUxpCSF1OfqJMoGYFOwX+PMYYSzDX1GbCZ5/xKmc PQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e24-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:48 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuC021444;
	Thu, 11 Jul 2019 14:26:44 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 19/26] mm/asi: Add option to map RCU data
Date: Thu, 11 Jul 2019 16:25:31 +0200
Message-Id: <1562855138-19507-20-git-send-email-alexandre.chartre@oracle.com>
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

Add an option to map RCU data when creating an ASI. This will map
the percpu rcu_data (which is not exported by the kernel), and
allow ASI to use RCU without faulting.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h |    1 +
 arch/x86/mm/asi.c          |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index a277e43..8199618 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -18,6 +18,7 @@
 #define ASI_MAP_STACK_CANARY	0x01	/* map stack canary */
 #define ASI_MAP_CPU_PTR		0x02	/* for get_cpu_var()/this_cpu_ptr() */
 #define ASI_MAP_CURRENT_TASK	0x04	/* map the current task */
+#define ASI_MAP_RCU_DATA	0x08	/* map rcu data */
 
 enum page_table_level {
 	PGT_LEVEL_PTE,
diff --git a/arch/x86/mm/asi.c b/arch/x86/mm/asi.c
index acd1135..20c23dc 100644
--- a/arch/x86/mm/asi.c
+++ b/arch/x86/mm/asi.c
@@ -7,6 +7,7 @@
 
 #include <linux/export.h>
 #include <linux/gfp.h>
+#include <linux/irq_work.h>
 #include <linux/mm.h>
 #include <linux/printk.h>
 #include <linux/sched/debug.h>
@@ -16,6 +17,8 @@
 #include <asm/bug.h>
 #include <asm/mmu_context.h>
 
+#include "../../../kernel/rcu/tree.h"
+
 /* ASI sessions, one per cpu */
 DEFINE_PER_CPU_PAGE_ALIGNED(struct asi_session, cpu_asi_session);
 
@@ -29,6 +32,7 @@ struct asi_map_option asi_map_percpu_options[] = {
 	{ ASI_MAP_STACK_CANARY, &fixed_percpu_data, sizeof(fixed_percpu_data) },
 	{ ASI_MAP_CPU_PTR, &this_cpu_off, sizeof(this_cpu_off) },
 	{ ASI_MAP_CURRENT_TASK, &current_task, sizeof(current_task) },
+	{ ASI_MAP_RCU_DATA, &rcu_data, sizeof(rcu_data) },
 };
 
 static void asi_log_fault(struct asi *asi, struct pt_regs *regs,
-- 
1.7.1

