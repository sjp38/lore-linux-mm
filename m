Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02E78C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:46:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 683B7207E0
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 15:46:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 683B7207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 431B66B026F; Thu,  5 Sep 2019 11:46:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E1D56B0270; Thu,  5 Sep 2019 11:46:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F98E6B0272; Thu,  5 Sep 2019 11:46:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id 0F81C6B026F
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:46:40 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 682EA2DFB
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:46:39 +0000 (UTC)
X-FDA: 75901294518.28.wheel39_3a086d9eb9903
X-HE-Tag: wheel39_3a086d9eb9903
X-Filterd-Recvd-Size: 10852
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:46:38 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x85Fd1l6033194;
	Thu, 5 Sep 2019 11:46:31 -0400
Received: from ppma02dal.us.ibm.com (a.bd.3ea9.ip4.static.sl-reverse.com [169.62.189.10])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uu3mdcysg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 05 Sep 2019 11:46:31 -0400
Received: from pps.filterd (ppma02dal.us.ibm.com [127.0.0.1])
	by ppma02dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x85Fjgo4018754;
	Thu, 5 Sep 2019 15:46:30 GMT
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by ppma02dal.us.ibm.com with ESMTP id 2uqgh7jw83-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 05 Sep 2019 15:46:30 +0000
Received: from b03ledav002.gho.boulder.ibm.com (b03ledav002.gho.boulder.ibm.com [9.17.130.233])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x85FkTWr53805538
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 5 Sep 2019 15:46:29 GMT
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6172C136051;
	Thu,  5 Sep 2019 15:46:29 +0000 (GMT)
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7B30F13604F;
	Thu,  5 Sep 2019 15:46:27 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.35.243])
	by b03ledav002.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu,  5 Sep 2019 15:46:27 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v9 7/7] libnvdimm/dax: Pick the right alignment default when creating dax devices
Date: Thu,  5 Sep 2019 21:16:03 +0530
Message-Id: <20190905154603.10349-8-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190905154603.10349-1-aneesh.kumar@linux.ibm.com>
References: <20190905154603.10349-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-05_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909050147
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

Cc: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/nd.h       |  6 +---
 drivers/nvdimm/pfn_devs.c | 75 ++++++++++++++++++++++++++++-----------
 include/linux/huge_mm.h   |  7 +++-
 3 files changed, 61 insertions(+), 27 deletions(-)

diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index e89af4b2d8e9..ee5c04070ef9 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -289,11 +289,7 @@ static inline struct device *nd_btt_create(struct nd=
_region *nd_region)
 struct nd_pfn *to_nd_pfn(struct device *dev);
 #if IS_ENABLED(CONFIG_NVDIMM_PFN)
=20
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define PFN_DEFAULT_ALIGNMENT HPAGE_PMD_SIZE
-#else
-#define PFN_DEFAULT_ALIGNMENT PAGE_SIZE
-#endif
+#define MAX_NVDIMM_ALIGN	4
=20
 int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns);
 bool is_nd_pfn(struct device *dev);
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index ce9ef18282dd..934cdcaaae97 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -103,39 +103,42 @@ static ssize_t align_show(struct device *dev,
 	return sprintf(buf, "%ld\n", nd_pfn->align);
 }
=20
-static const unsigned long *nd_pfn_supported_alignments(void)
+static unsigned long *nd_pfn_supported_alignments(unsigned long *alignme=
nts)
 {
-	/*
-	 * This needs to be a non-static variable because the *_SIZE
-	 * macros aren't always constants.
-	 */
-	const unsigned long supported_alignments[] =3D {
-		PAGE_SIZE,
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		HPAGE_PMD_SIZE,
-#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
-		HPAGE_PUD_SIZE,
-#endif
-#endif
-		0,
-	};
-	static unsigned long data[ARRAY_SIZE(supported_alignments)];
=20
-	memcpy(data, supported_alignments, sizeof(data));
+	alignments[0] =3D PAGE_SIZE;
+
+	if (has_transparent_hugepage()) {
+		alignments[1] =3D HPAGE_PMD_SIZE;
+		if (IS_ENABLED(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD))
+			alignments[2] =3D HPAGE_PUD_SIZE;
+	}
+
+	return alignments;
+}
+
+/*
+ * Use pmd mapping if supported as default alignment
+ */
+static unsigned long nd_pfn_default_alignment(void)
+{
=20
-	return data;
+	if (has_transparent_hugepage())
+		return HPAGE_PMD_SIZE;
+	return PAGE_SIZE;
 }
=20
 static ssize_t align_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
 	struct nd_pfn *nd_pfn =3D to_nd_pfn_safe(dev);
+	unsigned long aligns[MAX_NVDIMM_ALIGN] =3D { [0] =3D 0, };
 	ssize_t rc;
=20
 	nd_device_lock(dev);
 	nvdimm_bus_lock(dev);
 	rc =3D nd_size_select_store(dev, buf, &nd_pfn->align,
-			nd_pfn_supported_alignments());
+			nd_pfn_supported_alignments(aligns));
 	dev_dbg(dev, "result: %zd wrote: %s%s", rc, buf,
 			buf[len - 1] =3D=3D '\n' ? "" : "\n");
 	nvdimm_bus_unlock(dev);
@@ -259,7 +262,10 @@ static DEVICE_ATTR_RO(size);
 static ssize_t supported_alignments_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	return nd_size_select_show(0, nd_pfn_supported_alignments(), buf);
+	unsigned long aligns[MAX_NVDIMM_ALIGN] =3D { [0] =3D 0, };
+
+	return nd_size_select_show(0,
+			nd_pfn_supported_alignments(aligns), buf);
 }
 static DEVICE_ATTR_RO(supported_alignments);
=20
@@ -302,7 +308,7 @@ struct device *nd_pfn_devinit(struct nd_pfn *nd_pfn,
 		return NULL;
=20
 	nd_pfn->mode =3D PFN_MODE_NONE;
-	nd_pfn->align =3D PFN_DEFAULT_ALIGNMENT;
+	nd_pfn->align =3D nd_pfn_default_alignment();
 	dev =3D &nd_pfn->dev;
 	device_initialize(&nd_pfn->dev);
 	if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
@@ -412,6 +418,21 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn =
*nd_pfn)
 	return 0;
 }
=20
+static bool nd_supported_alignment(unsigned long align)
+{
+	int i;
+	unsigned long supported[MAX_NVDIMM_ALIGN] =3D { [0] =3D 0, };
+
+	if (align =3D=3D 0)
+		return false;
+
+	nd_pfn_supported_alignments(supported);
+	for (i =3D 0; supported[i]; i++)
+		if (align =3D=3D supported[i])
+			return true;
+	return false;
+}
+
 /**
  * nd_pfn_validate - read and validate info-block
  * @nd_pfn: fsdax namespace runtime state / properties
@@ -496,6 +517,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const cha=
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
index 45ede62aa85b..376a81ff2c96 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -108,7 +108,12 @@ static inline bool __transparent_hugepage_enabled(st=
ruct vm_area_struct *vma)
=20
 	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
 		return true;
-
+	/*
+	 * For dax vmas, try to always use hugepage mappings. If the kernel doe=
s
+	 * not support hugepages, fsdax mappings will fallback to PAGE_SIZE
+	 * mappings, and device-dax namespaces, that try to guarantee a given
+	 * mapping size, will fail to enable
+	 */
 	if (vma_is_dax(vma))
 		return true;
=20
--=20
2.21.0


