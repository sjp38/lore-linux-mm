Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53A7CC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18019218A0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18019218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33E3A8E0004; Mon, 17 Jun 2019 00:38:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29E0E8E0001; Mon, 17 Jun 2019 00:38:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F18D8E0004; Mon, 17 Jun 2019 00:38:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB8578E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:07 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so5267774pld.17
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:38:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=pHHqDgSmDhkmuuAn61xIwvRBD6Ngo7T4bwQJ4yY+RH4=;
        b=NdiM9lPfnyEsBpSBejXQj5o4KnbFELUfvklkDA0vlNI1VQgiTwivbiJHztzqNj3aeN
         jpy1CSqnKR6tauRHija+THzBTdu06eAeobvIxXf7SV6+RhyBTLlMK/B2EWNI8CYQEmtl
         jzcMpj3NLAWfCap7HebPbHuE6Pd5gq6G3iu53f6gFMvLUNuNfYjVtTC0e/HTzzvUJJGv
         IcN04uvF4Vl+DNKEuDymWy/0KmKkK5rcx7/4JS04wu7XUkPIOJMt9d+ht9N/2vrB+DIv
         6LO5mRvd0YMofpu1v/3Ntgb4HP8KwLr/HNHzaKRS5nLqIMtwEPsHvbZZyXnXSg2oh3XD
         vveA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVnXiXB1cqZkme2cnxX7JcpdwSIwcyfkmgTZ+iK2O6OwSND0M8V
	MFRVnxwaNrlour6Kg9nc2kzSbv+9OancJ+sD7w9g7FmXLc/7jzXaaNbIZqJoVcJG86WgqTqnfNP
	UJkcarOx3c1k0+oumpiG8U9w7zuTHsKLz+BQisCXqRiYLJrI5arklcgi1eBigvOaO8A==
X-Received: by 2002:a17:902:8d89:: with SMTP id v9mr82654296plo.99.1560746287453;
        Sun, 16 Jun 2019 21:38:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzX8E1I2HHmkW3Nd5PF+7AK+4rbH9PdjF4A7+q65vfhl9eIXArreSNtWD3/KDqiZr1zHsZY
X-Received: by 2002:a17:902:8d89:: with SMTP id v9mr82654261plo.99.1560746286776;
        Sun, 16 Jun 2019 21:38:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560746286; cv=none;
        d=google.com; s=arc-20160816;
        b=xkPkR+kQpYt6RmoeLW1FbjXQiCjP0gONhMc2uHeZnWeJ4MRWI1BLx30qRuMwdVtJFd
         fXD1yA6u37wfd8ddFSlGVZA1G4obCgaKli9+ka1j9pe8LiSqWZUsan34Qo4RfaR5MMSD
         UCAR1GbsOQAUJ0CcrtGdcOLlt/n4C7qUiYOmGcUu7DbYfOZwcxDP2MarRl77loSlbBtt
         rP0ASAPPS7XMm5xRBBgNhe3Q5HYShK+v812orN1vrY6ypc9QrVuY4zlnVr4ouykdae71
         DZzg0dT4sWLAgP1d44T0kgKRZK7kpwG/P8groPvrWYHaU7W+4ZM7KTuuq/2CWCMxR0v+
         jkUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=pHHqDgSmDhkmuuAn61xIwvRBD6Ngo7T4bwQJ4yY+RH4=;
        b=DESH+RiHdLGNA3oBZOosR6Pf7ODlyfou6TbQuh8QNYRTj2hfmJIjx/C9tU70KNPnTo
         i3p/ayFNtnwhUo8hFxpUvTn8bIWDt7IjIf35e4SBBU7A99GCTKBLZEUhlE+Pl8s8hrAz
         ySHDT6DmUQfUOMJpB1v4Ww6hAH/g6AFBf9z3CKmQOmddpUPW0tG4Y1df7GwZh2ZyzF1G
         Rx6K0LRT2qTxTc0G0hHGnImZyxqoLMh47aKhxic/7IOxaR/c3m7LRvUYo96jyrndSzVp
         brqpL3KOThEIcfxdDL9qrlZg9tX1sWqaO+eHMkql3qJIibnKoYnj9ccLsmE5CsEKL5of
         U9nA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u1si512511pjv.86.2019.06.16.21.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 21:38:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H4bY9O128432
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:06 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t61jckvka-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:05 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 17 Jun 2019 05:38:03 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 05:37:57 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H4bukV29622568
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 04:37:56 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C969352052;
	Mon, 17 Jun 2019 04:37:56 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8160B5204F;
	Mon, 17 Jun 2019 04:37:56 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 7A68EA0208;
	Mon, 17 Jun 2019 14:37:55 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>,
        Josh Poimboeuf <jpoimboe@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Jiri Kosina <jkosina@suse.cz>, Mukesh Ojha <mojha@codeaurora.org>,
        Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 1/5] mm: Trigger bug on if a section is not found in __section_nr
Date: Mon, 17 Jun 2019 14:36:27 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190617043635.13201-1-alastair@au1.ibm.com>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061704-0020-0000-0000-0000034AAC24
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061704-0021-0000-0000-0000219DEF14
Message-Id: <20190617043635.13201-2-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170042
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
 mm/sparse.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index fd13166949b5..104a79fedd00 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -105,20 +105,23 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
 int __section_nr(struct mem_section* ms)
 {
 	unsigned long root_nr;
-	struct mem_section *root = NULL;
+	struct mem_section *found = NULL;
+	struct mem_section *root;
 
 	for (root_nr = 0; root_nr < NR_SECTION_ROOTS; root_nr++) {
 		root = __nr_to_section(root_nr * SECTIONS_PER_ROOT);
 		if (!root)
 			continue;
 
-		if ((ms >= root) && (ms < (root + SECTIONS_PER_ROOT)))
-		     break;
+		if ((ms >= root) && (ms < (root + SECTIONS_PER_ROOT))) {
+			found = root;
+			break;
+		}
 	}
 
-	VM_BUG_ON(!root);
+	VM_BUG_ON(!found);
 
-	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
+	return (root_nr * SECTIONS_PER_ROOT) + (ms - found);
 }
 #else
 int __section_nr(struct mem_section* ms)
-- 
2.21.0

