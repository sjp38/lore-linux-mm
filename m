Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFD22C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 780FF21019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uIvYew5i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 780FF21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84ECC8E00CF; Thu, 11 Jul 2019 10:26:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 786D08E00C4; Thu, 11 Jul 2019 10:26:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6271F8E00CF; Thu, 11 Jul 2019 10:26:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33DE28E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:36 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n8so6924565ioo.21
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=gDByh8p+inBGj8eNOkt+0s0ErRCor6nCeXzUp1uJmZ0=;
        b=C+MGP3jzaNCZ1pNDycejCLKD3HU1TOhXffj8MLl+lZy1rorZsqxtkplQ8w7p9HhMd1
         f/8eaKACUKNcAnglJc79t06SNCq2lblu42+QXVMUgwmfk019VJzIYklJDYzBuODqTKtS
         z0+tHOvLKRlpuWaT5Ty3I9uiFYu153VXP/unHt2NbuCnevvT/EiEwR29BXjJSJFC0aq1
         VWznPJM86JiyV9QGz58UcGcLymaPfjDR8CTkxhQmuxdOp9U50mdj059wMphEMOt+vZo6
         7ECrjkHUPd+TGFhSw2nkP4zIvwjJkX8looqBUcGRVZnn0Rfm4I7FOCeuhHe7n6q73Rip
         nFKg==
X-Gm-Message-State: APjAAAVidJtDwKJRww0vW+hfHeRbN9OrfHCKfQkfrfLWGUjYDBn4eLk2
	zxUe760iLM3+zicovee/frlNiFDI8IGIbg32Jpmb0Ydb+wg13KbnRssy3WJDqzQh7tvB3ImfnkG
	evoykqpsyuAXTExRC6eEkKn9Hk0vYA+JqEO//0oIkmtn38RMTGv2rskuXvvrejgpsBg==
X-Received: by 2002:a5d:928a:: with SMTP id s10mr4647146iom.29.1562855195982;
        Thu, 11 Jul 2019 07:26:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMydXJcs8IqO9pyZAMFPj+cK/87CVIe08oz4/ZRLY+2J06ORNfy12w3qhxvRMkP5rtZqsh
X-Received: by 2002:a5d:928a:: with SMTP id s10mr4647092iom.29.1562855195425;
        Thu, 11 Jul 2019 07:26:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855195; cv=none;
        d=google.com; s=arc-20160816;
        b=PbJUbd6V8ubdHJQ00C8M0RATV8ZH9sax5GYgoZmKKGuQzYxiStoZGbLPV+1/yMxSg4
         wJDqVBErOheXuORnyNqNuB0elbQ1folGAHTbJiohktLBZUpHCfTVoKOhObhUqFbudRE3
         iJFFLlq5eMoucIvA1jEyFogO2hwwvf+bMWsc/ULT2vrqVt4SDd023Fpg5QVPc8JHJM35
         BxQkjfMYgk2PsBjZsY97pps8K3liykStfyC8/JNcZ7XSg2X3umh5c2NPpUVro+Vd5UFu
         S4UuvqFp6WKU6Yk3Vn6V8gK5NkUx6pvqbp+wGej+3JshzfrGZdk87y9E1XbSrQUiqx2X
         SLxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=gDByh8p+inBGj8eNOkt+0s0ErRCor6nCeXzUp1uJmZ0=;
        b=v+hDurvBXM0HiP0/ZJ1VCCrl8fnHMEFogQbIJeEzottcYdK3wf8T1ME3sTE8hIiIuP
         0iL0Hwc4QQp/wFgvZekxAZ0D6txPPCJWZH/Q3t2vl4nAi2dnk2/iTRnu8sogYms7ndaf
         5VjyhsuL0fGhCmI7kNGSJT//vGzJsq6zQ62zGP0lD1qaduHJZ+A0D443JaIkEnT0UQ0U
         xMBCoKo8uieCkWncZR6XzrTfxThqsXhfoJhj06qQsgIGM3/ue75IV+FLPrmWRxqAd3dH
         KLbCVmit4hk/cLe4GmtlJp+QK/klDjLPZBnf+YIL/GEJbcK32FCbRzSpMM/wNFa3d6fj
         9vnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uIvYew5i;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l10si7686574ion.114.2019.07.11.07.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uIvYew5i;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOKHZ001595;
	Thu, 11 Jul 2019 14:26:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=gDByh8p+inBGj8eNOkt+0s0ErRCor6nCeXzUp1uJmZ0=;
 b=uIvYew5i+/N3gKnyr4ociYqq+qt56BKvpfHx2yG6ELbiXTDFF1FnRFdNiTxKLqzKpugT
 7rZFZ27tp3XeOzJIDBEQWKZlGMdD04zWtCMR9kz9rtKT/I1eEKjmUoR0EfXOS4LZP41X
 SaOmMD0h5rmiZKjuWODlCFnTwFv/w3OU84qMp7I8vBQjvkB4kLSw+vU/HUfR9FiS4qmM
 dt9lswqhmPEYZvrjigJDb4qNQfKlbGFfmUQluSi/uyNCjdt/jH+m3QqAeoRgbBE5SECi
 sbhB6HhXJDdRZ5C1Vh+uI9HzCIOa4DMf+C+kQvxHt3TG4Fqj9spPHDE/SpvfNokpoD2Z Tw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0dyd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:25 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu5021444;
	Thu, 11 Jul 2019 14:26:21 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 12/26] mm/asi: Function to copy page-table entries for percpu buffer
Date: Thu, 11 Jul 2019 16:25:24 +0200
Message-Id: <1562855138-19507-13-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=895 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide functions to copy page-table entries from the kernel page-table
to an ASI page-table for a percpu buffer. A percpu buffer have a different
VA range for each cpu and all them have to be copied.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    6 ++++++
 arch/x86/mm/asi_pagetable.c |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index 919129f..912b6a7 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -105,6 +105,12 @@ static inline int asi_map_module(struct asi *asi, char *module_name)
 	return asi_map(asi, module->core_layout.base, module->core_layout.size);
 }
 
+#define	ASI_MAP_CPUVAR(asi, cpuvar)	\
+	asi_map_percpu(asi, &cpuvar, sizeof(cpuvar))
+
+extern int asi_map_percpu(struct asi *asi, void *percpu_ptr, size_t size);
+extern void asi_unmap_percpu(struct asi *asi, void *percpu_ptr);
+
 /*
  * Function to exit the current isolation. This is used to abort isolation
  * when a task using isolation is scheduled out.
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index 7aee236..a4fe867 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -804,3 +804,41 @@ void asi_unmap(struct asi *asi, void *ptr)
 	spin_unlock_irqrestore(&asi->lock, flags);
 }
 EXPORT_SYMBOL(asi_unmap);
+
+void asi_unmap_percpu(struct asi *asi, void *percpu_ptr)
+{
+	void *ptr;
+	int cpu;
+
+	pr_debug("ASI %p: UNMAP PERCPU %px\n", asi, percpu_ptr);
+	for_each_possible_cpu(cpu) {
+		ptr = per_cpu_ptr(percpu_ptr, cpu);
+		pr_debug("ASI %p: UNMAP PERCPU%d %px\n", asi, cpu, ptr);
+		asi_unmap(asi, ptr);
+	}
+}
+EXPORT_SYMBOL(asi_unmap_percpu);
+
+int asi_map_percpu(struct asi *asi, void *percpu_ptr, size_t size)
+{
+	int cpu, err;
+	void *ptr;
+
+	pr_debug("ASI %p: MAP PERCPU %px\n", asi, percpu_ptr);
+	for_each_possible_cpu(cpu) {
+		ptr = per_cpu_ptr(percpu_ptr, cpu);
+		pr_debug("ASI %p: MAP PERCPU%d %px\n", asi, cpu, ptr);
+		err = asi_map(asi, ptr, size);
+		if (err) {
+			/*
+			 * Need to unmap any percpu mapping which has
+			 * succeeded before the failure.
+			 */
+			asi_unmap_percpu(asi, percpu_ptr);
+			return err;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(asi_map_percpu);
-- 
1.7.1

