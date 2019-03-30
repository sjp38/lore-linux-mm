Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C90CC43381
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 05:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9F36218A3
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 05:42:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9F36218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 566F36B0006; Sat, 30 Mar 2019 01:42:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 516C46B0008; Sat, 30 Mar 2019 01:42:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E0966B000A; Sat, 30 Mar 2019 01:42:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 049F66B0006
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:42:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v76so1886311pfa.18
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 22:42:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=6yGWHEb2lZdr44Z+NRxqQ5CwZFu/9lym+Be6PcqldiI=;
        b=RIpGGW8R7eWMbMnRRUbnNHcSn5esjgHc4LnTK170LqwMg/FTXJt4RNytkK+fU0QPZ+
         aTktx23Kvuw3LGdN073CqgBNBHshiOarweTTCpQZv8JwGkskVtaRx6nAMrPxtjC5HSw8
         0cIUR5AH8/0R9lS0yTHGMEBnyNCMQOPnk6OHyzHX5j+EjdiivijDFcAidImM9HQG+De8
         emrRZRMpo+8xIi0LNIqDm/jbV4O7+gypIBSxYXWyPfidmr4O9q6ogsVbdG728gLvTxJt
         YIMmOAiQhIq6/8Ig6yMU2LpScS/1lOTe3iG4iAilMmeYD1AKe5xyoqkWrNk28NyaT/el
         W5Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXyEzW4gpbeMD5j61o1Lnkq1hiu7tXzSuoZ03R6HXEfZPQMgb9S
	BPoTJeWe2AI1JfQy6pQmucUGCrj19s+aJm8EX7BfgEosX+uhK+kj9hnYXo6I5mXwB26IacMkGKk
	tAB8yLGEvIknvhfBe+thkHNfu/2jnE/XE4S4nqLsBCjssHHl3PAN6pyYEVGm664yb0g==
X-Received: by 2002:a17:902:8bc6:: with SMTP id r6mr53991345plo.235.1553924536649;
        Fri, 29 Mar 2019 22:42:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA7uJr7ti8LmguzJZEqC023kv6nrGqlv46bi0X1T7GR86/586chHK8s2K0ZAsDIRExO4NF
X-Received: by 2002:a17:902:8bc6:: with SMTP id r6mr53991307plo.235.1553924535946;
        Fri, 29 Mar 2019 22:42:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553924535; cv=none;
        d=google.com; s=arc-20160816;
        b=hHsmqfzbIJQp8XhRpa8IAqbbBag0h6TYo/Ubc9DPh41epUgFoxJxTpN0650g9gglOL
         awTA/zR7QjeyymJ7Huxy5FKCi6lpFAPE7ZqApvwV4aPNm0JjjQTNg2QfyBHfGacHS6a2
         5ge/uqrIOfst0k/SvvZ9vM01E5mJoWr+NxmZrBu8Vm9wjQdwNZO7TTWyclL3FZ/5G5gP
         zVfYydb4pECjrf+qn0xFcE8Vojef17blyCDdB45Yu7YvkKKpdLXOj2dwS6CDoxfbPEsJ
         ATlXkfYDrDRShb+iN0qUULl/KD4YhLDmEdQ602Iy1jKANXu701tY3xqHOsJZtoZUaARx
         T+Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=6yGWHEb2lZdr44Z+NRxqQ5CwZFu/9lym+Be6PcqldiI=;
        b=NKDKcoANTyqFxgifscRCL7dGFO0uIKtevmNszKBI+zJZqbqfN2a59jXkzjIp9ob1FR
         KeTIaXfpOaaIVsqC4tTC2owS7IBg4IT0KKTXQQ8BjmJTXjRC53Rl83muQRC9WoWTPtDK
         bien0bHLT+ddpA2maJ7IzoDv44kdr+ueybmYIprmkSpOzQjk0FM0xIJaQf/1qRXRBbDw
         2Gu5XCUjqCXw83kQOY6fPGp54WAniU34AfSGGtp2+9EK9BF5Ss4zLfYmr+1c9Y/zOebf
         uA8hrLKZ16PvVCtqeuKODQqll6zv9WajXHlVZiXOtFsNg0907ebmWkt3Le1nLWeGtqrm
         zPyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m26si3543069pfi.247.2019.03.29.22.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 22:42:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2U5YJ9b058516
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:42:15 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rj27e8g38-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 01:42:15 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sat, 30 Mar 2019 05:42:14 -0000
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 30 Mar 2019 05:42:11 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2U5gAIp21692572
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 30 Mar 2019 05:42:10 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 60E2AB2065;
	Sat, 30 Mar 2019 05:42:10 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 97952B2066;
	Sat, 30 Mar 2019 05:42:08 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.85.132])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Sat, 30 Mar 2019 05:42:08 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH] drivers/dax: Allow to include DEV_DAX_PMEM as builtin
Date: Sat, 30 Mar 2019 11:12:05 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19033005-0064-0000-0000-000003C2D5B3
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010838; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000283; SDB=6.01181690; UDB=6.00618514; IPR=6.00962416;
 MB=3.00026217; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-30 05:42:13
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19033005-0065-0000-0000-00003CE26866
Message-Id: <20190330054205.28005-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=878 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903300038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This move the dependency to DEV_DAX_PMEM_COMPAT such that only
if DEV_DAX_PMEM is built as module we can allow the compat support.

This allows to test the new code easily in a emulation setup where we
often build things without module support.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/dax/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
index 5ef624fe3934..e582e088b48c 100644
--- a/drivers/dax/Kconfig
+++ b/drivers/dax/Kconfig
@@ -23,7 +23,6 @@ config DEV_DAX
 config DEV_DAX_PMEM
 	tristate "PMEM DAX: direct access to persistent memory"
 	depends on LIBNVDIMM && NVDIMM_DAX && DEV_DAX
-	depends on m # until we can kill DEV_DAX_PMEM_COMPAT
 	default DEV_DAX
 	help
 	  Support raw access to persistent memory.  Note that this
@@ -50,7 +49,7 @@ config DEV_DAX_KMEM
 
 config DEV_DAX_PMEM_COMPAT
 	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
-	depends on DEV_DAX_PMEM
+	depends on DEV_DAX_PMEM=m
 	default DEV_DAX_PMEM
 	help
 	  Older versions of the libdaxctl library expect to find all
-- 
2.20.1

