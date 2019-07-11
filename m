Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B63BEC74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BF9B2166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lniqBkC9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BF9B2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BE448E00D7; Thu, 11 Jul 2019 10:27:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FA8F8E00C4; Thu, 11 Jul 2019 10:27:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEE888E00D7; Thu, 11 Jul 2019 10:27:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id B688A8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:01 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k21so6990681ioj.3
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=9FGKxWOaR9lg8qKZvVxZYyBDHDZO4/U+GnNunz7EXSk=;
        b=lJoduAUbnMO/Y+o34z8MD/uFj6b4dikhGeNBTud29bhGHwS0YjxdRSw6w2Khf/srMU
         LIprHJquOQDhowcRC6li4io5ODtv5bhsG8fV1kckwjsKAqFeN66MEvUqd+pogiEiafqa
         9Dz7UCh8d1LoLoCbiTYqySk0Geyng4d5NemTwZ2i2oOYalH2/ohsqc/IGA9E10KKiIJ9
         eh+MpIGDa749bMnc3zsHjI83voAWSvgk8seTgxCZPO9HBJmn2+u5RlBmQfKV23BzpXPe
         TzSyn31mFGtEfyk2nfhplQepdlGh58uq8Qj0U5O71631+pO18ZLIuqbkkHqHXHDcx/3v
         s3Jw==
X-Gm-Message-State: APjAAAVHWsgYI39TmDME4wEq/1wJfg1Tl7dlirgBnUtGRCF/vwWFlwAo
	Tw4xj/aVXNvybcyHOhemyYDUzmqEaYEopgnEI1e+dyyUsurE+VunX0Zkvl29Rp4KLwpmYKBdjBQ
	m29dUKyQDVPBnlw/M0WsAZkC2HIitC0oXjMR1WvBLpud8NWHWy5VjWAtM8GwSAn1Etg==
X-Received: by 2002:a5d:87da:: with SMTP id q26mr4633698ios.193.1562855221551;
        Thu, 11 Jul 2019 07:27:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3vEubOZkD1MppYky2ndwi18FrQTB6UN1p5v/Wm/e8H7HSOXfnTZkTPI35qPRfQjVNZB9U
X-Received: by 2002:a5d:87da:: with SMTP id q26mr4633624ios.193.1562855220681;
        Thu, 11 Jul 2019 07:27:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855220; cv=none;
        d=google.com; s=arc-20160816;
        b=Sk00lhrtIgRxgRFZhQxCzIl44RloMcRvXUX2mNjBpC6tG5Ys24rc86sAR8N7h//P1L
         L0cLkiVbrQbNzO4WYxzmXmvmO+BskSJSS3VBKjZkd/XVuOQJB1hRwfb1iuTk7WITQS2r
         YIDRKK4+zIfHnhvHvifv4eFXwXXrOs7/2YGoRw7Pevrm7JKO9H+DJQ0LYOOFUyx5YVWV
         Bb4CgnC82jYROOMoOQl+n6h/6GRHSv6jqTXu/MI+Sh6I7pd4pmdc7uy/wjXzHs6CtvQW
         N+Lc96D2813WzMBrnR1C6kEXXmlYxFmb8Hb3NaznOrwwMFVifcJo4kgtOWVgcUgoCDLo
         tbaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=9FGKxWOaR9lg8qKZvVxZYyBDHDZO4/U+GnNunz7EXSk=;
        b=ZPjdSoZ9c4fVFhiN+KP5FW9VKEo1zys2pV3+djQ2IAFASHPXfKTv9TPLJ24yQ8iWU/
         6Q7ZQ+nLmyYCAfDgZCr0AoFIL1vlhCYAuMgbrctv8Ca2MS1XAcUeav56Zx+J4Bimsms/
         j/QAZrEn+X+/Mi7GAfx5674wVTEIouCWZ1a073QBKlYDFbf2pOXgNmraOnMUbAVxiSWo
         OBD1tw8mBGko3Wua/wSyG72ugNy/dMicqh9IFxVL3+srU9zMI+z/wHSFcqddHMIVA2vg
         rVEit7y8SIOsJ/vfJzp1ChxOwlGOPEKcqjPg7yRtwil1xOxb5kzTkV7lVSGrXYabUOtC
         dr3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lniqBkC9;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a16si8273870ioo.7.2019.07.11.07.27.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:27:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lniqBkC9;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOMdI013631;
	Thu, 11 Jul 2019 14:26:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=9FGKxWOaR9lg8qKZvVxZYyBDHDZO4/U+GnNunz7EXSk=;
 b=lniqBkC9yuqD/Ju9/6Xyu42PxGGU6Yt/2fjCL1pA8uTadjROIw7CBcc8faiSFRo7Bv3q
 BPubFEelFsfRjyPHH37WhqoIXQX5UbWj/nD4TDzwZBHQoeubLcnl1AB5vQ/mCucdF+Yu
 6nQIlGjLClEFr6VXl3jVjtuCT9T1LE8cucXjWWInMM2yXZ80VjgZXh9Wagaq6vop/Niu
 wJjXwR5Jbi7oMNqUbY65Is6pPs++Vxlbu62PVImCdj3jQ/wjgIZg0r9DuCe22wMVOgbF
 ph3T8g1h5qYYjiZctfTIEHMk2DM78dBxXxMV6ZGQQw9l9nE44jpFZXce/yhCQnDc6q9c 6g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2tjm9r0bsr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:51 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuD021444;
	Thu, 11 Jul 2019 14:26:47 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 20/26] mm/asi: Add option to map cpu_hw_events
Date: Thu, 11 Jul 2019 16:25:32 +0200
Message-Id: <1562855138-19507-21-git-send-email-alexandre.chartre@oracle.com>
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

Add option to map cpu_hw_events in ASI pagetable. Also restructure
to select ptions for percpu optional mapping.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h |    1 +
 arch/x86/mm/asi.c          |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index 8199618..f489551 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -19,6 +19,7 @@
 #define ASI_MAP_CPU_PTR		0x02	/* for get_cpu_var()/this_cpu_ptr() */
 #define ASI_MAP_CURRENT_TASK	0x04	/* map the current task */
 #define ASI_MAP_RCU_DATA	0x08	/* map rcu data */
+#define ASI_MAP_CPU_HW_EVENTS	0x10	/* map cpu hw events */
 
 enum page_table_level {
 	PGT_LEVEL_PTE,
diff --git a/arch/x86/mm/asi.c b/arch/x86/mm/asi.c
index 20c23dc..d488704 100644
--- a/arch/x86/mm/asi.c
+++ b/arch/x86/mm/asi.c
@@ -8,6 +8,7 @@
 #include <linux/export.h>
 #include <linux/gfp.h>
 #include <linux/irq_work.h>
+#include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/printk.h>
 #include <linux/sched/debug.h>
@@ -17,6 +18,7 @@
 #include <asm/bug.h>
 #include <asm/mmu_context.h>
 
+#include "../events/perf_event.h"
 #include "../../../kernel/rcu/tree.h"
 
 /* ASI sessions, one per cpu */
@@ -33,6 +35,7 @@ struct asi_map_option asi_map_percpu_options[] = {
 	{ ASI_MAP_CPU_PTR, &this_cpu_off, sizeof(this_cpu_off) },
 	{ ASI_MAP_CURRENT_TASK, &current_task, sizeof(current_task) },
 	{ ASI_MAP_RCU_DATA, &rcu_data, sizeof(rcu_data) },
+	{ ASI_MAP_CPU_HW_EVENTS, &cpu_hw_events, sizeof(cpu_hw_events) },
 };
 
 static void asi_log_fault(struct asi *asi, struct pt_regs *regs,
-- 
1.7.1

