Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED0BDC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5092D206A5
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5092D206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8B256B000D; Tue, 10 Sep 2019 04:30:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3BD76B000E; Tue, 10 Sep 2019 04:30:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A04BA6B0010; Tue, 10 Sep 2019 04:30:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id 808926B000D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:08 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 30B5B180AD801
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:30:08 +0000 (UTC)
X-FDA: 75918338496.13.spot12_1e39b1927b252
X-HE-Tag: spot12_1e39b1927b252
X-Filterd-Recvd-Size: 9271
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:30:07 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8A8RGcM018458
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:05 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ux6huby27-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:05 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 10 Sep 2019 09:30:03 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 10 Sep 2019 09:30:01 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8A8U0F054919172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 10 Sep 2019 08:30:00 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3000552054;
	Tue, 10 Sep 2019 08:30:00 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.35.217])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id F13E952050;
	Tue, 10 Sep 2019 08:29:57 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>,
        Paul Mackerras <paulus@ozlabs.org>
Subject: [PATCH v8 4/8] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
Date: Tue, 10 Sep 2019 13:59:42 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190910082946.7849-1-bharata@linux.ibm.com>
References: <20190910082946.7849-1-bharata@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091008-0028-0000-0000-0000039A6389
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091008-0029-0000-0000-0000245CC5DC
Message-Id: <20190910082946.7849-5-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-10_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909100085
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

H_SVM_INIT_START: Initiate securing a VM
H_SVM_INIT_DONE: Conclude securing a VM

As part of H_SVM_INIT_START, register all existing memslots with
the UV. H_SVM_INIT_DONE call by UV informs HV that transition of
the guest to secure mode is complete.

These two states (transition to secure mode STARTED and transition
to secure mode COMPLETED) are recorded in kvm->arch.secure_guest.
Setting these states will cause the assembly code that enters the
guest to call the UV_RETURN ucall instead of trying to enter the
guest directly.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
Acked-by: Paul Mackerras <paulus@ozlabs.org>
---
 arch/powerpc/include/asm/hvcall.h           |  2 ++
 arch/powerpc/include/asm/kvm_book3s_uvmem.h | 12 ++++++++
 arch/powerpc/include/asm/kvm_host.h         |  4 +++
 arch/powerpc/include/asm/ultravisor-api.h   |  1 +
 arch/powerpc/include/asm/ultravisor.h       |  7 +++++
 arch/powerpc/kvm/book3s_hv.c                |  7 +++++
 arch/powerpc/kvm/book3s_hv_uvmem.c          | 34 +++++++++++++++++++++
 7 files changed, 67 insertions(+)

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm=
/hvcall.h
index 4e98dd992bd1..13bd870609c3 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -348,6 +348,8 @@
 /* Platform-specific hcalls used by the Ultravisor */
 #define H_SVM_PAGE_IN		0xEF00
 #define H_SVM_PAGE_OUT		0xEF04
+#define H_SVM_INIT_START	0xEF08
+#define H_SVM_INIT_DONE		0xEF0C
=20
 /* Values for 2nd argument to H_SET_MODE */
 #define H_SET_MODE_RESOURCE_SET_CIABR		1
diff --git a/arch/powerpc/include/asm/kvm_book3s_uvmem.h b/arch/powerpc/i=
nclude/asm/kvm_book3s_uvmem.h
index 9603c2b48d67..fc924ef00b91 100644
--- a/arch/powerpc/include/asm/kvm_book3s_uvmem.h
+++ b/arch/powerpc/include/asm/kvm_book3s_uvmem.h
@@ -11,6 +11,8 @@ unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
 				    unsigned long gra,
 				    unsigned long flags,
 				    unsigned long page_shift);
+unsigned long kvmppc_h_svm_init_start(struct kvm *kvm);
+unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
 #else
 static inline unsigned long
 kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gra,
@@ -25,5 +27,15 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long g=
ra,
 {
 	return H_UNSUPPORTED;
 }
+
+static inline unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
+{
+	return H_UNSUPPORTED;
+}
+
+static inline unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
+{
+	return H_UNSUPPORTED;
+}
 #endif /* CONFIG_PPC_UV */
 #endif /* __POWERPC_KVM_PPC_HMM_H__ */
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/a=
sm/kvm_host.h
index 16633ad3be45..cab3099db8d4 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -281,6 +281,10 @@ struct kvm_hpt_info {
=20
 struct kvm_resize_hpt;
=20
+/* Flag values for kvm_arch.secure_guest */
+#define KVMPPC_SECURE_INIT_START 0x1 /* H_SVM_INIT_START has been called=
 */
+#define KVMPPC_SECURE_INIT_DONE  0x2 /* H_SVM_INIT_DONE completed */
+
 struct kvm_arch {
 	unsigned int lpid;
 	unsigned int smt_mode;		/* # vcpus per virtual core */
diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/inc=
lude/asm/ultravisor-api.h
index 1cd1f595fd81..c578d9b13a56 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -25,6 +25,7 @@
 /* opcodes */
 #define UV_WRITE_PATE			0xF104
 #define UV_RETURN			0xF11C
+#define UV_REGISTER_MEM_SLOT		0xF120
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
=20
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include=
/asm/ultravisor.h
index 0fc4a974b2e8..58ccf5e2d6bb 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -45,4 +45,11 @@ static inline int uv_page_out(u64 lpid, u64 dst_ra, u6=
4 src_gpa, u64 flags,
 			    page_shift);
 }
=20
+static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size=
,
+				       u64 flags, u64 slotid)
+{
+	return ucall_norets(UV_REGISTER_MEM_SLOT, lpid, start_gpa,
+			    size, flags, slotid);
+}
+
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index c5404db8f0cd..2527f1676b59 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1089,6 +1089,13 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
 					    kvmppc_get_gpr(vcpu, 5),
 					    kvmppc_get_gpr(vcpu, 6));
 		break;
+	case H_SVM_INIT_START:
+		ret =3D kvmppc_h_svm_init_start(vcpu->kvm);
+		break;
+	case H_SVM_INIT_DONE:
+		ret =3D kvmppc_h_svm_init_done(vcpu->kvm);
+		break;
+
 	default:
 		return RESUME_HOST;
 	}
diff --git a/arch/powerpc/kvm/book3s_hv_uvmem.c b/arch/powerpc/kvm/book3s=
_hv_uvmem.c
index bcecb643a730..68a00df1ed79 100644
--- a/arch/powerpc/kvm/book3s_hv_uvmem.c
+++ b/arch/powerpc/kvm/book3s_hv_uvmem.c
@@ -49,6 +49,40 @@ struct kvmppc_uvmem_page_pvt {
 	bool skip_page_out;
 };
=20
+unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
+{
+	struct kvm_memslots *slots;
+	struct kvm_memory_slot *memslot;
+	int ret =3D H_SUCCESS;
+	int srcu_idx;
+
+	srcu_idx =3D srcu_read_lock(&kvm->srcu);
+	slots =3D kvm_memslots(kvm);
+	kvm_for_each_memslot(memslot, slots) {
+		ret =3D uv_register_mem_slot(kvm->arch.lpid,
+					   memslot->base_gfn << PAGE_SHIFT,
+					   memslot->npages * PAGE_SIZE,
+					   0, memslot->id);
+		if (ret < 0) {
+			ret =3D H_PARAMETER;
+			goto out;
+		}
+	}
+	kvm->arch.secure_guest |=3D KVMPPC_SECURE_INIT_START;
+out:
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	return ret;
+}
+
+unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
+{
+	if (!(kvm->arch.secure_guest & KVMPPC_SECURE_INIT_START))
+		return H_UNSUPPORTED;
+
+	kvm->arch.secure_guest |=3D KVMPPC_SECURE_INIT_DONE;
+	return H_SUCCESS;
+}
+
 /*
  * Get a free device PFN from the pool
  *
--=20
2.21.0


