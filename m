Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D85BC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2067208E4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2067208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856D36B0007; Tue, 10 Sep 2019 04:30:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 807726B0008; Tue, 10 Sep 2019 04:30:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71D316B000A; Tue, 10 Sep 2019 04:30:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDA96B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:00 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id EFAC4181AC9BF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:29:59 +0000 (UTC)
X-FDA: 75918338118.29.cat35_1d0314ebcbd3b
X-HE-Tag: cat35_1d0314ebcbd3b
X-Filterd-Recvd-Size: 7321
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:29:59 +0000 (UTC)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8A8RJmC108784
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:29:57 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ux55bdvf1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:29:57 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 10 Sep 2019 09:29:55 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 10 Sep 2019 09:29:52 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8A8TosZ41091092
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 10 Sep 2019 08:29:50 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6391E52051;
	Tue, 10 Sep 2019 08:29:50 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.35.217])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5D5775204F;
	Tue, 10 Sep 2019 08:29:48 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v8 0/8] kvmppc: Driver to manage pages of secure guest
Date: Tue, 10 Sep 2019 13:59:38 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091008-0016-0000-0000-000002A96838
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091008-0017-0000-0000-00003309ED99
Message-Id: <20190910082946.7849-1-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-10_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909100085
Content-Transfer-Encoding: quoted-printable
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
available in the platform for running secure guests is created.
Whenever a page belonging to the guest becomes secure, a page from
this private device memory is used to represent and track that secure
page on the HV side. The movement of pages between normal and secure
memory is done via migrate_vma_pages(). The reverse movement is driven
via pagemap_ops.migrate_to_ram().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

These patches are against hmm.git
(https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=3Dh=
mm)

plus

Claudio Carvalho's base ultravisor enablement patches that are present
in Michael Ellerman's tree
(https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git/log/?h=
=3Dtopic/ppc-kvm)

These patches along with Claudio's above patches are required to
run secure pseries guests on KVM. This patchset is based on hmm.git
because hmm.git has migrate_vma cleanup and not-device memremap_pages
patchsets that are required by this patchset.

Changes in v8
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- s/kvmppc_devm/kvmppc_uvmem
- Carrying Suraj's patch that defines bit positions for different rmap
  functions from Paul's kvm-next branch. Added KVMPPC_RMAP_UVMEM_PFN
  to this patch.
- No need to use irqsave version of spinlock to protect pfn bitmap
- mmap_sem and srcu_lock reversal in page-in/page-out so that we
  have uniform locking semantics in page-in, page-out, fault and
  reset paths. This also matches with other usages of the same
  two locks in powerpc code.
- kvmppc_uvmem_free_memslot_pfns() needs kvm srcu read lock.
- Addressed all the review feedback from Christoph and Sukadev.
  - Dropped kvmppc_rmap_is_devm_pfn() and introduced kvmppc_rmap_type()
  - Bail out early if page-in request comes for an already paged-in page
  - kvmppc_uvmem_pfn_lock re-arrangement
  - Check for failure from gfn_to_memslot in kvmppc_h_svm_page_in
  - Consolidate migrate_vma setup and related code into two helpers
    kvmppc_svm_page_in/out.
  - Use NUMA_NO_NODE in memremap_pages() instead of -1
  - Removed externs in declarations
  - Ensure *rmap assignment gets cleared in the error case in
    kvmppc_uvmem_get_page()
- A few other code cleanups

v7: https://lists.ozlabs.org/pipermail/linuxppc-dev/2019-August/195631.ht=
ml

Anshuman Khandual (1):
  KVM: PPC: Ultravisor: Add PPC_UV config option

Bharata B Rao (6):
  kvmppc: Movement of pages between normal and secure memory
  kvmppc: Shared pages support for secure guests
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM
  kvmppc: Radix changes for secure guest
  kvmppc: Support reset of secure guest

Suraj Jitindar Singh (1):
  KVM: PPC: Book3S HV: Define usage types for rmap array in guest
    memslot

 Documentation/virt/kvm/api.txt              |  19 +
 arch/powerpc/Kconfig                        |  17 +
 arch/powerpc/include/asm/hvcall.h           |   9 +
 arch/powerpc/include/asm/kvm_book3s_uvmem.h |  48 ++
 arch/powerpc/include/asm/kvm_host.h         |  56 +-
 arch/powerpc/include/asm/kvm_ppc.h          |   2 +
 arch/powerpc/include/asm/ultravisor-api.h   |   6 +
 arch/powerpc/include/asm/ultravisor.h       |  36 ++
 arch/powerpc/kvm/Makefile                   |   3 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c      |  22 +
 arch/powerpc/kvm/book3s_hv.c                | 121 ++++
 arch/powerpc/kvm/book3s_hv_rm_mmu.c         |   2 +-
 arch/powerpc/kvm/book3s_hv_uvmem.c          | 604 ++++++++++++++++++++
 arch/powerpc/kvm/powerpc.c                  |  12 +
 include/uapi/linux/kvm.h                    |   1 +
 15 files changed, 953 insertions(+), 5 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_uvmem.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_uvmem.c

--=20
2.21.0


