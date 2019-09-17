Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25119C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3C32206C2
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3C32206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61D4E6B0006; Tue, 17 Sep 2019 11:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CAB36B0008; Tue, 17 Sep 2019 11:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BA206B000A; Tue, 17 Sep 2019 11:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6C96B0006
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:31:46 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BF850181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:31:45 +0000 (UTC)
X-FDA: 75944802570.28.soap50_2c6962b762d53
X-HE-Tag: soap50_2c6962b762d53
X-Filterd-Recvd-Size: 3982
Received: from mx0b-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:31:45 +0000 (UTC)
Received: from pps.filterd (m0127361.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8HFMYUB172692;
	Tue, 17 Sep 2019 11:31:43 -0400
Received: from ppma03wdc.us.ibm.com (ba.79.3fa9.ip4.static.sl-reverse.com [169.63.121.186])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2v30fsccvc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 17 Sep 2019 11:31:41 -0400
Received: from pps.filterd (ppma03wdc.us.ibm.com [127.0.0.1])
	by ppma03wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x8HFPhnc018654;
	Tue, 17 Sep 2019 15:31:37 GMT
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by ppma03wdc.us.ibm.com with ESMTP id 2v0t3d9r6u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 17 Sep 2019 15:31:37 +0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8HFVaL054460834
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 17 Sep 2019 15:31:36 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D8B93AE060;
	Tue, 17 Sep 2019 15:31:36 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2796CAE063;
	Tue, 17 Sep 2019 15:31:35 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.41.201])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue, 17 Sep 2019 15:31:34 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v6] mm/pgmap: Use correct alignment when looking at first pfn from a region
Date: Tue, 17 Sep 2019 21:01:29 +0530
Message-Id: <20190917153129.12905-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-17_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=900 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909170149
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmem_altmap_offset() adjust the section aligned base_pfn offset.
So we need to make sure we account for the same when computing base_pfn.

ie, for altmap_valid case, our pfn_first should be:

pfn_first =3D altmap->base_pfn + vmem_altmap_offset(altmap);

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
* changes from v5
* update commit subject and use linux-mm for merge

 mm/memremap.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/memremap.c b/mm/memremap.c
index ed70c4e8e52a..233908d7df75 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -54,8 +54,16 @@ static void pgmap_array_delete(struct resource *res)
=20
 static unsigned long pfn_first(struct dev_pagemap *pgmap)
 {
-	return PHYS_PFN(pgmap->res.start) +
-		vmem_altmap_offset(pgmap_altmap(pgmap));
+	const struct resource *res =3D &pgmap->res;
+	struct vmem_altmap *altmap =3D pgmap_altmap(pgmap);
+	unsigned long pfn;
+
+	if (altmap) {
+		pfn =3D altmap->base_pfn + vmem_altmap_offset(altmap);
+	} else
+		pfn =3D PHYS_PFN(res->start);
+
+	return pfn;
 }
=20
 static unsigned long pfn_end(struct dev_pagemap *pgmap)
--=20
2.21.0


