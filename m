Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BC7FC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09CEC207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09CEC207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 649A36B0266; Fri,  7 Jun 2019 02:47:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FA3E6B0269; Fri,  7 Jun 2019 02:47:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 511776B026B; Fri,  7 Jun 2019 02:47:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC456B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:47:48 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id h143so1096165ybg.6
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:47:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=FPpiJon3CxkvkrPxqW3LlksAfc6qYLNPiD04iowBvXQ=;
        b=dOmVdMobJgF1w8RW+j2iotGG6rbWskGH40IgBgUHxKSU72XXb9bRIVjjfy/XAqDMae
         FONCHFl2hqMfYOZbIztCICw57r1pKFcBMM2TNeS3CizU38gE/q7A4ageHeoLCdzsR9s6
         dd3prrFfT9/spCeHd/zk+TI5p0tCWQ9OyFo5AB29BQoRIKwjyEFrousFeqNXHLm6l+sX
         wLQvyaOjSLBmp2nzQSxbTVkVTlWcFVs2WkWgHPqpMWom8dRsFRyYUTsCkG4oIokwBapU
         z8SH0/qUHYQbBPietuwh/2LltHGpCknaJejgqJnRShmWIFe9+R9C+Zdjje8HCtnZ7Jev
         aHfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWabnfWV06vdWt2D2bp/IAy4n3sfVRgm9oCbbtpg/OJywkN2yCk
	VdjC44ZKKBoHNJaqRL0GiF7K3topbWx+FrgmK/nww+0PB8eqz2aLcw/gloaIfC6ctLBs2TTBB6a
	+lf7VvGnN7/mHOwxP3Uf+iNbMPlcTiKh1mlM57rOb40bRrUB2PHz+QTtYuiuUrjMsxA==
X-Received: by 2002:a81:4f0f:: with SMTP id d15mr27377903ywb.363.1559890067882;
        Thu, 06 Jun 2019 23:47:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb2SBBR6Uo9QRBuUBtei6ykCoF1Nin9DeyCEFPObFGkU4kps/7EB1/4nETi1fehFHtfjYK
X-Received: by 2002:a81:4f0f:: with SMTP id d15mr27377869ywb.363.1559890066337;
        Thu, 06 Jun 2019 23:47:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559890066; cv=none;
        d=google.com; s=arc-20160816;
        b=aVF0/+nxCFrVYK6G3Ro93NHbOZ9ukO82G93bY5TJb8ZkllUSWd6mo0TgRmD4+cypyy
         pxqPI4H6iVR46cpIHNTFRv2yYcAb4h9vtX+7hJjhydUcdYP3MYG0SUzduHyzRLOfhecr
         KvbgajNIZCR8TYpb7LC2DFpstCvU81A5aROj+7qFYBqJktilCwge2o1F2pjChwVVDHWq
         WmicAl/RHO7muuGStIDCdCXYWnTHm4xuDZwZ4l7M6gO0xq/+/Ts5nXzPVRShGCVHIpAq
         Kpgyu6TrGbn2QoDnYPlaARYOLzNmh3WNbSY5TKogsbHMGf9c9OtlFOoDrPBnW+mZZBKb
         nGlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=FPpiJon3CxkvkrPxqW3LlksAfc6qYLNPiD04iowBvXQ=;
        b=c75UGOgQJfXSZJVQoIW9Co37y4YojlJ3YdD2cS1Q23/f7NC8IRWN0+whBaA/+SRZqT
         gGM9ljQEwoICCOujeoxMMeDB/Ac0YSoNu8TLPy9by5Jgaw8XvUpDSM6r7oZG3oTCZMSe
         Dbexc13H4MK4OtGzjF2xVyLveXcuvizwCO/DOyuvuii64XjTXAPC1oHL8FK5PKPwKMLE
         Xx8Xzca4IvTOlzDICrhm+gmM0sol47nsR9L7uKGaTxkr2TMqR/W39a6EtFlwSbovwk6o
         3RGPTnfJFVMWv5UbZM35OtMyoW7LBYjR0e4tmwkj+S/uB09I73JcPrm/9NB641LeHDdG
         rA/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x67si291873yba.433.2019.06.06.23.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 23:47:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x576l3ut017078
	for <linux-mm@kvack.org>; Fri, 7 Jun 2019 02:47:46 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2syhtttyba-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 07 Jun 2019 02:47:45 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 7 Jun 2019 07:47:45 +0100
Received: from b01cxnp22035.gho.pok.ibm.com (9.57.198.25)
	by e14.ny.us.ibm.com (146.89.104.201) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 7 Jun 2019 07:47:41 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x576le5c19202352
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 7 Jun 2019 06:47:40 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B6EB8B2064;
	Fri,  7 Jun 2019 06:47:40 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4726EB2067;
	Fri,  7 Jun 2019 06:47:39 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.207])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Fri,  7 Jun 2019 06:47:39 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] =?UTF-8?q?mm/nvdimm:=20Fix=20endian=20conversion=20issues?= =?UTF-8?q?=C2=A0?=
Date: Fri,  7 Jun 2019 12:17:32 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060706-0052-0000-0000-000003CCAA7E
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011227; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01214407; UDB=6.00638362; IPR=6.00995493;
 MB=3.00027216; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-07 06:47:43
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060706-0053-0000-0000-00006138181D
Message-Id: <20190607064732.30384-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-07_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906070048
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

nd_label->dpa issue was observed when trying to enable the namespace created
with little-endian kernel on a big-endian kernel. That made me run
`sparse` on the rest of the code and other changes are the result of that.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/btt.c            | 8 ++++----
 drivers/nvdimm/namespace_devs.c | 7 ++++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index 4671776f5623..4ac0f5dde467 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -400,9 +400,9 @@ static int btt_flog_write(struct arena_info *arena, u32 lane, u32 sub,
 	arena->freelist[lane].sub = 1 - arena->freelist[lane].sub;
 	if (++(arena->freelist[lane].seq) == 4)
 		arena->freelist[lane].seq = 1;
-	if (ent_e_flag(ent->old_map))
+	if (ent_e_flag(le32_to_cpu(ent->old_map)))
 		arena->freelist[lane].has_err = 1;
-	arena->freelist[lane].block = le32_to_cpu(ent_lba(ent->old_map));
+	arena->freelist[lane].block = ent_lba(le32_to_cpu(ent->old_map));
 
 	return ret;
 }
@@ -568,8 +568,8 @@ static int btt_freelist_init(struct arena_info *arena)
 		 * FIXME: if error clearing fails during init, we want to make
 		 * the BTT read-only
 		 */
-		if (ent_e_flag(log_new.old_map) &&
-				!ent_normal(log_new.old_map)) {
+		if (ent_e_flag(le32_to_cpu(log_new.old_map)) &&
+		    !ent_normal(le32_to_cpu(log_new.old_map))) {
 			arena->freelist[i].has_err = 1;
 			ret = arena_clear_freelist_error(arena, i);
 			if (ret)
diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index c4c5a191b1d6..500c37db496a 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -1995,7 +1995,7 @@ static struct device *create_namespace_pmem(struct nd_region *nd_region,
 		nd_mapping = &nd_region->mapping[i];
 		label_ent = list_first_entry_or_null(&nd_mapping->labels,
 				typeof(*label_ent), list);
-		label0 = label_ent ? label_ent->label : 0;
+		label0 = label_ent ? label_ent->label : NULL;
 
 		if (!label0) {
 			WARN_ON(1);
@@ -2330,8 +2330,9 @@ static struct device **scan_labels(struct nd_region *nd_region)
 			continue;
 
 		/* skip labels that describe extents outside of the region */
-		if (nd_label->dpa < nd_mapping->start || nd_label->dpa > map_end)
-			continue;
+		if (__le64_to_cpu(nd_label->dpa) < nd_mapping->start ||
+		    __le64_to_cpu(nd_label->dpa) > map_end)
+				continue;
 
 		i = add_namespace_resource(nd_region, nd_label, devs, count);
 		if (i < 0)
-- 
2.21.0

