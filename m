Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3941C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:51:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9535D2396B
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:51:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YeDYM8WA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9535D2396B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3352C6B000A; Tue, 20 Aug 2019 03:51:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E58A6B000C; Tue, 20 Aug 2019 03:51:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FB406B000D; Tue, 20 Aug 2019 03:51:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id F39406B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:51:35 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 715F6180ACF05
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:51:35 +0000 (UTC)
X-FDA: 75842036550.07.flame96_48086d413c863
X-HE-Tag: flame96_48086d413c863
X-Filterd-Recvd-Size: 4042
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:51:34 +0000 (UTC)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7K7nE1b029410
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:51:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=NdN+ZDMV6cVKAsWdTWSaLrD9VOB5N6fSXCo/EOCkxFQ=;
 b=YeDYM8WAG3No/5UtcvOxnM31qeYGu3zCPpWpcFoxyjehF3LmYVMqebhG8fBuWF3t+N24
 wV3pAeo8mct0Zp1R2KTVymmuZ7jTyBwj+LGthGU8KOap4QrVAIMgVKJbW9A5xDpjOTWh
 vQNnPEuJqRM+pdqksRK/jcwIK0PREaU9Pv4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2ug5t3sc6v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:51:34 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 20 Aug 2019 00:51:32 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 0559462E2CCB; Tue, 20 Aug 2019 00:51:31 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <kernel-team@fb.com>, Song Liu <songliubraving@fb.com>,
        <stable@vger.kernel.org>, Joerg Roedel <jroedel@suse.de>,
        Thomas Gleixner
	<tglx@linutronix.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Andy
 Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH] x86/mm/pti: in pti_clone_pgtable() don't increase addr by PUD_SIZE
Date: Tue, 20 Aug 2019 00:51:28 -0700
Message-ID: <20190820075128.2912224-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-20_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=588 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908200083
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pti_clone_pgtable() increases addr by PUD_SIZE for pud_none(*pud) case.
This is not accurate because addr may not be PUD_SIZE aligned.

In our x86_64 kernel, pti_clone_pgtable() fails to clone 7 PMDs because
of this issuse, including PMD for the irq entry table. For a memcache
like workload, this introduces about 4.5x more iTLB-load and about 2.5x
more iTLB-load-misses on a Skylake CPU.

This patch fixes this issue by adding PMD_SIZE to addr for pud_none()
case.

Cc: stable@vger.kernel.org # v4.19+
Fixes: 16a3fe634f6a ("x86/mm/pti: Clone kernel-image on PTE level for 32 bit")
Signed-off-by: Song Liu <songliubraving@fb.com>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
---
 arch/x86/mm/pti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index b196524759ec..5a67c3015f59 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -330,7 +330,7 @@ pti_clone_pgtable(unsigned long start, unsigned long end,
 
 		pud = pud_offset(p4d, addr);
 		if (pud_none(*pud)) {
-			addr += PUD_SIZE;
+			addr += PMD_SIZE;
 			continue;
 		}
 
-- 
2.17.1


