Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8CA1C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4726C222D9
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4726C222D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF9C36B026B; Tue, 16 Apr 2019 09:46:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA99F6B026C; Tue, 16 Apr 2019 09:46:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1FB66B026D; Tue, 16 Apr 2019 09:46:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 647EA6B026B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so10671535edo.23
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=c4uoK04ICGZxbErKax+QXjYd+oc6OVnKOXPlRP5m6go=;
        b=bMAA0aIMqjS+5lCf+RqOpeVpYQroaOajG1SvIa8yBJjoegZmSnDLgueYt631/oUEN+
         uuoy5K745vGHhxC/ynA4MbXBlC/4bQnqJt7Ec89kBvJ+iNYRvd1pGbCBIIH2jWGhKTKX
         VVMPezAgIOhe7eWhL4ac70OH4SY3H6y1mq/OTMCT6bXujuaXN9U0b37jQ3H2xwAn5tx2
         VvOzHRcyp8WDq8Yp7VBHAStGcco9oglaF8EjyXfszzUezegdUy7iCDU7vxd2D0sw6O3s
         EAxbDK3maw6g+vyuWFbHXiQ39fDefY72WcyWf5pGg379mAiASrBfTjwrIDRFOi+olbl5
         T3gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW2jX1uWCfUxMRRnuc/LWTBVraDl+XRxPhFkGaIP/s4VYyGT+mf
	ESGYPCwBtJh/2LxcwVj9h7e/aI9TrAAtER+xca0Q+J2ZImDsnZEsVqx1YHKY2kQ2oTpFeOUMA8H
	I7wu5n4i9Z1MFcz7QuuXsv9QlNs14DnAmDvwfYS4ay8YBzunCSxX823HvEabtm3Xa8A==
X-Received: by 2002:a50:8719:: with SMTP id i25mr1986226edb.172.1555422416904;
        Tue, 16 Apr 2019 06:46:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwr9/5umfSZkZmRrMBbtqsVtQVZG84W9UeuBg2p2Si5DHqz+Qh3fnIx/Y7Ig8WjvL6sMpWP
X-Received: by 2002:a50:8719:: with SMTP id i25mr1985935edb.172.1555422412151;
        Tue, 16 Apr 2019 06:46:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422412; cv=none;
        d=google.com; s=arc-20160816;
        b=krLMIOqP6skgp20/2/78P5pRdoO1aM+G5B66PqRHnTh5GdUmtz4A4UZNvYhlfAcEd/
         Oc4whdUGb7ov/5SwtDY/SLFWeEdWwKM+kksmWN+q2e+KowZEQaQzVXVXsCkVjkca8MWz
         5vrFeJlfpgy8WX2Xovwx9hpiZay4qV9kB40Z0Ios+07H/BEQ/UHVCaOdIjSd6YvnnyQY
         CdmFBHlWBs5z3OdjpP4RkiOk2IWkwOhQaJ4rMFh4EKZwMgwxWPqTmQy+YvLGV+9Gmkzo
         rCj6Uuep/shPrrOHchZamFYDMSU56d3t4WzOxsHhsE2kO2JaA/YE9wm4RxpjX/LdnxHf
         MEDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=c4uoK04ICGZxbErKax+QXjYd+oc6OVnKOXPlRP5m6go=;
        b=PE0aT3rNZzEHMwUANHzL0w7f5er+IwjWzB3FsOSsKAlpecOJPfCRQ2oMfaN+ECAIup
         uaaWQva/cGoBgGFEv+3dezUfk6Icch+O4LEM2zkRcoYHGmIsc7DE4UgR/VjjlgwkP20w
         BQhCOyTyfE/m/lYI9aGBu+79auWtLw37HSG5BLw6AyuwKWsedqf2gwJTF6PRp7mnikJG
         otaEyVrL51pmWiCO5/PHmDM57UdYUsyeO1aWZjrLF86nCDyQXqTkH2pDHNxJZsjs75ji
         L1iEMX4tjNIkxRr+eueg1UB/8NJcV4P3PPGzrxA2T8zijLcjP1aIxV5qtmS8J2ro+A1q
         MjIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j9si996811ejn.10.2019.04.16.06.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkcPa175912
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:50 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwfbatrua-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:44 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:39 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:29 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjSvi36962434
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:28 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5A08D4C044;
	Tue, 16 Apr 2019 13:45:28 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4AD3D4C058;
	Tue, 16 Apr 2019 13:45:26 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:26 +0000 (GMT)
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
Subject: [PATCH v12 01/31] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
Date: Tue, 16 Apr 2019 15:44:52 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0008-0000-0000-000002DA6FA8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0009-0000-0000-00002246A82F
Message-Id: <20190416134522.17540-2-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This configuration variable will be used to build the code needed to
handle speculative page fault.

By default it is turned off, and activated depending on architecture
support, ARCH_HAS_PTE_SPECIAL, SMP and MMU.

The architecture support is needed since the speculative page fault handler
is called from the architecture's page faulting code, and some code has to
be added there to handle the speculative handler.

The dependency on ARCH_HAS_PTE_SPECIAL is required because vm_normal_page()
does processing that is not compatible with the speculative handling in the
case ARCH_HAS_PTE_SPECIAL is not set.

Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/Kconfig | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 0eada3f818fa..ff278ac9978a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -761,4 +761,26 @@ config GUP_BENCHMARK
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
+config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
+       def_bool n
+
+config SPECULATIVE_PAGE_FAULT
+	bool "Speculative page faults"
+	default y
+	depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
+	depends on ARCH_HAS_PTE_SPECIAL && MMU && SMP
+	help
+	  Try to handle user space page faults without holding the mmap_sem.
+
+	  This should allow better concurrency for massively threaded processes
+	  since the page fault handler will not wait for other thread's memory
+	  layout change to be done, assuming that this change is done in
+	  another part of the process's memory space. This type of page fault
+	  is named speculative page fault.
+
+	  If the speculative page fault fails because a concurrent modification
+	  is detected or because underlying PMD or PTE tables are not yet
+	  allocated, the speculative page fault fails and a classic page fault
+	  is then tried.
+
 endmenu
-- 
2.21.0

