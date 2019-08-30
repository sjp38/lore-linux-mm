Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10388C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0C2021897
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0C2021897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B6D56B0008; Fri, 30 Aug 2019 08:07:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EFF86B000A; Fri, 30 Aug 2019 08:07:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794036B000C; Fri, 30 Aug 2019 08:07:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0004.hostedemail.com [216.40.44.4])
	by kanga.kvack.org (Postfix) with ESMTP id 54D8A6B0008
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:25 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 053B2180AD7C1
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:25 +0000 (UTC)
X-FDA: 75878969250.18.crown05_7adeaf45f7a4c
X-HE-Tag: crown05_7adeaf45f7a4c
X-Filterd-Recvd-Size: 4803
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:24 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7UC3Xns042856
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:23 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uq364gykw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:22 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 30 Aug 2019 13:07:20 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 30 Aug 2019 13:07:17 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7UC7F0Z60686574
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 12:07:15 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 64B1842041;
	Fri, 30 Aug 2019 12:07:15 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 991B14204B;
	Fri, 30 Aug 2019 12:07:14 +0000 (GMT)
Received: from pomme.com (unknown [9.145.17.35])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 30 Aug 2019 12:07:14 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org,
        aneesh.kumar@linux.ibm.com, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] powerpc/mm: Initialize the HPTE encoding values
Date: Fri, 30 Aug 2019 14:07:10 +0200
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190830120712.22971-1-ldufour@linux.ibm.com>
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19083012-0012-0000-0000-00000344A064
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19083012-0013-0000-0000-0000217EE443
Message-Id: <20190830120712.22971-2-ldufour@linux.ibm.com>
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

Before reading the HPTE encoding values we initialize all of them to -1 (=
an
invalid value) to later being able to detect the initialized ones.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/powerpc/mm/book3s64/hash_utils.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/book3s64/hash_utils.c b/arch/powerpc/mm/book=
3s64/hash_utils.c
index c3bfef08dcf8..2039bc315459 100644
--- a/arch/powerpc/mm/book3s64/hash_utils.c
+++ b/arch/powerpc/mm/book3s64/hash_utils.c
@@ -408,7 +408,7 @@ static int __init htab_dt_scan_page_sizes(unsigned lo=
ng node,
 {
 	const char *type =3D of_get_flat_dt_prop(node, "device_type", NULL);
 	const __be32 *prop;
-	int size =3D 0;
+	int size =3D 0, idx, base_idx;
=20
 	/* We are scanning "cpu" nodes only */
 	if (type =3D=3D NULL || strcmp(type, "cpu") !=3D 0)
@@ -418,6 +418,11 @@ static int __init htab_dt_scan_page_sizes(unsigned l=
ong node,
 	if (!prop)
 		return 0;
=20
+	/* Set all the penc values to invalid */
+	for (base_idx =3D 0; base_idx < MMU_PAGE_COUNT; base_idx++)
+		for (idx =3D 0; idx < MMU_PAGE_COUNT; idx++)
+			mmu_psize_defs[base_idx].penc[idx] =3D -1;
+
 	pr_info("Page sizes from device-tree:\n");
 	size /=3D 4;
 	cur_cpu_spec->mmu_features &=3D ~(MMU_FTR_16M_PAGE);
@@ -426,7 +431,6 @@ static int __init htab_dt_scan_page_sizes(unsigned lo=
ng node,
 		unsigned int slbenc =3D be32_to_cpu(prop[1]);
 		unsigned int lpnum =3D be32_to_cpu(prop[2]);
 		struct mmu_psize_def *def;
-		int idx, base_idx;
=20
 		size -=3D 3; prop +=3D 3;
 		base_idx =3D get_idx_from_shift(base_shift);
--=20
2.23.0


