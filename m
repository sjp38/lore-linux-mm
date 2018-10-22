Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88C5A6B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x10-v6so24235848edx.9
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:18:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k10-v6si1484433ejh.140.2018.10.21.22.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 22:18:54 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9M59YH8133458
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:53 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2n9315rvue-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:53 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 22 Oct 2018 06:18:51 +0100
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v1 0/4] kvmppc: HMM backend driver to manage pages of secure guest
Date: Mon, 22 Oct 2018 10:48:33 +0530
Message-Id: <20181022051837.1165-1-bharata@linux.ibm.com>
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

Changes in v1
=============
- Moved from global HMM pages hash table to per guest hash
- Added support for shared pages (non-secure/normal pages of a secure
  guest)
- Misc cleanups and fixes

v0: https://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg138742.html

Bharata B Rao (4):
  kvmppc: HMM backend driver to manage pages of secure guest
  kvmppc: Add support for shared pages in HMM driver
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM

 arch/powerpc/include/asm/hvcall.h    |   9 +-
 arch/powerpc/include/asm/kvm_host.h  |  16 +
 arch/powerpc/include/asm/kvm_ppc.h   |  34 +-
 arch/powerpc/include/asm/ucall-api.h |  31 ++
 arch/powerpc/kvm/Makefile            |   3 +
 arch/powerpc/kvm/book3s.c            |   5 +-
 arch/powerpc/kvm/book3s_hv.c         | 115 +++++-
 arch/powerpc/kvm/book3s_hv_hmm.c     | 575 +++++++++++++++++++++++++++
 arch/powerpc/kvm/book3s_pr.c         |   3 +-
 arch/powerpc/kvm/powerpc.c           |   2 +-
 10 files changed, 785 insertions(+), 8 deletions(-)
 create mode 100644 arch/powerpc/include/asm/ucall-api.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

-- 
2.17.1
