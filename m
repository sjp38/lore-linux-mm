Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F360FC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B076321B26
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B076321B26
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF33F6B026A; Tue, 16 Apr 2019 09:46:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA72C6B026B; Tue, 16 Apr 2019 09:46:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6E416B026C; Tue, 16 Apr 2019 09:46:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9351F6B026A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:56 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id h125so15749529ybh.4
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=X8WMS1D0bTB8Pmp4y6yQGdPb3gyYC2VmqSmN2VwFJ50=;
        b=e2V7eTuDZJqTnjwnqgIeGLqz6RQEi4wgb+yzV5PJ1LwVNYfe6IvSC9G6RfKByftVuC
         sVUR0Q1WcVAOpUePTnOQAvBe7Mx62brTG4B3pPj67owjD/yRFtgR5+I0YSv48Q4Lz21w
         D1ey9zLEoVz+Wgh2foqvaI+vlGZvPWj1XRtTHfjs/FDEZyo4N9nq6wwUYb0Tx8ggiThr
         5rKk09fOGseca+32xcJTrcKdrfIn3hjElQEOU2xolY4JK/Rgnk42/ECiY/SC3adK06nE
         Aeruc5Srw4rjdS5unoKLz9hgGnglybN3vl4/t94B/QY7bZS1jS89NeVq2tN+kUzonGf+
         GFFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW4Td2hFjY7oAdWXLDyLh8xlmYuYFfHpCPhLy8/oxwxogJmuXd9
	obZ8yfv6MEBK370s0fRMS1XojpPjY6ha1F+apQYDwCFXyF3+Gb7WK/5Afy3urpxfvPlWNdq78DZ
	fOM0XV290uaSx2VllYu3sGq/QH/FPjBjT1mhzX1HLBecHvqTsxOUIvXwY/ynmD+J4iw==
X-Received: by 2002:a0d:dbd7:: with SMTP id d206mr61785324ywe.332.1555422416303;
        Tue, 16 Apr 2019 06:46:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHG6dFy9KzmMVMdsW34HoFrAi/rVh8fUcOATYZwttj2D/mgcU9tq2kPeNptejXEJtTku02
X-Received: by 2002:a0d:dbd7:: with SMTP id d206mr61785217ywe.332.1555422415085;
        Tue, 16 Apr 2019 06:46:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422415; cv=none;
        d=google.com; s=arc-20160816;
        b=RNSjwCIA8AFriLWYwQNOkpqJAH7F86HbyrZt2sqNC6zNQTqzrSxXy6tvFTiJTdQae4
         E+irn3+uYv5/WPD7jSW7Lpgf6odFQqAh3oxwg5Kn1fdefo4iTAcA664+04Q1uBJUaxqY
         HfU4Axrfk1+Mpe1PKjByXKlu/x7ABdQD0T82jSDAA9RUgPSLud3j7RKy3Emvp7JAVuNY
         r/XytJIM2wMi7b9fxDiYlMdWOriRwqydA7gZgBec2fQ3tizeSfFuhU6Vc/e95gd7ZCCb
         pp0BsG0ZHSLBFCfeap1HVmp3eXxqx3lhaLlYiP1JpZ1JqOQnTnrTvDiDGT6rC90xAyv2
         uO5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=X8WMS1D0bTB8Pmp4y6yQGdPb3gyYC2VmqSmN2VwFJ50=;
        b=Rl/wmdF6ftBcbJ8xLbAvSnm/An+lLWBlNuWZKJHJHuC9UfaRicCIT7gzDItw7BCpI2
         lJ6NNcVQqi+AHEqCBYRZbBIi7XQlK5O2yzcCstPHTo2kfavhLnqApOJN9vwPfuM3vZiq
         lylj/iJLNWJvfyf1nqKQvxug9V+8ZHV9YZdbGkwxRBj6i3OszIGiy47j3raaY1U80JYN
         T8PnyM4PNysWk5zkW1q9NcEgx+oWPe38+Z3krzoobV9Z/e9cJUGuT8ofNGB7dJVR5xaD
         /EOZB8EWmVOUZrx+zLQspix5UvWUcYNf7kqKzYPB8VQ+LsQ9NHYNIKCPD2qrMufgGZsf
         CO9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e128si20158833ybe.171.2019.04.16.06.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkSZl132311
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:54 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwdd2qv5h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:42 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:46 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:36 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjYou50724972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:34 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 445334C05A;
	Tue, 16 Apr 2019 13:45:34 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E6D874C058;
	Tue, 16 Apr 2019 13:45:31 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:31 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com,
        npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
Subject: [PATCH v12 03/31] powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Date: Tue, 16 Apr 2019 15:44:54 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0028-0000-0000-0000036170BA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0029-0000-0000-00002420A853
Message-Id: <20190416134522.17540-4-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=983 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for BOOK3S_64. This enables
the Speculative Page Fault handler.

Support is only provide for BOOK3S_64 currently because:
- require CONFIG_PPC_STD_MMU because checks done in
  set_access_flags_filter()
- require BOOK3S because we can't support for book3e_hugetlb_preload()
  called by update_mmu_cache()

Cc: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/powerpc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2d0be82c3061..a29887ea5383 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -238,6 +238,7 @@ config PPC
 	select PCI_SYSCALL			if PCI
 	select RTC_LIB
 	select SPARSE_IRQ
+	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if PPC_BOOK3S_64
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
 	select VIRT_TO_BUS			if !PPC64
-- 
2.21.0

