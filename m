Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5817C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6759C233FD
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:26:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6759C233FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17CE96B02F7; Thu, 22 Aug 2019 06:26:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 133EE6B02F8; Thu, 22 Aug 2019 06:26:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3A056B02F9; Thu, 22 Aug 2019 06:26:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id CF94C6B02F7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:26:48 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9145155F87
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:26:48 +0000 (UTC)
X-FDA: 75849685296.06.ants23_587f70c672159
X-HE-Tag: ants23_587f70c672159
X-Filterd-Recvd-Size: 7668
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:26:47 +0000 (UTC)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7MAMbO7043796
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:26:46 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uhs2q0m64-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:26:46 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Thu, 22 Aug 2019 11:26:44 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 22 Aug 2019 11:26:41 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7MAQdxI44564908
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 10:26:39 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6D952AE058;
	Thu, 22 Aug 2019 10:26:39 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1F4B6AE053;
	Thu, 22 Aug 2019 10:26:37 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.57.57])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 22 Aug 2019 10:26:36 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v7 2/7] kvmppc: Shared pages support for secure guests
Date: Thu, 22 Aug 2019 15:56:15 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190822102620.21897-1-bharata@linux.ibm.com>
References: <20190822102620.21897-1-bharata@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19082210-0016-0000-0000-000002A16DD8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082210-0017-0000-0000-00003301A65C
Message-Id: <20190822102620.21897-3-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=752 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220112
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A secure guest will share some of its pages with hypervisor (Eg. virtio
bounce buffers etc). Support sharing of pages between hypervisor and
ultravisor.

Once a secure page is converted to shared page, the device page is
unmapped from the HV side page tables.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h |  3 ++
 arch/powerpc/kvm/book3s_hv_devm.c | 70 +++++++++++++++++++++++++++++--
 2 files changed, 69 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm=
/hvcall.h
index 2f6b952deb0f..05b8536f6653 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -337,6 +337,9 @@
 #define H_TLB_INVALIDATE	0xF808
 #define H_COPY_TOFROM_GUEST	0xF80C
=20
+/* Flags for H_SVM_PAGE_IN */
+#define H_PAGE_IN_SHARED        0x1
+
 /* Platform-specific hcalls used by the Ultravisor */
 #define H_SVM_PAGE_IN		0xEF00
 #define H_SVM_PAGE_OUT		0xEF04
diff --git a/arch/powerpc/kvm/book3s_hv_devm.c b/arch/powerpc/kvm/book3s_=
hv_devm.c
index 13722f27fa7d..6a3229b78fed 100644
--- a/arch/powerpc/kvm/book3s_hv_devm.c
+++ b/arch/powerpc/kvm/book3s_hv_devm.c
@@ -46,6 +46,7 @@ struct kvmppc_devm_page_pvt {
 	unsigned long *rmap;
 	unsigned int lpid;
 	unsigned long gpa;
+	bool skip_page_out;
 };
=20
 /*
@@ -139,6 +140,54 @@ kvmppc_devm_migrate_alloc_and_copy(struct migrate_vm=
a *mig,
 	return 0;
 }
=20
+/*
+ * Shares the page with HV, thus making it a normal page.
+ *
+ * - If the page is already secure, then provision a new page and share
+ * - If the page is a normal page, share the existing page
+ *
+ * In the former case, uses the dev_pagemap_ops migrate_to_ram handler
+ * to unmap the device page from QEMU's page tables.
+ */
+static unsigned long
+kvmppc_share_page(struct kvm *kvm, unsigned long gpa, unsigned long page=
_shift)
+{
+
+	int ret =3D H_PARAMETER;
+	struct page *devm_page;
+	struct kvmppc_devm_page_pvt *pvt;
+	unsigned long pfn;
+	unsigned long *rmap;
+	struct kvm_memory_slot *slot;
+	unsigned long gfn =3D gpa >> page_shift;
+	int srcu_idx;
+
+	srcu_idx =3D srcu_read_lock(&kvm->srcu);
+	slot =3D gfn_to_memslot(kvm, gfn);
+	if (!slot)
+		goto out;
+
+	rmap =3D &slot->arch.rmap[gfn - slot->base_gfn];
+	if (kvmppc_rmap_is_devm_pfn(*rmap)) {
+		devm_page =3D pfn_to_page(*rmap & ~KVMPPC_RMAP_DEVM_PFN);
+		pvt =3D (struct kvmppc_devm_page_pvt *)
+			devm_page->zone_device_data;
+		pvt->skip_page_out =3D true;
+	}
+
+	pfn =3D gfn_to_pfn(kvm, gpa >> page_shift);
+	if (is_error_noslot_pfn(pfn))
+		goto out;
+
+	ret =3D uv_page_in(kvm->arch.lpid, pfn << page_shift, gpa, 0, page_shif=
t);
+	if (ret =3D=3D U_SUCCESS)
+		ret =3D H_SUCCESS;
+	kvm_release_pfn_clean(pfn);
+out:
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	return ret;
+}
+
 /*
  * Move page from normal memory to secure memory.
  */
@@ -159,9 +208,12 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long =
gpa,
 	if (page_shift !=3D PAGE_SHIFT)
 		return H_P3;
=20
-	if (flags)
+	if (flags & ~H_PAGE_IN_SHARED)
 		return H_P2;
=20
+	if (flags & H_PAGE_IN_SHARED)
+		return kvmppc_share_page(kvm, gpa, page_shift);
+
 	ret =3D H_PARAMETER;
 	down_read(&kvm->mm->mmap_sem);
 	srcu_idx =3D srcu_read_lock(&kvm->srcu);
@@ -211,7 +263,7 @@ kvmppc_devm_fault_migrate_alloc_and_copy(struct migra=
te_vma *mig,
 	struct page *dpage, *spage;
 	struct kvmppc_devm_page_pvt *pvt;
 	unsigned long pfn;
-	int ret;
+	int ret =3D U_SUCCESS;
=20
 	spage =3D migrate_pfn_to_page(*mig->src);
 	if (!spage || !(*mig->src & MIGRATE_PFN_MIGRATE))
@@ -226,8 +278,18 @@ kvmppc_devm_fault_migrate_alloc_and_copy(struct migr=
ate_vma *mig,
 	pvt =3D spage->zone_device_data;
=20
 	pfn =3D page_to_pfn(dpage);
-	ret =3D uv_page_out(pvt->lpid, pfn << page_shift, pvt->gpa, 0,
-			  page_shift);
+
+	/*
+	 * This same function is used in two cases:
+	 * - When HV touches a secure page, for which we do page-out
+	 * - When a secure page is converted to shared page, we touch
+	 *   the page to essentially unmap the device page. In this
+	 *   case we skip page-out.
+	 */
+	if (!pvt->skip_page_out)
+		ret =3D uv_page_out(pvt->lpid, pfn << page_shift, pvt->gpa, 0,
+				  page_shift);
+
 	if (ret =3D=3D U_SUCCESS)
 		*mig->dst =3D migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
 	else {
--=20
2.21.0


