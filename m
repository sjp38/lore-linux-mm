Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CD39C072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:27:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF3CB217F9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:27:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF3CB217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 599B06B0007; Wed, 22 May 2019 04:27:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54AB96B0008; Wed, 22 May 2019 04:27:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 439D66B000A; Wed, 22 May 2019 04:27:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 242426B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:27:18 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id y3so1418531ybg.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 01:27:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=X9uBNzC2btm2KmWV6r/+ddlF60lonpFz8lJksHabHHE=;
        b=d+thF0Orp0Xl6OCYeSwM3k24pUbM2xNIMbtJNQdb7VHvmUfVJvxi5F+f5b/CwT5hLp
         8GjUCTMSyNO3Zrch6yHQK/fvTGH5899oojzuOyoHNxFr7UdL2APUwKy0sZeUh8nVbwwk
         iardgns2xV+ZDZRgj0CSjxRXfRvlil3oKmSNCokWiMwpYmRcW16kBEYyycZbHL5moqA2
         aJgWxj+UDUAyrt51s8BCRp3KaNCSVZBHtnolf5OTrwWK09kMQ+Drp+UoduxYkp8EKNPw
         l8Pt77ofdaKfyyFbLSVwr+iR02qzwCnhcDrbftTLWBd0YpdM/CtAq+4HWB4NMg8H/uqy
         zrWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV2Rvn/PCmaSr1HSvI2yp4lA5Xx3Ul3F4lL02Qj4TK/CP3fkJBm
	nq+9B5gbBOd4HJ8BYLrZVlpe4arZP3M3DmTntIxScZ4ZGe5wEoa7NrVdQhdi+ZKy4Xw8gW/OLUe
	aM2pJAF7FSKzPowhwxQOJrkcTGjUIywuIzv/H4Z54F6ABw2BjpLktKDosn6uY2HDHWQ==
X-Received: by 2002:a5b:30a:: with SMTP id j10mr18490275ybp.466.1558513637834;
        Wed, 22 May 2019 01:27:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhGvf1rE7yjvEeOQELiWyhOW0/w64NBOnzSYwVEf/lGxZc0i/HGER0cDUwDdciqf0WEVGI
X-Received: by 2002:a5b:30a:: with SMTP id j10mr18490258ybp.466.1558513636740;
        Wed, 22 May 2019 01:27:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558513636; cv=none;
        d=google.com; s=arc-20160816;
        b=DgvJMU7OcX9TgrmUUkTmfcAg/6ITwQVOjKti/CFCYoNblEWCWlEFYfzrkq7R+nUgNX
         Z6KBfODHnPERnpQP+wVvTor5o/y8LD5IAFuPHnez9efVBOX/tkNorjqTTfAu5ofbd17/
         TVT0Me9rGDR9UN9IP8pgizHKsfWFw9aQmLV8D1dWNPLvw8EUkrASvSmg6yYkaVo0ennG
         /45KgwuHvtGiRCwqgkBdvrNLrjB6BlOWwyFOZsc1QIxui6pDL/ZsAaonOTYOTBUuZXC/
         akSIRuthEW5JOK1mDQWxO5Ws0x8xlGEwJpjjHx+NHOZ7fZ0BjIjLMhhXWnX1xrNPtWow
         Fd1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=X9uBNzC2btm2KmWV6r/+ddlF60lonpFz8lJksHabHHE=;
        b=QbpT7S/U//tHW728OVMVHlE0Kkf5zDf2dSguLHCPUGAUMOB/m5GzQo6TB8utb+Q7UA
         3xGS8Ckmivr4daFSZTGpCILowJn5g5cTj0kQBXiyTInVxSqoq+TuiuzRYZ7wb+exyR1O
         lL5646orcWAnUI3rv0E0t33mTuO7I6scN5UA6edyWBUT6RZ2QqT0THdldnj9pbF2cGSa
         plx4LZu95Z3a7aw5kpuno24fPeFU4eN9QYWv5IbD9aEH4oNkzAE5TlcXHhA8/BGJWS87
         2FkpLvXXymsuK/JgU062lMitUpP43jbH1WKlN3j86J9kExRESd3NIFt/9m3Cr68EReKX
         1GZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n14si6288115ybp.91.2019.05.22.01.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 01:27:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M8RGn1134519
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:27:16 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sn1tpttb1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:27:16 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 09:27:15 +0100
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e33.co.us.ibm.com (192.168.1.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 09:27:12 +0100
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M8RBSF30409194
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 08:27:11 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9DC79C605B;
	Wed, 22 May 2019 08:27:11 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F33B4C6055;
	Wed, 22 May 2019 08:27:09 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.87])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 08:27:09 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH V2 3/3] mm/nvdimm: Use correct #defines instead of opencoding
Date: Wed, 22 May 2019 13:57:01 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
References: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19052208-0036-0000-0000-00000AC1343D
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011141; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01206886; UDB=6.00633780; IPR=6.00987861;
 MB=3.00026999; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-22 08:27:13
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052208-0037-0000-0000-00004BE5854A
Message-Id: <20190522082701.6817-3-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The nfpn related change is needed to fix the kernel message

"number of pfns truncated from 2617344 to 163584"

The change makes sure the nfpns stored in the superblock is right value.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/label.c       | 2 +-
 drivers/nvdimm/pfn_devs.c    | 6 +++---
 drivers/nvdimm/region_devs.c | 8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
index f3d753d3169c..bc6de8fb0153 100644
--- a/drivers/nvdimm/label.c
+++ b/drivers/nvdimm/label.c
@@ -361,7 +361,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
 
 	/* check that DPA allocations are page aligned */
 	if ((__le64_to_cpu(nd_label->dpa)
-				| __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
+				| __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)
 		return false;
 
 	/* check checksum */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 39fa8cf8ef58..9fc2e514e28a 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -769,8 +769,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
-		offset = ALIGN(start + reserve + 64 * npfns,
-				max(nd_pfn->align, PMD_SIZE)) - start;
+		offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
+			       max(nd_pfn->align, PMD_SIZE)) - start;
 	} else if (nd_pfn->mode == PFN_MODE_RAM)
 		offset = ALIGN(start + reserve, nd_pfn->align) - start;
 	else
@@ -782,7 +782,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index b4ef7d9ff22e..2d8facea5a03 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -994,10 +994,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 		struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
 		struct nvdimm *nvdimm = mapping->nvdimm;
 
-		if ((mapping->start | mapping->size) % SZ_4K) {
-			dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
-					caller, dev_name(&nvdimm->dev), i);
-
+		if ((mapping->start | mapping->size) % PAGE_SIZE) {
+			dev_err(&nvdimm_bus->dev,
+				"%s: %s mapping%d is not 4K aligned\n",
+				caller, dev_name(&nvdimm->dev), i);
 			return NULL;
 		}
 
-- 
2.21.0

