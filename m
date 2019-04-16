Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29571C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D902B222BB
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D902B222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1F7E6B028C; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACF166B028D; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BDD06B028F; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A96B6B028D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w27so10987473edb.13
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=b+MVdc1f/Z29Fjq9C3qXW5Prfsae3+JEITZmBn3UMyY=;
        b=lxtrwsGivizGbof3vYVYvoWQy+6r5chFvx3IfT8+yspazl8yyLeswYwBhJ8MgCrCJk
         tXUJSGO21bJ3Vg7ta45QqFsJeMO6jk5kjgsP8hSP1COasILPWorAS9HaKvaLgnhxu+BZ
         i0s9x1nYTaQDjTFJnIRd1T98TcOORUpiHk0tr4E96WdcbP2jF20vvn4XODGxDxEQgfrZ
         KwEfrhuIncKhkSYTlqwkdKvqg2pAuCNdRPbjR4AFx7iBSGjjysxb32/gfUI/bwACwsLJ
         iEoe9sqKNxNCJrjNKLR4mP+Bm0eXMLuW4Tn1JkpKbZtJutz7yqYXRdE+L6JZbyMTH6EM
         easQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW/5wfOAumurDAb22tSfaocEEnAJpIwrsKjhP2eKDep8JzhL6Qi
	1ncna9aPh0R5YR981c4L2tAAgOX5VuwepPmCrnVnoFhKlPeEpqxsHQmFhH9YtVWpths5pQ/4pCc
	68QDoeKW+V/5kCIDqcbS7Kwjs/j6e/DI2ST2sCZLHKbKTf3+re+euNGdL7DAm6yk08Q==
X-Received: by 2002:aa7:c750:: with SMTP id c16mr5722333eds.106.1555422448810;
        Tue, 16 Apr 2019 06:47:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQqL+FdnvJRQGrO4sIc6z+rZnt+rffvxR9VR85ij0Gi2VUe1ScbgNhhOfmTzFSLmVOHmZn
X-Received: by 2002:aa7:c750:: with SMTP id c16mr5722277eds.106.1555422447736;
        Tue, 16 Apr 2019 06:47:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422447; cv=none;
        d=google.com; s=arc-20160816;
        b=RJb8Lyln6vQSPFFoc3acZnhgTVZfrYD6pqE1mLmqeIcW9GJmtv/UH8FCIumSf8QnUl
         K9X2UW1sv+A7XlOI7gAC5xexYZntO8i14x4z3MsZplfEoomNWNV3Z6FJtll3eXI9Q5a/
         KkPAZNcArZvk0bRSAmOZXKjK/XosWQjwnf5cLLYOPedoN2GuJd8HY6kRV4kfByD+jdAF
         x/qUQkAfvKBuCm8zuq0ZwYen91P1ucXQZnASMAaXBdITI27hk0aRjqa519sKryCxrl4G
         z2/BLq/+8EBuaXbRaTIZqNmPbeDEA7xH/Htd7G6ioMOsNFTACqv61ONjfFLrz78hL+Ed
         2dHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=b+MVdc1f/Z29Fjq9C3qXW5Prfsae3+JEITZmBn3UMyY=;
        b=hnyaGZnzSguCzLG5KMPAp0SS+H5/g5CBSX+QCWMg4+ubd7J5uD6/0k4Wh9bdtN/hcA
         XZ2SLYoskg3k/pL8ZuXCGaw3GU8qP8hsqatGqoeosV2Z9Z8xsNIXdR5TF32dhj1KCYLr
         t61IqcErQ6zdHT6mH5fHDnclRuNWDtqe/Y7NkxrwRvn1FrEmm9MQDe3J6CbW3FFrlUaT
         kCXwYKDxsx3oBROqoh6jTK+Wxx8LoSAaxcvNd4Oqq7DWvRS6xuGWkWPz3LvtP4qzsj0l
         JBbxFej7YnbrCSisc4YOjBbUFUXnXuXIHQSyTkXBH2tqS6oBoiAP2X8PKY3E3uSQOjjY
         lw5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k33si3352280edb.13.2019.04.16.06.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlHw7010813
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:26 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe56nwxt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:15 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:41 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:32 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjUpB46924002
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:31 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D80A44C044;
	Tue, 16 Apr 2019 13:45:30 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 693384C052;
	Tue, 16 Apr 2019 13:45:29 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:29 +0000 (GMT)
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
Subject: [PATCH v12 02/31] x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Date: Tue, 16 Apr 2019 15:44:53 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0012-0000-0000-0000030F6EEF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0013-0000-0000-00002147A84B
Message-Id: <20190416134522.17540-3-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=877 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT which turns on the
Speculative Page Fault handler when building for 64bit.

Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/x86/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0f2ab09da060..8bd575184d0b 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -30,6 +30,7 @@ config X86_64
 	select SWIOTLB
 	select X86_DEV_DMA_OPS
 	select ARCH_HAS_SYSCALL_WRAPPER
+	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
 
 #
 # Arch settings
-- 
2.21.0

