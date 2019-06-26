Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CAEC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47B412133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47B412133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F93E8E0007; Wed, 26 Jun 2019 02:11:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6582C8E0002; Wed, 26 Jun 2019 02:11:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51FD38E0007; Wed, 26 Jun 2019 02:11:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 182BF8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so1022180pfb.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:11:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=+LhoXjGDCmA/BWEI5sQyVHP3vUhDz7qGYRnqV/bPhyY=;
        b=Cpug/8t35jNDYjgePBQJ3mME+DcPTHEvDW2wVuhM83awgXlGlhILGfNtT8dBPeTwRc
         nYK+aJv34HC0M+wUkbFX+eWrBlYBvUEiyMXuc8pvYb69hfvt16rKBfKuLSi+oDbdJA/4
         Kkl2OoVMpRJWsTQiPYMQY7BTng4zrr63nLMqbh97GNoporj4/w2sZn7fd3EzscCkcfja
         TVoGpST4s62BCl0y3/RPqBjPAZLYVx2JIy0PhVimE//q4D6laRfsiH8oZ4SE3HZOQvvw
         gx4wdUfl7Cf0evYkf+6drw6Gt+gEPyrSpR9Lx+YGmqmCT9+hIeOinjYIGBv91hYSsPFl
         7zYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXgribsKUqmUTFxm00HwfllYjeaAtOKrw3f22vcY0Bu3z3E3JER
	R1zXCzTpisJJow3NFwv5oxmfcX2Z4UZuxgneHpYeo8t0wkpgfOWZ4uHSC0Qg6a82XpPMHxNn9S7
	VTAaok/5iDvG5ePbUb77NqxxVInOgrHZfMRvn0w0R/dTyinGn0JEnflgqlqIZUCPyAw==
X-Received: by 2002:a17:90a:bb94:: with SMTP id v20mr2641894pjr.88.1561529508737;
        Tue, 25 Jun 2019 23:11:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7NfZqaoeuiAI/dB94fxUdW36hQzEPFEMRQJip9QkO4JpUi0CQjyYuopkX3I/zEhRJqWS7
X-Received: by 2002:a17:90a:bb94:: with SMTP id v20mr2641839pjr.88.1561529507988;
        Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561529507; cv=none;
        d=google.com; s=arc-20160816;
        b=UT8DosWbCnyaXxa8dRX9HSZSABdCo45Do8mCf9l9hxVimdcL6O6OBxy7bzT3qhxyii
         HId2KK7Ysb3iCDTC1aS5X10k7BxVhZaRZHyvQ+q4QemvAhh+OBst6ry7Ky8yEMPZ8KaV
         Yw4XreAaQPKM3I+XAiK7OVlNKC2enkt8XksCR0yClLinFsGgFiA/YO09eq8eU4q6+DxL
         IWUH8QgRz8cdQbjSmNC1m5/nrEoLLYMF/DmA2nxo6W2lPLod0RKZBOKobIa0QoIckse6
         /ZitsFg0pzFcUAJtzRCoV6mRq2MZkehfoFYeMD8PUfP7NCIW5kkuUlPnSZZM9TXCL7NT
         nLvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=+LhoXjGDCmA/BWEI5sQyVHP3vUhDz7qGYRnqV/bPhyY=;
        b=DNJ5RFWFePGKkXi0pqixXml5HzAN9S+UZbd5lIc6CEBOl3aUiFIPuZJu8mP97W/pDP
         oEDqAVMdZ0KApailIvq2Rr+e7W63HXsyTCysMjAtKvXYl2dB2mnJSDETXtKnUTwDQpYo
         gRLt6QTw25WRIi/rGKwcr2Akd6AOGAvxwmTvjz1hUMQEsyW487Fo7Vm4R8fvK5fj3RB7
         FgK9ueBbod0WuteOBl3xqJiUJmGNQZuLNPaKnUMBGY4UMtEt0LL/JHvWycWIWgUjMGWN
         EF+lXBiAwWQpgBxRP9eCui/a57G1NEvXidO0F7/924qy6z5Jgi2kffaQZb7UZ9M7Z4S1
         8bdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h38si2390560plb.149.2019.06.25.23.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:11:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5Q67HUm068727
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:47 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tc1gf3c8y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:46 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Wed, 26 Jun 2019 07:11:44 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 26 Jun 2019 07:11:39 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5Q6BcPj55312554
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 06:11:38 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C8DBBA4055;
	Wed, 26 Jun 2019 06:11:38 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 722F4A4053;
	Wed, 26 Jun 2019 06:11:38 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 26 Jun 2019 06:11:38 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 5ECC5A01D8;
	Wed, 26 Jun 2019 16:11:37 +1000 (AEST)
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
Subject: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in __section_nr
Date: Wed, 26 Jun 2019 16:11:21 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190626061124.16013-1-alastair@au1.ibm.com>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19062606-0020-0000-0000-0000034D7214
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062606-0021-0000-0000-000021A0E534
Message-Id: <20190626061124.16013-2-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

If a memory section comes in where the physical address is greater than
that which is managed by the kernel, this function would not trigger the
bug and instead return a bogus section number.

This patch tracks whether the section was actually found, and triggers the
bug if not.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 drivers/base/memory.c | 18 +++++++++++++++---
 mm/sparse.c           |  7 ++++++-
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index f180427e48f4..9244c122abf1 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -585,13 +585,21 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
 struct memory_block *find_memory_block_hinted(struct mem_section *section,
 					      struct memory_block *hint)
 {
-	int block_id = base_memory_block_id(__section_nr(section));
+	int block_id, section_nr;
 	struct device *hintdev = hint ? &hint->dev : NULL;
 	struct device *dev;
 
+	section_nr = __section_nr(section);
+	if (section_nr < 0) {
+		if (hintdev)
+			put_device(hintdev);
+		return NULL;
+	}
+
+	block_id = base_memory_block_id(section_nr);
 	dev = subsys_find_device_by_id(&memory_subsys, block_id, hintdev);
-	if (hint)
-		put_device(&hint->dev);
+	if (hintdev)
+		put_device(hintdev);
 	if (!dev)
 		return NULL;
 	return to_memory_block(dev);
@@ -664,6 +672,10 @@ static int init_memory_block(struct memory_block **memory,
 		return -ENOMEM;
 
 	scn_nr = __section_nr(section);
+
+	if (scn_nr < 0)
+		return scn_nr;
+
 	mem->start_section_nr =
 			base_memory_block_id(scn_nr) * sections_per_block;
 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
diff --git a/mm/sparse.c b/mm/sparse.c
index fd13166949b5..57a1a3d9c1cf 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -113,10 +113,15 @@ int __section_nr(struct mem_section* ms)
 			continue;
 
 		if ((ms >= root) && (ms < (root + SECTIONS_PER_ROOT)))
-		     break;
+			break;
 	}
 
 	VM_BUG_ON(!root);
+	if (root_nr == NR_SECTION_ROOTS) {
+		VM_BUG_ON(true);
+
+		return -EINVAL;
+	}
 
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
-- 
2.21.0

