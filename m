Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0836B243E
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:28:24 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so2455172edz.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 21:28:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l1si4551487edc.252.2018.11.20.21.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 21:28:22 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAL5SKjB052746
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:28:21 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nvxhyd975-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:28:21 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 21 Nov 2018 05:28:19 -0000
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v2 0/4] kvmppc: HMM backend driver to manage pages of secure guest
Date: Wed, 21 Nov 2018 10:58:07 +0530
Message-Id: <20181121052811.4819-1-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com, Bharata B Rao <bharata@linux.ibm.com>

Hi,

A pseries guest can be run as a secure guest on Ultravisor-enabled
POWER platforms. On such platforms, this driver will be used to manage
the movement of guest pages between the normal memory managed by
hypervisor (HV) and secure memory managed by Ultravisor (UV).

This is an early post of HMM driver patches that manage page migration
between normal and secure memory.

Private ZONE_DEVICE memory equal to the amount of secure memory
available in the platform for running secure guests is created
via a HMM device. The movement of pages between normal and secure
memory is done by ->alloc_and_copy() callback routine of migrate_vma().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

The implementation of uvcall themselves are not present in this post
and will be posted separately.

Changes in v2
=============
- Removed the HMM PFN hash table as the same information is now being
  stored in kvm_memory_slot->arch.rmap[] array as suggested by
  Paul Mackerras.
- Addressed the review comments from v1.

Bharata B Rao (4):
  kvmppc: HMM backend driver to manage pages of secure guest
  kvmppc: Add support for shared pages in HMM driver
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM

 arch/powerpc/include/asm/hvcall.h    |   9 +
 arch/powerpc/include/asm/kvm_host.h  |  15 +
 arch/powerpc/include/asm/kvm_ppc.h   |  46 ++-
 arch/powerpc/include/asm/ucall-api.h |  33 ++
 arch/powerpc/kvm/Makefile            |   3 +
 arch/powerpc/kvm/book3s.c            |   5 +-
 arch/powerpc/kvm/book3s_hv.c         |  49 ++-
 arch/powerpc/kvm/book3s_hv_hmm.c     | 542 +++++++++++++++++++++++++++
 arch/powerpc/kvm/book3s_pr.c         |   3 +-
 arch/powerpc/kvm/powerpc.c           |   2 +-
 10 files changed, 700 insertions(+), 7 deletions(-)
 create mode 100644 arch/powerpc/include/asm/ucall-api.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

-- 
2.17.1
