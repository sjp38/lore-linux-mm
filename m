Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B043C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE5FD2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:45:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE5FD2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2057E6B0005; Fri,  9 Aug 2019 03:45:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B6B06B0006; Fri,  9 Aug 2019 03:45:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07EC06B0007; Fri,  9 Aug 2019 03:45:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBB236B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 03:45:36 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id r206so8400085ybc.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 00:45:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=maUtppyZ/ZzXMKQD6DCj7W8zZ7OvmQ8A1+hamzMiuDE=;
        b=GxfAltVZgcVbIy8PRA7G9lJ43sdSboJtNP8rj3p79k/AMlmC/HmnWS/hY0bv05B6Ex
         Ql21pLTXA6dL9uwhMjdNIJ2LzVIaVRBKHFmpBA3jAkbpTnOsTgIiZky59o98GYWAak0n
         PlgrKE8njaZgHdetZT0oKSr12h5OIyHmduke/L4wAVoMR+/NtaUbwupok/YQMRg6mSN5
         uefCVGI/2vg2GoMtj0Wk61BU3s2xXKxcF1dOnVTYt/4wRHhnF3t3BLG5B/8uMHqckHlP
         RRYpXxV0FCA6W7WnF7tvlesjqJ+ZKycUdbHpRJDFbc95y/mxbefMqC4oWuoTPWnnQqs/
         EA+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU7zyf0kwO6n9Ir3RWtSanqbJBAbRK1bb0i0QeTntv2xRQZCjaA
	5hIrEHdMETLK25BzDEM9WDcXb5E5LH8IQFFGizW+IYChtn/Xlb6rC+OaIJxnQ18DHmyUPL1DMIQ
	F44NUNJkEV+FDajP+07vjCalWhiJ7Rvp2mf/btycuhio8JRdxVoX3Tyc4sH7HR+8x5Q==
X-Received: by 2002:a25:6944:: with SMTP id e65mr7465131ybc.213.1565336736621;
        Fri, 09 Aug 2019 00:45:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdfGO3n+gbOMHPkGuMVJTZA8wP9ON/BTHbUN9TnZxjSV1EL5qvr8nfhldkqmA3A3DKxMtR
X-Received: by 2002:a25:6944:: with SMTP id e65mr7465108ybc.213.1565336735959;
        Fri, 09 Aug 2019 00:45:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565336735; cv=none;
        d=google.com; s=arc-20160816;
        b=LFXHhcGFbJRBgzXIud7S05j9IiDUmPpPK1n+/+xB1clk40vKvq7fm5bMUwo+he+O5W
         27ZPObvnCjLgUPZ2nOI6q/5qMgXhRzk/V+5/NGGnSvjr01o4FgLmiOunMvuIbnkAZZ4p
         Vylctd5Q1gwVun8+tpNhlVLXQrobqTihy00zpkxotF+9mIdBEI0TZHKUNpsOyo09lwHU
         4aq0u8l0qGWUD/AGAX8p76+Mw6w8FVAvjlc+HRIvG83bNy13IbRSr8jlTJpwsHFlWscz
         w0Wr2GDOAene7WqO8AzQ9/UnBP/O6NVpIpABgB27zmSpctU2wE/SjOIqUNBKU4pdBM4n
         Po6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=maUtppyZ/ZzXMKQD6DCj7W8zZ7OvmQ8A1+hamzMiuDE=;
        b=jg48cqv3IZaLXK1ZYn3HI6xEtPEJQS+s/GEtfRNtGNL8kH5CBFVrHxHYsNQMSl00M3
         XItRtOGKvsCva8bgT1TfFr5Ds1RrFa2V+sngAkuboqv6WbMBSh9F29/OkQinLjeRDIjT
         Vibd2cKJhxQC5l7JWO90bQ2kb/LAohEUy9hntViUKEp5QRHgqVU9DTNU/OQSxbUUn5mi
         Je2c6SoQJMW43GYsn+IPll/PlECuCM0sOKs878Soib3nYQsgbqnwO3ephlFuBTtuf8Zw
         KmJSk0jgkkeZmZyN7jJwlxJ7KLbhC7PK4X/O22rxuUTXs8kxJESdZlk9J1crw8ShM4Y/
         1n7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g17si1540042ybq.109.2019.08.09.00.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 00:45:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x797hWtn003197;
	Fri, 9 Aug 2019 03:45:33 -0400
Received: from ppma04dal.us.ibm.com (7a.29.35a9.ip4.static.sl-reverse.com [169.53.41.122])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u94e2gn3a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 03:45:33 -0400
Received: from pps.filterd (ppma04dal.us.ibm.com [127.0.0.1])
	by ppma04dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x797hdn2012259;
	Fri, 9 Aug 2019 07:45:32 GMT
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by ppma04dal.us.ibm.com with ESMTP id 2u51w7cqjt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 09 Aug 2019 07:45:32 +0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x797jV6m21234126
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 07:45:31 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6677F6A047;
	Fri,  9 Aug 2019 07:45:31 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 66DE16A04F;
	Fri,  9 Aug 2019 07:45:29 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.36.73])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 07:45:29 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v5 0/4] Mark the namespace disabled on pfn superblock mismatch
Date: Fri,  9 Aug 2019 13:15:16 +0530
Message-Id: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=864 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We add new members to pfn superblock (PAGE_SIZE and struct page size) in this series.
This is now checked while initializing the namespace. If we find a mismatch we mark
the namespace disabled.

This series also handle configs where hugepage support is not enabled by default.
This can result in different align restrictions for dax namespace. We mark the
dax namespace disabled if we find the alignment not supported.

Aneesh Kumar K.V (4):
  nvdimm: Consider probe return -EOPNOTSUPP as success
  mm/nvdimm: Add page size and struct page size to pfn superblock
  mm/nvdimm: Use correct #defines instead of open coding
  mm/nvdimm: Pick the right alignment default when creating dax devices

 arch/powerpc/include/asm/libnvdimm.h |  9 ++++
 arch/powerpc/mm/Makefile             |  1 +
 arch/powerpc/mm/nvdimm.c             | 34 +++++++++++++++
 arch/x86/include/asm/libnvdimm.h     | 19 +++++++++
 drivers/nvdimm/bus.c                 |  2 +-
 drivers/nvdimm/label.c               |  2 +-
 drivers/nvdimm/namespace_devs.c      |  6 +--
 drivers/nvdimm/nd.h                  |  6 ---
 drivers/nvdimm/pfn.h                 |  5 ++-
 drivers/nvdimm/pfn_devs.c            | 62 ++++++++++++++++++++++++++--
 drivers/nvdimm/pmem.c                | 26 ++++++++++--
 drivers/nvdimm/region_devs.c         |  8 ++--
 include/linux/huge_mm.h              |  7 +++-
 13 files changed, 163 insertions(+), 24 deletions(-)
 create mode 100644 arch/powerpc/include/asm/libnvdimm.h
 create mode 100644 arch/powerpc/mm/nvdimm.c
 create mode 100644 arch/x86/include/asm/libnvdimm.h

-- 
2.21.0

