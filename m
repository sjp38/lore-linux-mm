Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45430C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F03B820C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F03B820C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9570F6B0269; Fri,  9 Aug 2019 04:41:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E0B36B026B; Fri,  9 Aug 2019 04:41:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BE706B026C; Fri,  9 Aug 2019 04:41:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 311FD6B0269
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:41:41 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j22so60953881pfe.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:41:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=joheOuv75wiZDhRK/dGRAMxToLZySRFQgPGD7osns0c=;
        b=DOleq1/1etNtaGVj4EwHKUe+kOxKyNTtv5zWgKCNjm8M0gsrZT18vL6DpgBdOAC3x9
         Zx2LFAeHllD1DdtwySmc+ghCUOouEVwF5pnKCWpllKu3M6PjnmfeWnSrfOf+CAWRbMnT
         l0G2XpdNGBAyK8oYhqebTpSZKQJTl7Lm9ILSdHEIUiNg3j2m3F6q16TInd+/+LgcdZC/
         pv7v5NTEc2HoTOdo0H53VWhjCTi38iQ0aTfYQANHv5StWdgXxRxwWpZqdB3NXFQMK0v3
         pjyYPLV7ifLiUvBxkEr6CyfdWhCmGbNpWjAGVGK83T/WrzpDfOfpBYJ7lJmrNByISlDp
         BC1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVr7mFq31EwYMPBcb3FIF0Ijc0ucm3BOzfv6J+8r45JHpZyUKg+
	iuYdsYc7L70FBsb4c702lKrqJDWWKvGhKTIEFnmRpWDllaiUw2mZCSTc66+b4j26p7pHF6W5ivX
	dajbPryWL/8qZyXrwQ413PAsQcrEFFQpRTgvMzO2DOUHOZ3hqdlGAj46b4DqSKmHPTQ==
X-Received: by 2002:a62:8343:: with SMTP id h64mr2286082pfe.170.1565340100882;
        Fri, 09 Aug 2019 01:41:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfq/D6hvAfffDcMjiJl64dHWIXTrR5TIQnsoe02hKwl4DUHmp0J3lYGMwN+pmnsy7eOkLE
X-Received: by 2002:a62:8343:: with SMTP id h64mr2286040pfe.170.1565340100214;
        Fri, 09 Aug 2019 01:41:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340100; cv=none;
        d=google.com; s=arc-20160816;
        b=ESYOmK3DbctSPC6rPNt0Ki4I4k+MuNMYGVBG06m+BVBuoBJ/0gXyiQtVVzK0L/ALEu
         KdtxsPuk7CaUHv5er6meM6NSzFeo3/1H9ivRKvPYgytEt1i19/fLJiUUCWwEXoIZKBvi
         tnuRFvtCmmnaYN0uGA+iTR3rUocbWdWU4c7QWzhHPrD4YD8yFpnadVsAThLqX3K9SRgx
         w0xPh2VyCV9xzI8G7zcQz8tp2q+HRfNuRpsfITmLbEbhjz/cw2XFNsn9Ikb6l+nTka4F
         gdZnPH1p3KLCMCI3ENPjUfjRl9wTFa3q36mibhIFSgocLma3tsXi+MEfb+Z1xJIqVxVT
         jgZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=joheOuv75wiZDhRK/dGRAMxToLZySRFQgPGD7osns0c=;
        b=h87httjbIPGrosIMsygffdjtUdn0Z3ni8O+59Zaro4cilm90lZr1MZAS14712JJ9UV
         rmY1sWaRtku4TwckV8Di5N2vVb/vj/aOdgPprgSr+GV+jgO6P/bY3V5Cmdq7m2qoWJCe
         Bw5D+DYnCjurJowF2blvqt/3GcegXmrWU8qPGMvkvBfPUtPiBT+n6qhIuXZZIHbg6sXH
         qy1SSzWKfsrXKQVviRmdlxCqomqZBHcX4WWaEi2MI//+XVkj8jSp0ZSSo6TUbyCBm0JN
         29YeA6RFjuNvGV+S4uJlew9IbYyeDAZcMLAkwTe4S1C1SBMuQUvfNPG+iEecmIdbtySV
         UM2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a6si49491140pla.259.2019.08.09.01.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:41:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x798btxQ101105
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 04:41:39 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u94vqhdst-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:41:39 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 9 Aug 2019 09:41:37 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 09:41:34 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x798fX9V61735158
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 08:41:33 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2661DA4065;
	Fri,  9 Aug 2019 08:41:33 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 05288A405B;
	Fri,  9 Aug 2019 08:41:31 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.95.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 08:41:30 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Anshuman Khandual <khandual@linux.vnet.ibm.com>,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v6 7/7] KVM: PPC: Ultravisor: Add PPC_UV config option
Date: Fri,  9 Aug 2019 14:11:08 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190809084108.30343-1-bharata@linux.ibm.com>
References: <20190809084108.30343-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19080908-0012-0000-0000-0000033CA6CF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080908-0013-0000-0000-00002176ABF7
Message-Id: <20190809084108.30343-8-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=939 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anshuman Khandual <khandual@linux.vnet.ibm.com>

CONFIG_PPC_UV adds support for ultravisor.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
[ Update config help and commit message ]
Signed-off-by: Claudio Carvalho <cclaudio@linux.ibm.com>
---
 arch/powerpc/Kconfig | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index d8dcd8820369..8b36ca5ed3b0 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -448,6 +448,24 @@ config PPC_TRANSACTIONAL_MEM
 	help
 	  Support user-mode Transactional Memory on POWERPC.
 
+config PPC_UV
+	bool "Ultravisor support"
+	depends on KVM_BOOK3S_HV_POSSIBLE
+	select ZONE_DEVICE
+	select MIGRATE_VMA_HELPER
+	select DEV_PAGEMAP_OPS
+	select DEVICE_PRIVATE
+	select MEMORY_HOTPLUG
+	select MEMORY_HOTREMOVE
+	default n
+	help
+	  This option paravirtualizes the kernel to run in POWER platforms that
+	  supports the Protected Execution Facility (PEF). In such platforms,
+	  the ultravisor firmware runs at a privilege level above the
+	  hypervisor.
+
+	  If unsure, say "N".
+
 config LD_HEAD_STUB_CATCH
 	bool "Reserve 256 bytes to cope with linker stubs in HEAD text" if EXPERT
 	depends on PPC64
-- 
2.21.0

