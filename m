Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A1AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED4552171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED4552171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D3836B0266; Fri,  9 Aug 2019 04:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55D016B0269; Fri,  9 Aug 2019 04:41:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D4DC6B026A; Fri,  9 Aug 2019 04:41:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 039706B0269
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:41:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so52464536pgv.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:41:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=DSGGS4ckthPOgMVW/7AjdVqvu1U/hZH+bha8WkDduHw=;
        b=Y+zKfV0DGrE3SuS9RdlmjmlbKmVlXMouT/m67UzszEygN7TdkDU/nJ7SmNQ2saF29d
         Xy4nXzjaIb9OwGo/CyAHuMUs+2LDMxCo1KP/KTQKmVDE6YtJntpSE+w3uDp8XAM0CFgw
         fqwf2SFSWBG5WtY5OILJILcGcDrTn1D8c/l99zgSpJ441FJYH9cBRp7EcTQOnH86gqXR
         BJEexhXMdgHZpKLAigxEp+UOgJHkQa71laPOAMwkdnvaaSrmerLYqyYdDsAxFC0PlL09
         UuNSOlFyi9k8FoMgJhkchpa3LSduQWw45dWMyIG8fn44Ow2W2STC+JQIt/D70a82JD3B
         3kNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUCPhpnk/v9pj2q182kiRDv1WJ7cc1yemmx4Pq0PcRGMIsISy4h
	G9a70wGBqjwPrnV63mzcO04uUYRx1xxTUo8qb+AYUNrYDSAD4hm3EWT24KTZ2N4u5NrjaD1iLcj
	w84GTzl8lPFPzQhdgF6tZvlWKKSWOMmes1r67fzL9ZjstxSk5Ft4bGhI9JmilhOtsWg==
X-Received: by 2002:a17:902:28a4:: with SMTP id f33mr1442871plb.50.1565340092586;
        Fri, 09 Aug 2019 01:41:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPQjEGwv1eyTT5vU8Myy7VfCebmzsbV4tsnTjXpCkGR4dik7ZDJrW4oe7II7Bs3Jj3SbLd
X-Received: by 2002:a17:902:28a4:: with SMTP id f33mr1442827plb.50.1565340091675;
        Fri, 09 Aug 2019 01:41:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340091; cv=none;
        d=google.com; s=arc-20160816;
        b=dtaLYOJ6D7DBxKEBnwvgLCT4oQnAsCNe+WRgQN542G6qXhyKvtB4PKoBfEnIDoXpJl
         pF72fDEXovR8uR486tqM03+r9eVrdE3MFgiy31FzV+wxQCt6Dlt952nc03L7xvol/mKr
         Tc2k1+XZy/hALP7cBDppaBISEyRtQZ22EVp1Gawwh/vSwpxHcYGRjgywv7JVoU0j9wEb
         JHIIppbFdSCqyj3SgIRSWuMWg+aNOVb9atfPhwUodavA9UH2fLStuhDxnBaIIsiabVQ+
         JnD43gpwNLx7Ks4hpn0l8WCkv4EvV2i/rK9CrMuSIKORztQHReCdlDbxrzf/rgqTwfv6
         FXXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=DSGGS4ckthPOgMVW/7AjdVqvu1U/hZH+bha8WkDduHw=;
        b=CO28UjgU/VlCMaYBVzpbjxASqUA6XX+Sxu3mVu4JVaEu9GcmtTdWnQR8qm8SbpC685
         sZ64xuT6wLhrxX+7StQlGZVDCA10f/hoQ+4DNGS0iRGp+Bkahv9wwfvXuz0qtKWKvREw
         5QoFdPeVjAjKy4Pxxz1d17HqURv724F0bKL0yFguq6Z/KWr7WeqHrkkboI1sWwMAIiWJ
         CM7fV1wZ1ks0hYRLchQh0dS2gqO2EXTt83cCFNNSoYsy1Py4VEKrmuvqXQdbSOtFZ+jN
         ZYuGRTc2zIbfFLSz7M8aBUX+0TpZ4d3Wy0P5/M2h/g0SWxQ3FrpsFSUwWyBmmnqfp+L8
         +9eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u17si57300803pfc.210.2019.08.09.01.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:41:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x798bc5N063074
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 04:41:31 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u94f62e2a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:41:30 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 9 Aug 2019 09:41:21 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 09:41:18 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x798fGi851904514
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 08:41:16 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ABE50A4062;
	Fri,  9 Aug 2019 08:41:16 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AFE64A405C;
	Fri,  9 Aug 2019 08:41:14 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.95.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 08:41:14 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v6 0/7] KVMPPC driver to manage secure guest pages
Date: Fri,  9 Aug 2019 14:11:01 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19080908-0020-0000-0000-0000035DA566
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080908-0021-0000-0000-000021B2ABF1
Message-Id: <20190809084108.30343-1-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=765 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A pseries guest can be run as a secure guest on Ultravisor-enabled
POWER platforms. On such platforms, this driver will be used to manage
the movement of guest pages between the normal memory managed by
hypervisor(HV) and secure memory managed by Ultravisor(UV).

Private ZONE_DEVICE memory equal to the amount of secure memory
available in the platform for running secure guests is created
via a char device. Whenever a page belonging to the guest becomes
secure, a page from this private device memory is used to
represent and track that secure page on the HV side. The movement
of pages between normal and secure memory is done via
migrate_vma_pages().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

These patches are against Christoph Hellwig's migrate_vma-cleanup.2
branch
(http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/migrate_vma-cleanup.2)

plus

Claudio Carvalho's base ultravisor enablement patchset
(https://lore.kernel.org/linuxppc-dev/20190808040555.2371-1-cclaudio@linux.ibm.com/T/#t)

These patches along with Claudio's above patches are required to
run a secure pseries guest on KVM.

Changes in v6
=============
Updated the driver to account for the changes in HMM and migrate_vma()
by Christoph Hellwig.
 - Not using any HMM routines any more.
 - Switched to using migrate_vma_pages()

v5: https://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg153294.html

Anshuman Khandual (1):
  KVM: PPC: Ultravisor: Add PPC_UV config option

Bharata B Rao (6):
  kvmppc: Driver to manage pages of secure guest
  kvmppc: Shared pages support for secure guests
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM
  kvmppc: Radix changes for secure guest
  kvmppc: Support reset of secure guest

 Documentation/virtual/kvm/api.txt          |  18 +
 arch/powerpc/Kconfig                       |  18 +
 arch/powerpc/include/asm/hvcall.h          |   9 +
 arch/powerpc/include/asm/kvm_book3s_devm.h |  48 ++
 arch/powerpc/include/asm/kvm_host.h        |  28 +
 arch/powerpc/include/asm/kvm_ppc.h         |   2 +
 arch/powerpc/include/asm/ultravisor-api.h  |   6 +
 arch/powerpc/include/asm/ultravisor.h      |  36 ++
 arch/powerpc/kvm/Makefile                  |   3 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c     |  22 +
 arch/powerpc/kvm/book3s_hv.c               | 115 ++++
 arch/powerpc/kvm/book3s_hv_devm.c          | 668 +++++++++++++++++++++
 arch/powerpc/kvm/powerpc.c                 |  12 +
 include/uapi/linux/kvm.h                   |   1 +
 14 files changed, 986 insertions(+)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_devm.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_devm.c

-- 
2.21.0

