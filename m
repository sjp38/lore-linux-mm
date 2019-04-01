Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93117C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 05:14:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5519C20856
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 05:14:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5519C20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8EA06B0007; Mon,  1 Apr 2019 01:14:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3FB56B0008; Mon,  1 Apr 2019 01:14:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2FD36B000A; Mon,  1 Apr 2019 01:14:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99DEC6B0007
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 01:14:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so6411247pff.1
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 22:14:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=FX6LpGiBLVAKA83znq7JaFefiJoxdJ7HqPsQuKLu4yA=;
        b=R3s1VHsrKgqpBHoiHYfTDOnaTRBT/Rc2vAa5YkqdEEhK/JraT2Ilt2zDiLMxx4x/4j
         yGBZK5txnuhXjc6TZWQJKm7Mv3MCFGLt3gjRUFXoF0NV2H6GsueDlsJSI1X3bkMKDcLY
         ZceHXPKZoBsPSFQDA2U4tMHPXNWiIDSNPgLvGXvOcrbQFS/rWE1U2CYK08pWSTto2vu1
         42nvGS2KFI8nEqydoJULxDXRMoU4WA4e765iy8FYB+70pyIHpVveEhC9HoJj1isX9xE0
         zEIHBuQBQHZ6/hS8pNSBNX5xuKGssgz0sKnCe7SHH2/v/Mb+DX7kUNxaWHKOau8Xg7nx
         MBkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWjubkflUHcdOjiAThDNru++LKd0xFxF+5Lj7YCk4xs/kTK66dH
	liNvqW0vqRi54a8c9vR/K3h9vivOOxKamlUYhbqqqJf9TBfrJI+TEH9sFp92/8QOyBAcK3gYBQ+
	aOSSoSj4ZlPWO7SHrXI7Z4yRM8gqbTEOYY0edkMdIsoa24OpvNO8f0OZcvYyQz1TPCQ==
X-Received: by 2002:a65:53c1:: with SMTP id z1mr51804030pgr.415.1554095682161;
        Sun, 31 Mar 2019 22:14:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKLw2eLUA+Dc0hmhJh0y6ibjTECyKgwt4qFisdbE6hE9Lc2UNw70QYQYePJSalZ65+BQm7
X-Received: by 2002:a65:53c1:: with SMTP id z1mr51803982pgr.415.1554095681036;
        Sun, 31 Mar 2019 22:14:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554095681; cv=none;
        d=google.com; s=arc-20160816;
        b=sFD+xvSGUB2s9Xh8hi6CSf32c7aLGKcZB/5qj5peMJWFIKvGj4wTnEuqxsdHWYBbZZ
         GLaN80b0jx6iIiSCIkKXVFO5fSvzdL6pT8twKl0JdjkVqUHW9F2hzVEfHbjLDHR44KH3
         d4UU//UGGdRKQfsPDZbs7IH5o7Xne4YBsC6Q1pLTWzT8SBzf4bhI0tzboOwv4c5d8Lxy
         w592CEzCvKDvu9wA9PFAiQPPc8LU+yD63w1Z8F0e2ExOL4CbY4w+TL3dEG65ZNJaIn2u
         L6N/btn1Thg7C6HKdwvS0VKO8I/YBCAjCt5fYtNGcsGOhr20LkpyHmMQNNep7jiYnxBa
         1XNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=FX6LpGiBLVAKA83znq7JaFefiJoxdJ7HqPsQuKLu4yA=;
        b=V0wlnAku85N3I3cqEhkfojrrZB+MqIfRZ1kA3YgNpGxPlADU1WQ7+pav3fCmgzZxBB
         myHKJn+fDR7lU5J8htuR5LF0E29wBFzLeX5zcNy2m1is2o2kZMjF0W4aFctWbnDHOi7T
         wRhZwHFOBUGuKn38bFSRX2GEZWFZT5KNBYZz0iiWeh8+MIMIzcORfXMYehKAxKoxA63E
         X4RijYNMY3xJ3SZQE6kuUT1kOD2a0In05DF3nxAKfhBhN4qZoQdUCRD0p0a2jKgJxg46
         OgVd4zv+9ICp2N7QAVkoGai8Db64nvO3M98GewpUHDmvKEOOcX00npDa6D8+WH+W7PHz
         DKJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k18si8242113pgb.351.2019.03.31.22.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Mar 2019 22:14:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x315EekB108318
	for <linux-mm@kvack.org>; Mon, 1 Apr 2019 01:14:40 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rkbsvh8mn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 Apr 2019 01:14:40 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 1 Apr 2019 06:14:38 +0100
Received: from b03cxnp07029.gho.boulder.ibm.com (9.17.130.16)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 1 Apr 2019 06:14:35 +0100
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x315EYQt11534578
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 1 Apr 2019 05:14:34 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 430587805C;
	Mon,  1 Apr 2019 05:14:34 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 02C577805E;
	Mon,  1 Apr 2019 05:14:31 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.204.201.112])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP;
	Mon,  1 Apr 2019 05:14:31 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v2] drivers/dax: Allow to include DEV_DAX_PMEM as builtin
Date: Mon,  1 Apr 2019 10:44:21 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19040105-0012-0000-0000-0000171FE265
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010851; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000283; SDB=6.01182625; UDB=6.00619080; IPR=6.00963368;
 MB=3.00026236; MTD=3.00000008; XFM=3.00000015; UTC=2019-04-01 05:14:36
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040105-0013-0000-0000-000056B4D84B
Message-Id: <20190401051421.17878-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-01_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=885 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904010039
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
Changes from V1:
* Make sure we only build compat code as module

 drivers/dax/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
index 5ef624fe3934..a59f338f520f 100644
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
+	depends on m && DEV_DAX_PMEM=m
 	default DEV_DAX_PMEM
 	help
 	  Older versions of the libdaxctl library expect to find all
-- 
2.20.1

