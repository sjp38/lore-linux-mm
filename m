Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65F18C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0681D20665
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0681D20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64DA48E0047; Tue,  9 Jul 2019 06:26:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FD7C8E0032; Tue,  9 Jul 2019 06:26:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C4028E0047; Tue,  9 Jul 2019 06:26:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 282B38E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:26:03 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l141so12917226ywc.11
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:26:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=/AVivOJLHIthbxLbPC1Oa4Mk7L4hX1Np2Or936u25I0=;
        b=c7EYRWJgERxibbpwJ8OlRI+7ieU14iSKwDgJ75j3k602saGPPix1r4iTzGORJzl12A
         tjO3DWCax9jPy64JoeUqrmYzRWtj55pMJKW099rMql2jEZ2kWTpoCb9ObVMOkja8ZlWJ
         GaWB590lvRxerOGAW7BGlKvs4FwS1hyhfALcOBWbTyU3xcOz3DtUoL8jXZ68aLSP2J9j
         tCzlnx9V6pzYZBWVhmyOVw5XURyfRIk0N7b5zZ0lJlu+aQtUHSwefk2DFZnL5Jnz6FyQ
         vFTvjLC9OfcaWH+KK/wdtaWTmnl7kTLDTMNMwD1zq257u+dPokAGBJ7uRLBlQHL861e8
         sjTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVw1v7BBtICoDz9iDDCFyV/Z87Jns9uc/YrOvF2FVC9XrIS1dQ/
	tU5SdOFOjFEN4pzjSzIOuRtA2PyHvYu0hE6S2wWbaBbvbE88q87eUcQ8rKq8X1i7OdS4EaXjcd8
	Dp5CTeXKQfQGYdtPUpXb6UBM6rbb1PLmjrsmm7gxOJzeEOITaYwRV53j+HE3se6Mczw==
X-Received: by 2002:a81:a186:: with SMTP id y128mr14592581ywg.128.1562667962933;
        Tue, 09 Jul 2019 03:26:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTlNeCU7zeajoH9khOL/8nKMZdfi/jMwu/AeI9RdSswHBgBlpB31esSbTu22HozWQM3hxn
X-Received: by 2002:a81:a186:: with SMTP id y128mr14592556ywg.128.1562667962087;
        Tue, 09 Jul 2019 03:26:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562667962; cv=none;
        d=google.com; s=arc-20160816;
        b=ETs9JjO2w/e+UCc3qY2pYWrd8HCyxZB9RE+0uwM6FYJJjj8hvxC7Yet8ApZ8v040MJ
         1DREB5coZHuY6tyWYCJO0c6L2+5Ncg9tnnPC/GHvdh7Ir+ixVfxSjDghbSFOpDlbsuKk
         KvLm3wPp5OKzl9Q67XzbzNXZ6r9SETSNxf4LfEMxxY0szc14HvQQQyxKOkgWJfQNEOjR
         ++SF/2uVwbci6iMtDGPXeXuRFkz4hWOjxAgE5UsqAXtNedcnBrrpVvukW+GwEG4PvwvX
         6d0A1S1trIZGQirZr1w5mxIsHemeNRs3fVC6K6t7fENRlZ6BTtY+RTmR6MrU1PKEvlKg
         9akQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=/AVivOJLHIthbxLbPC1Oa4Mk7L4hX1Np2Or936u25I0=;
        b=jXuHoEcv3vtAqDH1GYkvXxyB2EcXuDlkhwtaZgVm29B1tah6HHG9QK46rYUjLobAKN
         hL1y2ade3O3UAme7h2W4+2qLkBNff0ePf2sLUcGYQ0Ph0eZfRLOs7LxT8M7E5g8q3TPy
         e7SU6ZWlDTCkE3LJ9VQ8Ylc8XZx1q9v2+C3IOSpH1UF3VLtzpsb99gFo0+UvB99bQfbb
         12yRIaifxjJQ5VHwhF5JloKnUk+BblzqQSvZ2F1O/F3fRra4OUNq0K5p4/gwyc3lmUQ/
         WeqPtX1nw7fS19UjXR/54mG74GbaO7c1WXkzIchuqc8f3ZB0Uetw/IulCvzY2P8/rhIX
         avLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w2si1639638yba.64.2019.07.09.03.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:26:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69AMc07012120
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:26:01 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tmpfmpk6e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:26:01 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:25:59 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:25:57 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69APtHU49479782
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:25:55 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6EC45AE045;
	Tue,  9 Jul 2019 10:25:55 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 98CD1AE051;
	Tue,  9 Jul 2019 10:25:53 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 10:25:53 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v5 0/7] kvmppc: HMM driver to manage pages of secure guest
Date: Tue,  9 Jul 2019 15:55:38 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19070910-4275-0000-0000-0000034A7EDF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-4276-0000-0000-0000385AA8D4
Message-Id: <20190709102545.9187-1-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090127
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A pseries guest can be run as a secure guest on Ultravisor-enabled
POWER platforms. On such platforms, this driver will be used to manage
the movement of guest pages between the normal memory managed by
hypervisor (HV) and secure memory managed by Ultravisor (UV).

Private ZONE_DEVICE memory equal to the amount of secure memory
available in the platform for running secure guests is created
via a HMM device. The movement of pages between normal and secure
memory is done by ->alloc_and_copy() callback routine of migrate_vma().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

These patches apply and work on top of the base Ultravisor v4 patches
posted by Claudio Carvalho at:
https://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg152842.html

Changes in v5
=============
- Hold kvm->srcu lock until we are done migrating the page.
- Ensure we take heavier lock mmap_sem first before taking kvm->srcu
  lock.
- Code reorgs, comments updates and commit messages updates.
- Ensure we don't lookup HV side partition scoped page tables from
  memslot flush code, this is required for memory unplug to make
  progress.
- Fix reboot of secure SMP guests by unpinng the VPA pages during
  reboot (Ram Pai).
- Added documentation for the new KVM_PP_SVM_OFF ioctl.
- Using different bit slot to differentiate HMM PFN from other uses
  of rmap entries.
- Remove kvmppc_hmm_release_pfns() as releasing of HMM PFNs will be
  done by unmap_vmas() and its callers during VM shutdown.
- Carrying the patch that adds CONFIG_PPC_UV with this patchset.

v4: https://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg151156.html

Anshuman Khandual (1):
  KVM: PPC: Ultravisor: Add PPC_UV config option

Bharata B Rao (6):
  kvmppc: HMM backend driver to manage pages of secure guest
  kvmppc: Shared pages support for secure guests
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM
  kvmppc: Radix changes for secure guest
  kvmppc: Support reset of secure guest

 Documentation/virtual/kvm/api.txt         |  19 +
 arch/powerpc/Kconfig                      |  20 +
 arch/powerpc/include/asm/hvcall.h         |   9 +
 arch/powerpc/include/asm/kvm_book3s_hmm.h |  48 ++
 arch/powerpc/include/asm/kvm_host.h       |  28 +
 arch/powerpc/include/asm/kvm_ppc.h        |   2 +
 arch/powerpc/include/asm/ultravisor-api.h |   6 +
 arch/powerpc/include/asm/ultravisor.h     |  47 ++
 arch/powerpc/kvm/Makefile                 |   3 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c    |  22 +
 arch/powerpc/kvm/book3s_hv.c              | 115 ++++
 arch/powerpc/kvm/book3s_hv_hmm.c          | 656 ++++++++++++++++++++++
 arch/powerpc/kvm/powerpc.c                |  12 +
 include/uapi/linux/kvm.h                  |   1 +
 tools/include/uapi/linux/kvm.h            |   1 +
 15 files changed, 989 insertions(+)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_hmm.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

-- 
2.21.0

