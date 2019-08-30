Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5974C3A5A7
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3FB821897
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3FB821897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3E196B000A; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DB2C6B000D; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C8526B000E; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD306B000A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0FF611F845
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:26 +0000 (UTC)
X-FDA: 75878969292.26.women80_7b096f2962f2f
X-HE-Tag: women80_7b096f2962f2f
X-Filterd-Recvd-Size: 8449
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:25 +0000 (UTC)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7UC36FG030331
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:24 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uq3f786ma-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:23 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 30 Aug 2019 13:07:21 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 30 Aug 2019 13:07:18 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7UC7GE250987220
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 12:07:16 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4597242041;
	Fri, 30 Aug 2019 12:07:16 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7FE3342042;
	Fri, 30 Aug 2019 12:07:15 +0000 (GMT)
Received: from pomme.com (unknown [9.145.17.35])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 30 Aug 2019 12:07:15 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org,
        aneesh.kumar@linux.ibm.com, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] powperc/mm: read TLB Block Invalidate Characteristics
Date: Fri, 30 Aug 2019 14:07:11 +0200
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190830120712.22971-1-ldufour@linux.ibm.com>
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19083012-0016-0000-0000-000002A4A2DD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19083012-0017-0000-0000-00003304FD2F
Message-Id: <20190830120712.22971-3-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908300132
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The PAPR document specifies the TLB Block Invalidate Characteristics whic=
h
is telling which couple base page size / page size is supported by the
H_BLOCK_REMOVE hcall.

A new set of feature is added to the mmu_psize_def structure to record pe=
r
base page size which page size is supported by H_BLOCK_REMOVE.

A new init service is added to read the characteristics. The size of the
buffer is set to twice the number of known page size, plus 10 bytes to
ensure we have enough place.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu.h |   3 +
 arch/powerpc/platforms/pseries/lpar.c    | 107 +++++++++++++++++++++++
 2 files changed, 110 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/incl=
ude/asm/book3s/64/mmu.h
index 23b83d3593e2..675895dfe39f 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu.h
@@ -12,11 +12,14 @@
  *    sllp  : is a bit mask with the value of SLB L || LP to be or'ed
  *            directly to a slbmte "vsid" value
  *    penc  : is the HPTE encoding mask for the "LP" field:
+ *    hblk  : H_BLOCK_REMOVE supported block size for this page size in
+ *            segment who's base page size is that page size.
  *
  */
 struct mmu_psize_def {
 	unsigned int	shift;	/* number of bits */
 	int		penc[MMU_PAGE_COUNT];	/* HPTE encoding */
+	int		hblk[MMU_PAGE_COUNT];	/* H_BLOCK_REMOVE support */
 	unsigned int	tlbiel;	/* tlbiel supported for that page size */
 	unsigned long	avpnm;	/* bits to mask out in AVPN in the HPTE */
 	union {
diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platfor=
ms/pseries/lpar.c
index 4f76e5f30c97..375e19b3cf53 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -1311,6 +1311,113 @@ static void do_block_remove(unsigned long number,=
 struct ppc64_tlb_batch *batch,
 		(void)call_block_remove(pix, param, true);
 }
=20
+static inline void __init set_hblk_bloc_size(int bpsize, int psize,
+					     unsigned int block_size)
+{
+	struct mmu_psize_def *def =3D &mmu_psize_defs[bpsize];
+
+	if (block_size > def->hblk[psize])
+		def->hblk[psize] =3D block_size;
+}
+
+static inline void __init check_lp_set_hblk(unsigned int lp,
+					    unsigned int block_size)
+{
+	unsigned int bpsize, psize;
+
+
+	/* First, check the L bit, if not set, this means 4K */
+	if ((lp & 0x80) =3D=3D 0) {
+		set_hblk_bloc_size(MMU_PAGE_4K, MMU_PAGE_4K, block_size);
+		return;
+	}
+
+	/* PAPR says to look at bits 2-7 (0 =3D MSB) */
+	lp &=3D 0x3f;
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
+static int __init read_tlbbi_characteristics(void)
+{
+	int call_status;
+	unsigned char local_buffer[SPLPAR_TLB_BIC_MAXLENGTH];
+	int len, idx, bpsize;
+
+	if (!firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)) {
+		pr_info("H_BLOCK_REMOVE is not supported");
+		return 0;
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
+		return 0;
+	}
+
+	/*
+	 * The first two (2) bytes of the data in the buffer are the length of
+	 * the returned data, not counting these first two (2) bytes.
+	 */
+	len =3D local_buffer[0] * 256 + local_buffer[1] + 2;
+	if (len >=3D SPLPAR_TLB_BIC_MAXLENGTH) {
+		pr_warn("%s too large returned buffer %d", __func__, len);
+		return 0;
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
+		if (block_size !=3D 8)
+			/* We only support 8 bytes size TLB invalidate buffer */
+			pr_warn("Unsupported H_BLOCK_REMOVE block size : %d\n",
+				block_size);
+
+		for (npsize =3D local_buffer[idx++];  npsize > 0; npsize--)
+			check_lp_set_hblk((unsigned int) local_buffer[idx++],
+					  block_size);
+	}
+
+	for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsize++)
+		for (idx =3D 0; idx < MMU_PAGE_COUNT; idx++)
+			if (mmu_psize_defs[bpsize].hblk[idx])
+				pr_info("H_BLOCK_REMOVE supports base psize:%d psize:%d block size:%=
d",
+					bpsize, idx,
+					mmu_psize_defs[bpsize].hblk[idx]);
+
+	return 0;
+}
+machine_arch_initcall(pseries, read_tlbbi_characteristics);
+
 /*
  * Take a spinlock around flushes to avoid bouncing the hypervisor tlbie
  * lock.
--=20
2.23.0


