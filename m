Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2616CC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B566921924
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B566921924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 331546B0007; Tue, 16 Apr 2019 09:46:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E10D6B0008; Tue, 16 Apr 2019 09:46:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CED66B000A; Tue, 16 Apr 2019 09:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2E616B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e22so9341060edd.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=EOJUH5UxCRZTR6sReLNjhW1Ydu3e6MQFNMVn2SqWD7M=;
        b=mpInnqEXsjHZWofj9FDh2ihKL0/qLtWaYykhr1PVioVT9lUDWAfcy8C2XJq6R6JWYu
         s+kpQ+MMvQrGUqMx+ceDTs/dXGSVA3LsmgGraRFCg/CUKgBZrSEptBwOgy16mdCOPg8J
         p1jdr9Zt+pU/sohDuMWAVu9psvOCkWGQ2mo3QZIXPFzwojC7Tl9cebdbDy/prgBr9tZf
         rwI1S7Rc9n89G21J2Yo/yd4LgRTscEKH0Srof3xMxjmjoVnwiuhh2ApUJDSpVUZ70tFu
         clgyzgsOmlIZxhhXUZQuMxHjFDmRgFgIhEV1i6wzop4/wW51dyfWTQd2NvQoWW/57pP1
         6VwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXCRZpAQxwreExtQZAP4ZkDQmAgfvF3ULpdvPyzeypAMsVCGdax
	7KayPo/ybY/jHadu+ANrlOEwfDkptJRcX5eDFoicio//niL4WEFNULrx0CPONF9qqzR2OFxjzRX
	pn3Er13dF3OkFwDeuEB6lPpBtmr3b3yk2NNR7eK1b8hg2ptghAURow8joztoXqZapiw==
X-Received: by 2002:a05:6402:1557:: with SMTP id p23mr10693765edx.27.1555422392151;
        Tue, 16 Apr 2019 06:46:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVfbviiGvj6JiBEGjkbFATy88UmtU9v6LaWDVnfWUHhVETFAhX9l+VqLYmB1SLB6OgfT5D
X-Received: by 2002:a05:6402:1557:: with SMTP id p23mr10693693edx.27.1555422390982;
        Tue, 16 Apr 2019 06:46:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422390; cv=none;
        d=google.com; s=arc-20160816;
        b=mJ6vGEY3OlnEgtAOjwFnGF249viCVYYMJiZefhfv98JWHqbWAqeRCOnbv+pfJHTBOT
         AtchbJnkRQiQ7FRiw5vmZQQu+nSt5SKnS+AbWbWxAZ7YAoCOJBwkr9fMMl8ClNHJeL9h
         +cMKfHT/uuaWYT8G72isBo3UBkRd2irNPvo5xoeVHs9imlHfp/lNvleVGZHPENYpxKHX
         R2I+bvmEaMXg3HdrzOeixVHyPqwgddV/Bq4Y7PjB0CD6ltDM4WGAiCu7Rl2i6iksr+BK
         HaApkyXuVR0iEKS7rRyttGkd1/kdt0mCfetFKDm7eiWOFEr1vf+Jvirlyk63rnt0Zyf7
         Ce1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=EOJUH5UxCRZTR6sReLNjhW1Ydu3e6MQFNMVn2SqWD7M=;
        b=IgJSSNPZI/nl/RVOFdu054DEyQkoqLV6Nr7F6KB0+AArP0PW6tLFBF6GkJmnMwVIbl
         rhh9evgXjdx/NUsdKrIHcLbBhq/rG1MLsGFyVl+NbYeW2MYfegQFEMQ3/vD3YX2BSfQ0
         WVCqtV/KvPJT/Ks81wMBjuxInCbdc8e6vAr+p/VwevIEWrgebNxa9hEO9s6ctC9KTsWi
         oHibOfbE0Sl/2RXMtScxp9XnmitCYpysp8Km/suaC7N1wDaVFY2BC37UvEh3NAkZwyUF
         RHwRDcJIeOJUySlivhnu6gmIlsU1GT3ktyOlDEuy/xIvidKPomgJtJC+67L85NRCAS3h
         CZvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d9si10677102edq.270.2019.04.16.06.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkHts129524
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:28 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe6cnnkx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:26 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:48 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:38 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjaDU61276172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:36 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C18A04C052;
	Tue, 16 Apr 2019 13:45:36 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 56A644C040;
	Tue, 16 Apr 2019 13:45:35 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:35 +0000 (GMT)
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
Subject: [PATCH v12 04/31] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Date: Tue, 16 Apr 2019 15:44:55 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0008-0000-0000-000002DA6FAB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0009-0000-0000-00002246A833
Message-Id: <20190416134522.17540-5-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=972 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mahendran Ganesh <opensource.ganesh@gmail.com>

Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
enables Speculative Page Fault handler.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 870ef86a64ed..8e86934d598b 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -174,6 +174,7 @@ config ARM64
 	select SWIOTLB
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
+	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
-- 
2.21.0

