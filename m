Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAFBFC606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FEF420665
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FEF420665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC59B8E004E; Tue,  9 Jul 2019 06:26:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9F888E0032; Tue,  9 Jul 2019 06:26:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C42848E004E; Tue,  9 Jul 2019 06:26:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87A2E8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:26:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so12145730pfo.22
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:26:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=2eRHuFRxu3nmgRqPvDNZA8w7i7TdtZDNf4qyGtD4kMY=;
        b=c8JV51tLD96i2dnIr/UJY5F58dDNazdH9Jo1PPxaA9CmvrTf1xmZ2HjTRr+EumL0To
         UAqdzYbsyohFiwBV1QayNbqwCq/638KcekNRsMg8gloqqKj4qBIGd3Fid6Qr/wqNJpcG
         vKc1hdRoR3h2kDeLbYcyL91nynU2yivjjTIiQB+lkh0Ubz0muNxR4+i8hyxa9LHHWnIS
         Epsges5gBuaChWJZbuWDtwDzf7mXh/4ROrP8RPE6c8LlOcS1poMyp9ym/B55+D5dMLut
         NO4jjaBLEw1ICE/SOFSriW5P79CSinzHoGw8jROPh8MJXQ4Tww/rxMuv+vgWqFhV2yX/
         DfhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWiEqKUj8DZaM6ZXqaFVOrxJ82nbraUyPdDgItMBPVbUOEZQsWN
	7CwXemTv0ntI00uGZ4ZNO/E4l6VZiPl6iYhwLwhB6y7NWN/eHhxYgQam8micBAvnyEj8iToVxg4
	z7E1sQwHMDgEnAmnJ/NZqcNtaMEWcDPJIqvozI+nEOsI8ij/Dn1WB9T51S4MwNIqizg==
X-Received: by 2002:a63:34c3:: with SMTP id b186mr29432066pga.294.1562667979043;
        Tue, 09 Jul 2019 03:26:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxf91rg2xsYxLoNaix2h408Byykxh6tG3SsauYab1lcHBilY1cdqZ2Y8m34655FGB4VbSSw
X-Received: by 2002:a63:34c3:: with SMTP id b186mr29432008pga.294.1562667978207;
        Tue, 09 Jul 2019 03:26:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562667978; cv=none;
        d=google.com; s=arc-20160816;
        b=lEUUNGd8ITC75W+tUStWRgGptf4ZSPITAUAXHawqmOQSNvOra7/44AUeM7bfFI3tXu
         Sqe67NRGHcvSOvESq//jWU0n7IeqfsMW/y0J33/f4K+nT6vH7v7dJc0TZMvP1rj3THK2
         fJVkP0ddRPdp8eqyX5plxUkNm5DPJMehYRG6knpPB7k/ho0Am/lJB5Ik3SMo0uEwYR79
         X0D1VrwD/DKiOnyz69vmkj5GT1BVL1vEINHH8kvH6kjXsuFggRpDF/7DZ3P/WWEjFRP1
         QGfwedoncmFG9vZGXfSsAo7KaimjwK52oWcD44dBvRiof/DCaOPmO+cQ8bQUIsGSyXQp
         RVEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=2eRHuFRxu3nmgRqPvDNZA8w7i7TdtZDNf4qyGtD4kMY=;
        b=Xe/HueDZcpazxutfsYTzSOVLXEQocOALS2Kz5LLC5RYc284saeFj5aT0CGi2p1/NDu
         jnyNX24AA0+Bv+gP0/QKq8N0RGWugB6NdrC79GlmJf9HwRHCG+dJ78pGB8Gx+PjWh2fZ
         o8Szpq1bBwAqs+pcT71rC4XStnhHi7lgGG9LYFqV3vhLp8WWRmrQQkOFmhVbyrrONgIz
         hS8OVCGhKxPtuwdSQvQ9rP7tlZDigfU8Vm/TeXXAAoym+7KMXI+Ak2KYGCWAj7OZVEVf
         9uE0AY1p8ruFbk6LVEAoX8PsJvxYwu3aZYhEJVy31J6DlzyRFMZ9uECdc72U3FzBXcn/
         n+Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n8si22487548pfa.223.2019.07.09.03.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:26:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69AMaLO001907
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:26:17 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmqe6vcym-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:26:17 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:26:14 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:26:12 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69AQAeW60096766
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:26:10 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CA15BAE045;
	Tue,  9 Jul 2019 10:26:10 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D4275AE051;
	Tue,  9 Jul 2019 10:26:08 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 10:26:08 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com,
        Anshuman Khandual <khandual@linux.vnet.ibm.com>,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v5 7/7] KVM: PPC: Ultravisor: Add PPC_UV config option
Date: Tue,  9 Jul 2019 15:55:45 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190709102545.9187-1-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19070910-0028-0000-0000-000003824292
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0029-0000-0000-000024424E67
Message-Id: <20190709102545.9187-8-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=961 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090127
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
 arch/powerpc/Kconfig | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index f0e5b38d52e8..20c6c213d2be 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -440,6 +440,26 @@ config PPC_TRANSACTIONAL_MEM
        ---help---
          Support user-mode Transactional Memory on POWERPC.
 
+config PPC_UV
+	bool "Ultravisor support"
+	depends on KVM_BOOK3S_HV_POSSIBLE
+	select HMM_MIRROR
+	select HMM
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

