Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71D82C76192
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 02:42:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A8D721841
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 02:42:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A8D721841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 777166B0005; Wed, 17 Jul 2019 22:42:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727846B0007; Wed, 17 Jul 2019 22:42:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F05A8E0001; Wed, 17 Jul 2019 22:42:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2337C6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 22:42:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so13129821pld.1
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 19:42:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=8EzvB7i2YoHMyqI+IPD3lTmLkVOKRpq539k5H3z+ISQ=;
        b=rK3VYt7TAQeLhA97z0NeojfTKcp9hDmWSZM58J1CiyHfU8hcYpLJMWRHfvYdwAU5YV
         K0EpLKomMj4GEG3I7yNsYXV9a4ql3t8efgAmGnSIgbnA5V2HVMIStDwcGrpsISkkDrGl
         2N5NbZBGj7/MZ6CxkHl84UNVerkMjznfot9bDAuAa/vYbrhf5YcWiaDb5GXauNAK8zYn
         DVjipuOt/7ypuyE2/2Lug/9H5IoOjTLerBYq/sMqlvGwYdQ2N8zWKhhHNL1Bh4E7yM7S
         gvG31k668MOiVg7an3syJpdxzy2KZpKltCeB3AWaRXwRP+pRSkcAcQQ1HkHWaZcJIyPm
         C3Ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV2ELJeO/oGss39SEMGP7cdEdFB1/UmlyYnaCMOeTsnwBUj7EUa
	qSYfXomPk/QcznbcHhVwJ26Z2oVITCIOwNQTyov+swZ/rl90PARYG04rytn7MnoAVcNS3HPvMja
	h65QWSG4S6s8fYAwgBVOVPi0sqeM2VWAyey+h/mPlepeLZP83bRcOGVqegW0jkG3LxQ==
X-Received: by 2002:a17:90a:f498:: with SMTP id bx24mr48941460pjb.91.1563417758681;
        Wed, 17 Jul 2019 19:42:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiuNY/low7ViQKlTCoZ3elS7uXD/k3um2MhwxXnsKm69O3UGdYsRDT4o6OVd0mpzOxbgsS
X-Received: by 2002:a17:90a:f498:: with SMTP id bx24mr48941396pjb.91.1563417757833;
        Wed, 17 Jul 2019 19:42:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563417757; cv=none;
        d=google.com; s=arc-20160816;
        b=XhYkfoPsPxfuTpdJ2mPXRs2PEHL8vFYduKFWaYtA1oUxFAaH39hXjitciiAq5rjmBV
         tcly1pQ0k5yqcAGC203yJ5envabEir9hhNFSDDohaPSo2zEpgb+oJ9ZoeGlKvx47NxAw
         hII5aGLs68vz3yU1CdfL9EfK22sK10AUdzIeTmGa4p8sMczsX3Wn6xDNZaT8h2lOXs/r
         ye/hrBJhA7gZ6/JvmLzBKu1t4stn88hrU165WRXWJSdgycT7BxJD4nUh5JTTffteOdo9
         m/G62sLMg6KTCuxPLyWMNvTMn6Awt2F1XsEVcTCHVVM2KbSryeohFLMq4nFzBy2UiEct
         3nIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=8EzvB7i2YoHMyqI+IPD3lTmLkVOKRpq539k5H3z+ISQ=;
        b=Pdlji8YwZiXaFggLAiVr4fWSZsc7+gl5afBe9pVU69tKEf+DgKOclb94p/nIAzVRmO
         u5lC2epBK4NMpczf1nsB+TAREYFRCWz2oHghHs2z3Oy5tAQRigEoeFutdWAfQmOnZcNl
         lvVFG5ece8NNInGJVjIrtLkkTjblha1FUpMOBf4/HBDXAeLWlOef6fC0j2n/bn4QvIPZ
         U2aHC49SIEItx63SIOiroVILFqyxiIL5n4LwjV1KekrzmqILqyPbOCGQpFfqd02+LJ6n
         iknKBGzA9iglCMgty6hR2TMVqnoj8lyB9fvKzMz/Ko3VN+WlhXDHJlAjuvqLuA9SniyG
         Ya5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 7si928178pfh.38.2019.07.17.19.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 19:42:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6I2bkXE097676
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 22:42:36 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ttg4g05pp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 22:42:36 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <leonardo@linux.ibm.com>;
	Thu, 18 Jul 2019 03:42:35 +0100
Received: from b01cxnp23032.gho.pok.ibm.com (9.57.198.27)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Jul 2019 03:42:30 +0100
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6I2gT4Q42598804
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Jul 2019 02:42:29 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D6C30AE062;
	Thu, 18 Jul 2019 02:42:29 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE5C0AE05C;
	Thu, 18 Jul 2019 02:42:17 +0000 (GMT)
Received: from LeoBras.ibmuc.com (unknown [9.85.131.254])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 18 Jul 2019 02:42:16 +0000 (GMT)
From: Leonardo Bras <leonardo@linux.ibm.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Leonardo Bras <leonardo@linux.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in ZONE_MOVABLE
Date: Wed, 17 Jul 2019 23:41:34 -0300
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19071802-2213-0000-0000-000003B290F7
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011449; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01233723; UDB=6.00650096; IPR=6.01015051;
 MB=3.00027769; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-18 02:42:33
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071802-2214-0000-0000-00005F49F2FE
Message-Id: <20190718024133.3873-1-leonardo@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-18_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907180028
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adds an option on kernel config to make hot-added memory online in
ZONE_MOVABLE by default.

This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=y by
allowing to choose which zone it will be auto-onlined

Signed-off-by: Leonardo Bras <leonardo@linux.ibm.com>
---
 drivers/base/memory.c |  3 +++
 mm/Kconfig            | 14 ++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index f180427e48f4..378b585785c1 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -670,6 +670,9 @@ static int init_memory_block(struct memory_block **memory,
 	mem->state = state;
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
+#ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
+	mem->online_type = MMOP_ONLINE_MOVABLE;
+#endif
 
 	ret = register_memory(mem);
 
diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..74e793720f43 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -180,6 +180,20 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config MEMORY_HOTPLUG_MOVABLE
+	bool "Enhance the likelihood of hot-remove"
+	depends on MEMORY_HOTREMOVE
+	help
+	  This option sets the hot-added memory zone to MOVABLE which
+	  drastically reduces the chance of a hot-remove to fail due to
+	  unmovable memory segments. Kernel memory can't be allocated in
+	  this zone.
+
+	  Say Y here if you want to have better chance to hot-remove memory
+	  that have been previously hot-added.
+	  Say N here if you want to make all hot-added memory available to
+	  kernel space.
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
-- 
2.20.1

