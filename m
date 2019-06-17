Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C005CC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88CB02187F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88CB02187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22A5E8E0003; Mon, 17 Jun 2019 00:38:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DBE98E0001; Mon, 17 Jun 2019 00:38:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07C758E0003; Mon, 17 Jun 2019 00:38:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFF778E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d19so5295656pls.1
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:38:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=WSS1FEP37Kte2pRR388DKHXWBjbnavnMHYRtwqciyFc=;
        b=JOYUFHV/F9ul92nth13KMbmYhhTzBdKdMVeIucTfWZyHeG26KUvTgR0ndIJoQxHy7z
         1SyIDIn+MnYp/UBYFTWhRKJFpbOk1hrNIaXxuoX/LzSm3pBrpp7eavw1M6YkTZ3lqwjg
         ntNmFszOV+L4Hyj9QjKDsc4frdp622XzOMlpoGBZ4jyCyjmqJURr/1mzfvbvgUnBVVIT
         go4anJ5ZA6WsuuNXU/8AuktCRTTGGl551uIC3BS5ANN8+ohwLou9fu/WWu2Gb8/5iByU
         PLYIf5H6JNb3iQNo0I3qjQSApF/y1uhDTigsMH4cEZUmHUlie7uxFmX7S6jhD/FZ8H6Q
         2NUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWYNaEQ6fvrdVbaA+zzShjgpa+iuX/6xTW+WoxsXIBUIY6OMql+
	oA7q8a0ZOL1BMQKvuTY+GHRSxyzpvw0bfQKQk5wVISd5Bg69trKq/8gYjQrbBl6zR9t9t/I6nPj
	sDfUnmZtKoTYJTlt8B7EOqU8WiNEaTnegUyzT3MHYoXX0q0ywoigcbjqBqouO9znweQ==
X-Received: by 2002:a17:902:b094:: with SMTP id p20mr40368577plr.337.1560746286345;
        Sun, 16 Jun 2019 21:38:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLmoj141syWbxPHep+phBJMhJrJFRWM4Kq6eWpSyc9YD9tOkdz5sBpt+tY1nV85t9+Wik5
X-Received: by 2002:a17:902:b094:: with SMTP id p20mr40368539plr.337.1560746285565;
        Sun, 16 Jun 2019 21:38:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560746285; cv=none;
        d=google.com; s=arc-20160816;
        b=U+d0MMyu5VcEOGMb6DlT+j9q4VEsHtRhr9C37yLw/wH2VkvWyM8bwqJBbFKktclBfe
         HY47hzwMKjFDYak2R0xxVCpK7tIM7ZjofXSVkYR707xbcHXmNrggKy1taYXzPcC+8zC8
         jkmVrZw4ZvI37dag2RxkHt+q1y2zb8GSIIMv/FSEc3d4C9Ki1c6qZrFlWD+LFEhaPrve
         lP5t/6+EskpeDg1udj42J6CyyYEM3CjnQZAJtdYYkvtGIZsuJ/Ot58xKi0bFqP1AMSAO
         W4vZ7QPaguFLyM0hkUbf03+XQFdT/zxO7oR3EsEIl2KhZ+PasCHd+Su1qICNtl17puFU
         BDRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=WSS1FEP37Kte2pRR388DKHXWBjbnavnMHYRtwqciyFc=;
        b=f5pyCqVFO3ADJKlvm1ED5W3VcAoSyKV0e1ByHWqxMpjFG4Q2Q5DmwLdj1RAZe6oc2s
         l4p5y0pCMyzqRupy8zVenGDrIFHrpJkdOe05h/xH5fYbvk2IIOtePUwRmgd3Tll6YIMP
         syfUBFNS2eyGX9rSDTuNxvyW/9iPyovfp/kLviSgDLkUh/bC+U5Xwp7RIhsk24FA079g
         M3nrmWT6y0Tl+AiZ972bU+e1zcJd22DyenPvatNieI+1W5uOyoUoUgCRkblJgzhKdMjW
         V4DbzDUwgi6mvoNnK3Bs/i45Nn9erpSPMPKm+bpuQNKtxMzx9xNz7yTiNXpESxhNBbl+
         cwfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l64si4064193pjb.93.2019.06.16.21.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 21:38:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H4buk4128556
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:04 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t63wxg4k7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:04 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 17 Jun 2019 05:38:01 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 05:37:55 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H4bsib51904688
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 04:37:54 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 82EFE42041;
	Mon, 17 Jun 2019 04:37:54 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 307084204B;
	Mon, 17 Jun 2019 04:37:54 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 17 Jun 2019 04:37:54 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id DEDC7A0208;
	Mon, 17 Jun 2019 14:37:50 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.com>,
        David Hildenbrand <david@redhat.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>,
        Josh Poimboeuf <jpoimboe@redhat.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>,
        Mukesh Ojha <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/5] mm: Cleanup & allow modules to hotplug memory
Date: Mon, 17 Jun 2019 14:36:26 +1000
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061704-0016-0000-0000-00000289A7C9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061704-0017-0000-0000-000032E6EEDB
Message-Id: <20190617043635.13201-1-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=441 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170042
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

This series addresses some minor issues found when developing a
persistent memory driver.

As well as cleanup code, it also exports try_online_node so that
it can be called from driver modules that provide access to additional
physical memory.

Alastair D'Silva (5):
  mm: Trigger bug on if a section is not found in __section_nr
  mm: don't hide potentially null memmap pointer in
    sparse_remove_one_section
  mm: Don't manually decrement num_poisoned_pages
  mm/hotplug: Avoid RCU stalls when removing large amounts of memory
  mm/hotplug: export try_online_node

 include/linux/memory_hotplug.h |  4 ++--
 kernel/cpu.c                   |  2 +-
 mm/memory_hotplug.c            | 23 ++++++++++++++++++-----
 mm/sparse.c                    | 28 +++++++++++++++++-----------
 4 files changed, 38 insertions(+), 19 deletions(-)

-- 
2.21.0

