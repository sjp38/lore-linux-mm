Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83AAEC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:57:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37D3A206A4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:57:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37D3A206A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DDA26B0006; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 866F46B0007; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72EA36B0008; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id 51CEC6B0007
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 05013180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:57:26 +0000 (UTC)
X-FDA: 75940331292.29.love87_7b0e69517a037
X-HE-Tag: love87_7b0e69517a037
X-Filterd-Recvd-Size: 10418
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:57:25 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8G9qgZL063204
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:57:24 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v282p09sb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:57:24 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Mon, 16 Sep 2019 10:57:22 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 16 Sep 2019 10:57:19 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8G9vHV948693316
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 09:57:18 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D775F4C046;
	Mon, 16 Sep 2019 09:57:17 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 142274C040;
	Mon, 16 Sep 2019 09:57:17 +0000 (GMT)
Received: from pomme.com (unknown [9.145.76.175])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 16 Sep 2019 09:57:16 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org,
        aneesh.kumar@linux.ibm.com, npiggin@gmail.com,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/2] powperc/mm: read TLB Block Invalidate Characteristics
Date: Mon, 16 Sep 2019 11:55:42 +0200
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190916095543.17496-1-ldufour@linux.ibm.com>
References: <20190916095543.17496-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091609-0016-0000-0000-000002AC848B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091609-0017-0000-0000-0000330D21F2
Message-Id: <20190916095543.17496-2-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909160105
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The PAPR document specifies the TLB Block Invalidate Characteristics whic=
h
tells for each couple segment base page size, actual page size, the size =
of
the block the hcall H_BLOCK_REMOVE is supporting.

These characteristics are loaded at boot time in a new table hblkr_size.
The table is appart the mmu_psize_def because this is specific to the
pseries architecture.

A new init service, pseries_lpar_read_hblkr_characteristics() is added to
read the characteristics. In that function, the size of the buffer is set
to twice the number of known page size, plus 10 bytes to ensure we have
enough place. This new init function is called from pSeries_setup_arch().

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 .../include/asm/book3s/64/tlbflush-hash.h     |   1 +
 arch/powerpc/platforms/pseries/lpar.c         | 138 ++++++++++++++++++
 arch/powerpc/platforms/pseries/setup.c        |   1 +
 3 files changed, 140 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h b/arch/po=
werpc/include/asm/book3s/64/tlbflush-hash.h
index 64d02a704bcb..74155cc8cf89 100644
--- a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
@@ -117,4 +117,5 @@ extern void __flush_hash_table_range(struct mm_struct=
 *mm, unsigned long start,
 				     unsigned long end);
 extern void flush_tlb_pmd_range(struct mm_struct *mm, pmd_t *pmd,
 				unsigned long addr);
+extern void pseries_lpar_read_hblkr_characteristics(void);
 #endif /*  _ASM_POWERPC_BOOK3S_64_TLBFLUSH_HASH_H */
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platfor=
ms/pseries/lpar.c
index 36b846f6e74e..98a5c2ff9a0b 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -56,6 +56,15 @@ EXPORT_SYMBOL(plpar_hcall);
 EXPORT_SYMBOL(plpar_hcall9);
 EXPORT_SYMBOL(plpar_hcall_norets);
=20
+/*
+ * H_BLOCK_REMOVE supported block size for this page size in segment who=
's base
+ * page size is that page size.
+ *
+ * The first index is the segment base page size, the second one is the =
actual
+ * page size.
+ */
+static int hblkr_size[MMU_PAGE_COUNT][MMU_PAGE_COUNT];
+
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
 static u8 dtl_mask =3D DTL_LOG_PREEMPT;
 #else
@@ -1311,6 +1320,135 @@ static void do_block_remove(unsigned long number,=
 struct ppc64_tlb_batch *batch,
 		(void)call_block_remove(pix, param, true);
 }
=20
+/*
+ * TLB Block Invalidate Characteristics These characteristics define the=
 size of
+ * the block the hcall H_BLOCK_REMOVE is able to process for each couple=
 segment
+ * base page size, actual page size.
+ *
+ * The ibm,get-system-parameter properties is returning a buffer with th=
e
+ * following layout:
+ *
+ * [ 2 bytes size of the RTAS buffer (without these 2 bytes) ]
+ * -----------------
+ * TLB Block Invalidate Specifiers:
+ * [ 1 byte LOG base 2 of the TLB invalidate block size being specified =
]
+ * [ 1 byte Number of page sizes (N) that are supported for the specifie=
d
+ *          TLB invalidate block size ]
+ * [ 1 byte Encoded segment base page size and actual page size
+ *          MSB=3D0 means 4k segment base page size and actual page size
+ *          MSB=3D1 the penc value in mmu_psize_def ]
+ * ...
+ * -----------------
+ * Next TLB Block Invalidate Specifiers...
+ * -----------------
+ * [ 0 ]
+ */
+static inline void __init set_hblk_bloc_size(int bpsize, int psize,
+					     unsigned int block_size)
+{
+	if (block_size > hblkr_size[bpsize][psize])
+		hblkr_size[bpsize][psize] =3D block_size;
+}
+
+/*
+ * Decode the Encoded segment base page size and actual page size.
+ * PAPR specifies with bit 0 as MSB:
+ *   - bit 0 is the L bit
+ *   - bits 2-7 are the penc value
+ * If the L bit is 0, this means 4K segment base page size and actual pa=
ge size
+ * otherwise the penc value should be readed.
+ */
+#define HBLKR_L_BIT_MASK	0x80
+#define HBLKR_PENC_MASK		0x3f
+static inline void __init check_lp_set_hblk(unsigned int lp,
+					    unsigned int block_size)
+{
+	unsigned int bpsize, psize;
+
+
+	/* First, check the L bit, if not set, this means 4K */
+	if ((lp & HBLKR_L_BIT_MASK) =3D=3D 0) {
+		set_hblk_bloc_size(MMU_PAGE_4K, MMU_PAGE_4K, block_size);
+		return;
+	}
+
+	lp &=3D HBLKR_PENC_MASK;
+	for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsize++) {
+		struct mmu_psize_def *def =3D  &mmu_psize_defs[bpsize];
+
+		for (psize =3D 0; psize < MMU_PAGE_COUNT; psize++) {
+			if (def->penc[psize] =3D=3D lp) {
+				set_hblk_bloc_size(bpsize, psize, block_size);
+				return;
+			}
+		}
+	}
+}
+
+#define SPLPAR_TLB_BIC_TOKEN		50
+#define SPLPAR_TLB_BIC_MAXLENGTH	(MMU_PAGE_COUNT*2 + 10)
+void __init pseries_lpar_read_hblkr_characteristics(void)
+{
+	int call_status;
+	unsigned char local_buffer[SPLPAR_TLB_BIC_MAXLENGTH];
+	int len, idx, bpsize;
+
+	if (!firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)) {
+		pr_info("H_BLOCK_REMOVE is not supported");
+		return;
+	}
+
+	memset(local_buffer, 0, SPLPAR_TLB_BIC_MAXLENGTH);
+
+	spin_lock(&rtas_data_buf_lock);
+	memset(rtas_data_buf, 0, RTAS_DATA_BUF_SIZE);
+	call_status =3D rtas_call(rtas_token("ibm,get-system-parameter"), 3, 1,
+				NULL,
+				SPLPAR_TLB_BIC_TOKEN,
+				__pa(rtas_data_buf),
+				RTAS_DATA_BUF_SIZE);
+	memcpy(local_buffer, rtas_data_buf, SPLPAR_TLB_BIC_MAXLENGTH);
+	local_buffer[SPLPAR_TLB_BIC_MAXLENGTH - 1] =3D '\0';
+	spin_unlock(&rtas_data_buf_lock);
+
+	if (call_status !=3D 0) {
+		pr_warn("%s %s Error calling get-system-parameter (0x%x)\n",
+			__FILE__, __func__, call_status);
+		return;
+	}
+
+	/*
+	 * The first two (2) bytes of the data in the buffer are the length of
+	 * the returned data, not counting these first two (2) bytes.
+	 */
+	len =3D local_buffer[0] * 256 + local_buffer[1] + 2;
+	if (len >=3D SPLPAR_TLB_BIC_MAXLENGTH) {
+		pr_warn("%s too large returned buffer %d", __func__, len);
+		return;
+	}
+
+	idx =3D 2;
+	while (idx < len) {
+		unsigned int block_size =3D local_buffer[idx++];
+		unsigned int npsize;
+
+		if (!block_size)
+			break;
+
+		block_size =3D 1 << block_size;
+
+		for (npsize =3D local_buffer[idx++];  npsize > 0; npsize--)
+			check_lp_set_hblk((unsigned int) local_buffer[idx++],
+					  block_size);
+	}
+
+	for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsize++)
+		for (idx =3D 0; idx < MMU_PAGE_COUNT; idx++)
+			if (hblkr_size[bpsize][idx])
+				pr_info("H_BLOCK_REMOVE supports base psize:%d psize:%d block size:%=
d",
+					bpsize, idx, hblkr_size[bpsize][idx]);
+}
+
 /*
  * Take a spinlock around flushes to avoid bouncing the hypervisor tlbie
  * lock.
diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platfo=
rms/pseries/setup.c
index f8adcd0e4589..015b7ba13ee4 100644
--- a/arch/powerpc/platforms/pseries/setup.c
+++ b/arch/powerpc/platforms/pseries/setup.c
@@ -744,6 +744,7 @@ static void __init pSeries_setup_arch(void)
=20
 	pseries_setup_rfi_flush();
 	setup_stf_barrier();
+	pseries_lpar_read_hblkr_characteristics();
=20
 	/* By default, only probe PCI (can be overridden by rtas_pci) */
 	pci_add_flags(PCI_PROBE_ONLY);
--=20
2.23.0


