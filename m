Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 248DDC43381
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 05:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2429218A3
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 05:43:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2429218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6775B6B000A; Sat, 30 Mar 2019 01:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65B456B000C; Sat, 30 Mar 2019 01:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5153C6B000D; Sat, 30 Mar 2019 01:43:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6436B000A
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:43:01 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i124so3754648qkf.14
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 22:43:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=DQlz7Pu3mX6BhQ0nlFCUhEvoP4NvKJJpeUFJMThbm5A=;
        b=fUnI7HnqyLdibeq9HfObBbVMeYXJ8xE0mfjK+H5X59sCnlr1ehnzBfll26f8jeDNDq
         GHf/MIyPqWcJy8hxZD+2YwGo5Xbbnsx0GfDFD43wBJVM+iETdKYVIW9OYfI1sI3lqeM2
         ZcVVwbr2/2AdrwQMPwDLy9bAPEm5E9wmyMGEOmWhjT8A4gr0aimIu0sfpAtL0cYzc9JB
         eM6mF8ZWMHDQ4Oa7eo1g+j+rx/4/NMNkNUJ48rH+gU+CeCtwR/MaGhi3VC7s5PH4cr+g
         y/ZTrAVMDuRln2yUyI5+mALUycYbbZGdugkVoUIj7V9e8eM/tacnFyYu6RSQ7i+pUFb1
         HtJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVMo4UUzLGMFFCv57LVb4zI15291Ye5PSDs6HPxVrx1kuIBxzY4
	xDa5A8zzbcRqgOP73OK9fGHOJ5gLCQDm+XcSSPyPoTGFKHAq79VlewqSnxV1RLEAIO7sCU1xxiJ
	DgLQgiQb/27y7GZbNsvDcsT/ItfwH92Tw2dP/pENspNG8eEv1sf8UgTUQzFQnZg+QKw==
X-Received: by 2002:ac8:2649:: with SMTP id v9mr44388109qtv.275.1553924580935;
        Fri, 29 Mar 2019 22:43:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdwBGVb23anuJyTccJ0YzkuI0idXUbia8bQSMTR6jMau80K1SoCE+r1iGeXPKuGPYPENX7
X-Received: by 2002:ac8:2649:: with SMTP id v9mr44388093qtv.275.1553924580300;
        Fri, 29 Mar 2019 22:43:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553924580; cv=none;
        d=google.com; s=arc-20160816;
        b=UClKszzPT2JpwAPeTcl1Fej+aeHvHgTs4y0c6LJG+ft+slkK5cgFnQ5r2qVeNOxF28
         RVqaGTA/OxNruu6MbwMNwtMKro7m9n8Fj4tNF/haDD9K25+B2m+eR3wPfH4ZXo1Oa5u8
         y5fjgZ/sDNtDW0WTw3wg0cz0Hx3xY8YObAaapB28PhBcTa3uMvuqPmKRlOF63ndkK1Cx
         yNJDmUpCpTMChHsNG2aUzRws3p+ckbZOGYHXAd2LtXAC1u6CwNWdp3IkRX/G10syKOg0
         EovWMstwBHr4cO3U+jb/AIrFAF9dRRYzJw6m1lbZTAaQ0cX6XCafuz1D98g75reK3iBy
         /2Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=DQlz7Pu3mX6BhQ0nlFCUhEvoP4NvKJJpeUFJMThbm5A=;
        b=ahkCgIJfosCWU9cherjPCJTLaxJVNchqY4XdcTMM5ipqw4mbdWc5qaB8hi2Kax8Lur
         aEELBg4PzvnEslgYXsIShAlVNVdZ8DndZzZC3BJtKGnPwXxG2U6r4pUipfmtDGm5Cd0j
         U5IHE66cSiM5k3uy5V+VwWkQ4umkpguLXLCGkxJoCXUF743BXg6IBaoZaf0M8uRSYk0K
         096qsBxxyJu5sGWuX4MRbXYkygmLuI0KKggFzx+2UZTX3XsmIbAlO74fZohRTPp2U2OW
         TTlVqaYopF2u+0gUGAsPBYBAyuNze3y0K51wkGgAqLztRXNGHJ2db0ceUuqlQCrbR2dT
         4HvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b125si293193qke.208.2019.03.29.22.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 22:43:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2U5YE6H097893
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:43:00 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rhv513kjs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:42:59 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sat, 30 Mar 2019 05:42:59 -0000
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 30 Mar 2019 05:42:56 -0000
Received: from b01ledav004.gho.pok.ibm.com (b01ledav004.gho.pok.ibm.com [9.57.199.109])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2U5gtes12058860
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 30 Mar 2019 05:42:55 GMT
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 65B26112064;
	Sat, 30 Mar 2019 05:42:55 +0000 (GMT)
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D8CCC112061;
	Sat, 30 Mar 2019 05:42:53 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.85.132])
	by b01ledav004.gho.pok.ibm.com (Postfix) with ESMTP;
	Sat, 30 Mar 2019 05:42:53 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm: Fix build warning
Date: Sat, 30 Mar 2019 11:12:48 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19033005-2213-0000-0000-0000036C650A
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010838; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000283; SDB=6.01181690; UDB=6.00618514; IPR=6.00962416;
 MB=3.00026217; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-30 05:42:57
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19033005-2214-0000-0000-00005DD71D5D
Message-Id: <20190330054248.28357-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903300038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mm/debug.c: In function ‘dump_mm’:
include/linux/kern_levels.h:5:18: warning: format ‘%llx’ expects argument of type ‘long long unsigned int’, but argument 19 has type ‘long int’ [-Wformat=]
              ~~~^

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 mm/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..c134e76918dc 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -137,7 +137,7 @@ void dump_mm(const struct mm_struct *mm)
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
 		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
-		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
+		"pinned_vm %lx data_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
 		"start_brk %lx brk %lx start_stack %lx\n"
 		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
-- 
2.20.1

