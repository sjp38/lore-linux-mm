Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88C2BC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C8A42146E
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C8A42146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E95BA8E0006; Wed, 26 Jun 2019 02:11:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45E48E0002; Wed, 26 Jun 2019 02:11:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D68738E0006; Wed, 26 Jun 2019 02:11:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0B508E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:47 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id o17so3362714yba.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=iQPsl1iMENa5hzy31vUEN7C6dkGUjfPrZ3bDwYeU8lE=;
        b=S3LgOmFn+PYxJGFqQhtS0qYZ7sNbEyaIKIGA7yMppq1z3Ajx06tPKKOgpcp5HsG9DI
         78iyguRM9rW0v0pL/ORPMO27nZBNKPDWrnEsVD9eP7lkMnwPXzFSsQH6C9dIJij+KGWV
         cU4teDG3/sgCeZ5rIzCoksqxYu4mpunCyYYiW3SW2S8sIlv0crKA7tSp5ElJXlUSYXLd
         RkTYLIYAPnt3W40HMYrZjP8V2eDPnZWwL3yvUQz4YkHimPZko4PEdkBlzsHWKHg5YG/E
         BV64D2OgPyO4qrxPngAwS+49zd7xkk9wudx69jksoaSnafQTCKrDex81/x3TOQ1lY9tR
         8KdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXTCfSNTeWjAMBiyUYDlv0BDHo9yt0QN/SKnlM9AnsVqGGPuhy4
	IpyS8GnZdYQsoLLc0UT9i/6sOzeoT3sBPSGvVKjptSuKs1Dn8Mv0GoBbLXS0TxYRR8bV60/LgU9
	04nxRF835JXyzvkh/fwdQRGmDUJB/47n77AQt2AKvZk/m/bQDfFpOg7WuQc8ErcGT8A==
X-Received: by 2002:a81:8946:: with SMTP id z67mr1687335ywf.224.1561529507483;
        Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0PxhRzrLHT1elfuShz28+XpQ5srB+Dgp34eD/fA0xvL9+FIXwo033gjm3E338Z/5gw3UW
X-Received: by 2002:a81:8946:: with SMTP id z67mr1687313ywf.224.1561529506910;
        Tue, 25 Jun 2019 23:11:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561529506; cv=none;
        d=google.com; s=arc-20160816;
        b=j/tbRqYn18pVa9DOLoogJ0FMGI8dNkKlyZfcT8M00/ZMj/6yCHTX7zWHLSjKyc7Lq2
         m/XH/eZECM6WfsDc4FU3s3/kOW8OdBl+HssyGWaElhX7hism5FTCijRU540GD3ivUlAY
         XTNjoj/caJ4Yiv6ZwJMwSPTR5Wn298bChrDAT0UFe2KBtzF3V9t1H847UrW2GpWB3xSJ
         xhICIoQ5Zi181KUkLtcnC/4rRtt7+xo8I/6Q9i9tC+siH2ANXRlG8cn4enNhNP2ac7jZ
         Z5fZ1/ePTZSk0eQqUMJ6nvGyPf1QZ+bcP+pxFZRYq7Dl6ZfLS3RCODcPOCVDMn8sX4lq
         4LYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=iQPsl1iMENa5hzy31vUEN7C6dkGUjfPrZ3bDwYeU8lE=;
        b=zSrGncIJ1kX80pQsvcvXoq2jzOfbebCeShhlK42kW2tFvlkJUc1XilGCPvfP4cvB0x
         jjnxp2/FcU/+LVZyTr4g3y3HK8QaUj9MU3cQZ1MuHf+Lh8W6m8NKNi1z6CTnFai0KRKU
         K0akB9RWUDtZFxYSM8f7fTiyZvvLz0TFBfaSpxbDXVk/W8IWg3rWBeXSyZGXLM+R/q7z
         aLZMECuaJcbTnnHi+kT7r3LAqr4y/7+Nzat9+upHVGmb9TLvI/UOx5TpzYAsVmgprxof
         a3krY/15eHcvC1aERmQaqlfyD2FhNaKLQXt7Uq7PMefyE3VT+o0dmxP0CUrwFl621T7r
         TzPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q11si6559170ywi.32.2019.06.25.23.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:11:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5Q68ZHq077854
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:46 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tc2j1hd1v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:45 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Wed, 26 Jun 2019 07:11:43 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 26 Jun 2019 07:11:38 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5Q6BbO860162242
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 06:11:37 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 82E1A42041;
	Wed, 26 Jun 2019 06:11:37 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2E6394203F;
	Wed, 26 Jun 2019 06:11:37 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 26 Jun 2019 06:11:37 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id E1F39A01B9;
	Wed, 26 Jun 2019 16:11:35 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
        Wei Yang <richard.weiyang@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [PATCH v2 0/3] mm: Cleanup & allow modules to hotplug memory
Date: Wed, 26 Jun 2019 16:11:20 +1000
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19062606-0012-0000-0000-0000032C756E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062606-0013-0000-0000-00002165ADDA
Message-Id: <20190626061124.16013-1-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=476 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

This series addresses some minor issues found when developing a
persistent memory driver.

Changelog:
V2:
  - Drop mm/hotplug: export try_online_node
        (not necessary)
  - Return errors from __section_nr
  - Remove errant whitespace change in
        mm: don't hide potentially null memmap pointer
  - Rework mm: don't hide potentially null memmap pointer
    to use a start & count
  - Drop mm/hotplug: Avoid RCU stalls when removing large amounts of memory
        (similar patch already went in)

Alastair D'Silva (3):
  mm: Trigger bug on if a section is not found in __section_nr
  mm: don't hide potentially null memmap pointer in
    sparse_remove_one_section
  mm: Don't manually decrement num_poisoned_pages

 drivers/base/memory.c | 18 +++++++++++++++---
 mm/sparse.c           | 21 +++++++++++++++------
 2 files changed, 30 insertions(+), 9 deletions(-)

-- 
2.21.0

