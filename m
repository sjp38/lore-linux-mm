Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8788DC3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:53:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 484BD22CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:53:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 484BD22CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2C506B0003; Wed,  4 Sep 2019 02:53:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDD876B0006; Wed,  4 Sep 2019 02:53:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCB836B0007; Wed,  4 Sep 2019 02:53:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 955D26B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:53:36 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1DDC3180AD802
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:53:36 +0000 (UTC)
X-FDA: 75896322432.29.sense23_242717702c29
X-HE-Tag: sense23_242717702c29
X-Filterd-Recvd-Size: 9818
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:53:35 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x846q7ev110053;
	Wed, 4 Sep 2019 02:53:33 -0400
Received: from ppma05wdc.us.ibm.com (1b.90.2fa9.ip4.static.sl-reverse.com [169.47.144.27])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ut7xagvm2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 04 Sep 2019 02:53:33 -0400
Received: from pps.filterd (ppma05wdc.us.ibm.com [127.0.0.1])
	by ppma05wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x846nh3h016238;
	Wed, 4 Sep 2019 06:53:30 GMT
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by ppma05wdc.us.ibm.com with ESMTP id 2usa0m9708-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 04 Sep 2019 06:53:30 +0000
Received: from b01ledav002.gho.pok.ibm.com (b01ledav002.gho.pok.ibm.com [9.57.199.107])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x846rUYq14156540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 4 Sep 2019 06:53:30 GMT
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 12263124058;
	Wed,  4 Sep 2019 06:53:30 +0000 (GMT)
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 67581124053;
	Wed,  4 Sep 2019 06:53:28 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.33.228])
	by b01ledav002.gho.pok.ibm.com (Postfix) with ESMTP;
	Wed,  4 Sep 2019 06:53:28 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v8] libnvdimm/dax: Pick the right alignment default when creating dax devices
Date: Wed,  4 Sep 2019 12:23:20 +0530
Message-Id: <20190904065320.6005-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-04_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909040070
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allow arch to provide the supported alignments and use hugepage alignment=
 only
if we support hugepage. Right now we depend on compile time configs where=
as this
patch switch this to runtime discovery.

Architectures like ppc64 can have THP enabled in code, but then can have
hugepage size disabled by the hypervisor. This allows us to create dax de=
vices
with PAGE_SIZE alignment in this case.

Existing dax namespace with alignment larger than PAGE_SIZE will fail to
initialize in this specific case. We still allow fsdax namespace initiali=
zation.

With respect to identifying whether to enable hugepage fault for a dax de=
vice,
if THP is enabled during compile, we default to taking hugepage fault and=
 in dax
fault handler if we find the fault size > alignment we retry with PAGE_SI=
ZE
fault size.

This also addresses the below failure scenario on ppc64

ndctl create-namespace --mode=3Ddevdax  | grep align
 "align":16777216,
 "align":16777216

cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
 65536 16777216

daxio.static-debug  -z -o /dev/dax0.0
  Bus error (core dumped)

  $ dmesg | tail
   lpar: Failed hash pte insert with error -4
   hash-mmu: mm: Hashing failure ! EA=3D0x7fff17000000 access=3D0x8000000=
000000006 current=3Ddaxio
   hash-mmu:     trap=3D0x300 vsid=3D0x22cb7a3 ssize=3D1 base psize=3D2 p=
size 10 pte=3D0xc000000501002b86
   daxio[3860]: bus error (7) at 7fff17000000 nip 7fff973c007c lr 7fff973=
bff34 code 2 in libpmem.so.1.0.0[7fff973b0000+20000]
   daxio[3860]: code: 792945e4 7d494b78 e95f0098 7d494b78 f93f00a0 480001=
2c e93f0088 f93f0120
   daxio[3860]: code: e93f00a0 f93f0128 e93f0120 e95f0128 <f9490000> e93f=
0088 39290008 f93f0110

The failure was due to guest kernel using wrong page size.

The namespaces created with 16M alignment will appear as below on a confi=
g with
16M page size disabled.

$ ndctl list -Ni
[
  {
    "dev":"namespace0.1",
    "mode":"fsdax",
    "map":"dev",
    "size":5351931904,
    "uuid":"fc6e9667-461a-4718-82b4-69b24570bddb",
    "align":16777216,
    "blockdev":"pmem0.1",
    "supported_alignments":[
      65536
    ]
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",    <=3D=3D=3D=3D devdax 16M alignment marked disabled=
.
    "map":"mem",
    "size":5368709120,
    "uuid":"a4bdf81a-f2ee-4bc6-91db-7b87eddd0484",
    "state":"disabled"
  }
]

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/nd.h       |  6 ----
 drivers/nvdimm/pfn_devs.c | 69 +++++++++++++++++++++++++++++----------
 include/linux/huge_mm.h   |  8 ++++-
 3 files changed, 59 insertions(+), 24 deletions(-)

diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index e89af4b2d8e9..401a78b02116 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -289,12 +289,6 @@ static inline struct device *nd_btt_create(struct nd=
_region *nd_region)
 struct nd_pfn *to_nd_pfn(struct device *dev);
 #if IS_ENABLED(CONFIG_NVDIMM_PFN)
=20
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define PFN_DEFAULT_ALIGNMENT HPAGE_PMD_SIZE
-#else
-#define PFN_DEFAULT_ALIGNMENT PAGE_SIZE
-#endif
-
 int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns);
 bool is_nd_pfn(struct device *dev);
 struct device *nd_pfn_create(struct nd_region *nd_region);
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index ce9ef18282dd..4cb240b3d5b0 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -103,27 +103,36 @@ static ssize_t align_show(struct device *dev,
 	return sprintf(buf, "%ld\n", nd_pfn->align);
 }
=20
-static const unsigned long *nd_pfn_supported_alignments(void)
+const unsigned long *nd_pfn_supported_alignments(void)
 {
-	/*
-	 * This needs to be a non-static variable because the *_SIZE
-	 * macros aren't always constants.
-	 */
-	const unsigned long supported_alignments[] =3D {
-		PAGE_SIZE,
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		HPAGE_PMD_SIZE,
+	static unsigned long supported_alignments[3];
+
+	supported_alignments[0] =3D PAGE_SIZE;
+
+	if (has_transparent_hugepage()) {
+
+		supported_alignments[1] =3D HPAGE_PMD_SIZE;
+
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
-		HPAGE_PUD_SIZE,
-#endif
+		supported_alignments[2] =3D HPAGE_PUD_SIZE;
 #endif
-		0,
-	};
-	static unsigned long data[ARRAY_SIZE(supported_alignments)];
+	} else {
+		supported_alignments[1] =3D 0;
+		supported_alignments[2] =3D 0;
+	}
=20
-	memcpy(data, supported_alignments, sizeof(data));
+	return supported_alignments;
+}
+
+/*
+ * Use pmd mapping if supported as default alignment
+ */
+unsigned long nd_pfn_default_alignment(void)
+{
=20
-	return data;
+	if (has_transparent_hugepage())
+		return HPAGE_PMD_SIZE;
+	return PAGE_SIZE;
 }
=20
 static ssize_t align_store(struct device *dev,
@@ -302,7 +311,7 @@ struct device *nd_pfn_devinit(struct nd_pfn *nd_pfn,
 		return NULL;
=20
 	nd_pfn->mode =3D PFN_MODE_NONE;
-	nd_pfn->align =3D PFN_DEFAULT_ALIGNMENT;
+	nd_pfn->align =3D nd_pfn_default_alignment();
 	dev =3D &nd_pfn->dev;
 	device_initialize(&nd_pfn->dev);
 	if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
@@ -412,6 +421,20 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn =
*nd_pfn)
 	return 0;
 }
=20
+static bool nd_supported_alignment(unsigned long align)
+{
+	int i;
+	const unsigned long *supported =3D nd_pfn_supported_alignments();
+
+	if (align =3D=3D 0)
+		return false;
+
+	for (i =3D 0; supported[i]; i++)
+		if (align =3D=3D supported[i])
+			return true;
+	return false;
+}
+
 /**
  * nd_pfn_validate - read and validate info-block
  * @nd_pfn: fsdax namespace runtime state / properties
@@ -496,6 +519,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const cha=
r *sig)
 		return -EOPNOTSUPP;
 	}
=20
+	/*
+	 * Check whether the we support the alignment. For Dax if the
+	 * superblock alignment is not matching, we won't initialize
+	 * the device.
+	 */
+	if (!nd_supported_alignment(align) &&
+			!memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
+		dev_err(&nd_pfn->dev, "init failed, alignment mismatch: "
+				"%ld:%ld\n", nd_pfn->align, align);
+		return -EOPNOTSUPP;
+	}
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 45ede62aa85b..36708c43ef8e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -108,7 +108,13 @@ static inline bool __transparent_hugepage_enabled(st=
ruct vm_area_struct *vma)
=20
 	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
 		return true;
-
+	/*
+	 * For dax let's try to do hugepage fault always. If the kernel doesn't
+	 * support hugepages, namespaces with hugepage alignment will not be
+	 * enabled. For namespace with PAGE_SIZE alignment, we try to handle
+	 * hugepage fault but will fallback to PAGE_SIZE via the check in
+	 * __dev_dax_pmd_fault
+	 */
 	if (vma_is_dax(vma))
 		return true;
=20
--=20
2.21.0


