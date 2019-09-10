Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D274AC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0022206A5
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0022206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D3D66B000E; Tue, 10 Sep 2019 04:30:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 485F66B0010; Tue, 10 Sep 2019 04:30:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 373596B0266; Tue, 10 Sep 2019 04:30:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id 104B56B000E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:11 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B36D98243765
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:30:10 +0000 (UTC)
X-FDA: 75918338580.30.smash38_1e9d65f7cfd37
X-HE-Tag: smash38_1e9d65f7cfd37
X-Filterd-Recvd-Size: 5752
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:30:10 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8A8RKc2028920
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:09 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ux5htn5pj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:09 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 10 Sep 2019 09:30:07 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 10 Sep 2019 09:30:04 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8A8Tcvs37159320
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 10 Sep 2019 08:29:38 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9F35B52057;
	Tue, 10 Sep 2019 08:30:02 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.35.217])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6FBC652054;
	Tue, 10 Sep 2019 08:30:00 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>,
        Paul Mackerras <paulus@ozlabs.org>
Subject: [PATCH v8 5/8] kvmppc: Handle memory plug/unplug to secure VM
Date: Tue, 10 Sep 2019 13:59:43 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190910082946.7849-1-bharata@linux.ibm.com>
References: <20190910082946.7849-1-bharata@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091008-0008-0000-0000-00000313C59E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091008-0009-0000-0000-00004A322C05
Message-Id: <20190910082946.7849-6-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-10_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=799 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909100085
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register the new memslot with UV during plug and unregister
the memslot during unplug.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
Acked-by: Paul Mackerras <paulus@ozlabs.org>
---
 arch/powerpc/include/asm/ultravisor-api.h |  1 +
 arch/powerpc/include/asm/ultravisor.h     |  5 +++++
 arch/powerpc/kvm/book3s_hv.c              | 21 +++++++++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/inc=
lude/asm/ultravisor-api.h
index c578d9b13a56..46b1ee381695 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -26,6 +26,7 @@
 #define UV_WRITE_PATE			0xF104
 #define UV_RETURN			0xF11C
 #define UV_REGISTER_MEM_SLOT		0xF120
+#define UV_UNREGISTER_MEM_SLOT		0xF124
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
=20
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include=
/asm/ultravisor.h
index 58ccf5e2d6bb..719c0c3930b9 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -52,4 +52,9 @@ static inline int uv_register_mem_slot(u64 lpid, u64 st=
art_gpa, u64 size,
 			    size, flags, slotid);
 }
=20
+static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
+{
+	return ucall_norets(UV_UNREGISTER_MEM_SLOT, lpid, slotid);
+}
+
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 2527f1676b59..fc93e5ba5683 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -74,6 +74,7 @@
 #include <asm/hw_breakpoint.h>
 #include <asm/kvm_host.h>
 #include <asm/kvm_book3s_uvmem.h>
+#include <asm/ultravisor.h>
=20
 #include "book3s.h"
=20
@@ -4517,6 +4518,26 @@ static void kvmppc_core_commit_memory_region_hv(st=
ruct kvm *kvm,
 	if (change =3D=3D KVM_MR_FLAGS_ONLY && kvm_is_radix(kvm) &&
 	    ((new->flags ^ old->flags) & KVM_MEM_LOG_DIRTY_PAGES))
 		kvmppc_radix_flush_memslot(kvm, old);
+	/*
+	 * If UV hasn't yet called H_SVM_INIT_START, don't register memslots.
+	 */
+	if (!kvm->arch.secure_guest)
+		return;
+
+	switch (change) {
+	case KVM_MR_CREATE:
+		uv_register_mem_slot(kvm->arch.lpid,
+				     new->base_gfn << PAGE_SHIFT,
+				     new->npages * PAGE_SIZE,
+				     0, new->id);
+		break;
+	case KVM_MR_DELETE:
+		uv_unregister_mem_slot(kvm->arch.lpid, old->id);
+		break;
+	default:
+		/* TODO: Handle KVM_MR_MOVE */
+		break;
+	}
 }
=20
 /*
--=20
2.21.0


