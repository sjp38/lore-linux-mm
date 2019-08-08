Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C197C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFB1217D7
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:53:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFB1217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 660836B0008; Thu,  8 Aug 2019 03:53:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60FB96B000A; Thu,  8 Aug 2019 03:53:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FF316B000C; Thu,  8 Aug 2019 03:53:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1890B6B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:53:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so58504371pfc.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:53:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=4Cn12r9OX9wL6vQp492Xp9qM2ktAqHqEiUHONLQCdAI=;
        b=oqf9zbXbyViZjSGCuOrEEKPQltFmAEV+NQJkmU7F/mXbSDzwcTjLkJz4SIasSH3oEP
         D5iOFlEbrvpSjgIlR3I+G5Qs4hXhfts05Lpt+iLfx68ONgPtOQptnEPTaM4Bu3bMvuGo
         YV3yEvF1wcpalL+0UpJLXkJRwa42AAK8D1kEb98ChaU0lXgOVWIfxkSgvgA9NO9vvClB
         zmA1Q2RMovb8w8L39orDMk8KkSMxzei4P5rGA+ZmbjB84ZXHQ87AA9gLoZRyWDY8nt5G
         FArKsccee/CH/hL1vqtetrZMqWX5D3NtlCqzNTAXjGeTIb4MECuX2YHVQKcJvnU3JZma
         7BTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW25NbEbLFAgajbKQWFVCAcKySLkFbHS6HZcgvepsh3JgvUwqyg
	pSE8abje2fRHFJtaeV3vEHJ2FwRavlTRNbNTpBVajbGMgd7cBPeePterVaH5n//RjSKC4+PSJKG
	Mr91xoTtDN3KXmq2qqnNVKCqzTa5sRRZ6W3NE9hgglhDrjQ0Mftki/29wxYvANxdFwg==
X-Received: by 2002:a62:483:: with SMTP id 125mr14399752pfe.245.1565250801725;
        Thu, 08 Aug 2019 00:53:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi7B1H45a8GY1Y0nsTdSB7m/mytQJJj/lT6gRnnHo2i0h+XW+umMS3ZSV4af4Qmrq3T2Mk
X-Received: by 2002:a62:483:: with SMTP id 125mr14399714pfe.245.1565250801037;
        Thu, 08 Aug 2019 00:53:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565250801; cv=none;
        d=google.com; s=arc-20160816;
        b=K0gwphxm0LNww5lEDBl4Nz0+HgIhZSqvDnPXysDLgzsRQPn7h+MvBn7IID+z0rH3UD
         PqZ4jkten1bfZp3Qb5LrLSb6Sntd2d/QD0W/f/FdVq3BKyZbpIFmOZbiaeMnmaR2If9t
         VaSeeMwdZdR6g8vYnK0qHlJVW33cYK7Z4xPsqCtgXtSGClq8pBBFTeG+OXBbVYB6GYMR
         UQFpVyTh0aaM4WBYYsqT4xAVdCL07A7DP0ZYM1qtKark9/+f7onLf1CezQybifwJlN7h
         r4km5jGQ1V8AphUJlmBFodK3pEhTHuWwjbGviVCQU47CH2e+r/wSe7CycsftvAUB6uYu
         2Z6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=4Cn12r9OX9wL6vQp492Xp9qM2ktAqHqEiUHONLQCdAI=;
        b=ihYjSGjpjthv1CjHnAq+z+aqPF0CS5Z8aVQXJJBHx+ajEyomCstzFmgJ5yJHL1QL+M
         DPDxdi8l1CnJc3s/km6r87dro29VVDaBmKc7o55qRbTTx3tlNdRla/WkHQhgm6kRf/oc
         3dQ1Y/fzhnHHHoK9wGrQ1CjdaQXZ7VDFz3V9MZovEkeRVRqssY37QtYHn2qHQs6puAJK
         PKAs2dnVFBhVgfY0GKi0+kvsXw2ZBXQqFj1lz+/5YyFasms8wn58VGJpxJKfhl4ggIoO
         kMrYWD7u/pkwgzDoNnsa9fO+5MmnV7hMGgyzYheirLIT1Tzfu9rJrN5ViQy48f1KpBFB
         pUbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z14si1359455pju.64.2019.08.08.00.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:53:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x787rBWH012911
	for <linux-mm@kvack.org>; Thu, 8 Aug 2019 03:53:20 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u8e1f3ynd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:53:17 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 8 Aug 2019 08:52:16 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 8 Aug 2019 08:52:12 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x787qBCv41943078
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 8 Aug 2019 07:52:11 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 636E842045;
	Thu,  8 Aug 2019 07:52:11 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B04B142047;
	Thu,  8 Aug 2019 07:52:09 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  8 Aug 2019 07:52:09 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 08 Aug 2019 10:52:09 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Tony Luck <tony.luck@intel.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-sh@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/3] mm: remove quicklist page table caches
Date: Thu,  8 Aug 2019 10:52:05 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19080807-0020-0000-0000-0000035D2ABA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080807-0021-0000-0000-000021B22C72
Message-Id: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-08_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908080090
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I while ago Nicholas proposed to remove quicklist page table caches [1].

I've rebased his patch on the curren upstream and switched ia64 and sh to
use generic versions of PTE allocation.

[1] https://lore.kernel.org/linux-mm/20190711030339.20892-1-npiggin@gmail.com

Mike Rapoport (2):
  ia64: switch to generic version of pte allocation
  sh: switch to generic version of pte allocation

Nicholas Piggin (1):
  mm: remove quicklist page table caches

 arch/alpha/include/asm/pgalloc.h      |   2 -
 arch/arc/include/asm/pgalloc.h        |   1 -
 arch/arm/include/asm/pgalloc.h        |   2 -
 arch/arm64/include/asm/pgalloc.h      |   2 -
 arch/csky/include/asm/pgalloc.h       |   2 -
 arch/hexagon/include/asm/pgalloc.h    |   2 -
 arch/ia64/Kconfig                     |   4 --
 arch/ia64/include/asm/pgalloc.h       |  52 +++--------------
 arch/m68k/include/asm/pgtable_mm.h    |   2 -
 arch/m68k/include/asm/pgtable_no.h    |   2 -
 arch/microblaze/include/asm/pgalloc.h |  89 +++--------------------------
 arch/microblaze/mm/pgtable.c          |   4 --
 arch/mips/include/asm/pgalloc.h       |   2 -
 arch/nds32/include/asm/pgalloc.h      |   2 -
 arch/nios2/include/asm/pgalloc.h      |   2 -
 arch/openrisc/include/asm/pgalloc.h   |   2 -
 arch/parisc/include/asm/pgalloc.h     |   2 -
 arch/powerpc/include/asm/pgalloc.h    |   2 -
 arch/riscv/include/asm/pgalloc.h      |   4 --
 arch/s390/include/asm/pgtable.h       |   1 -
 arch/sh/include/asm/pgalloc.h         |  44 +--------------
 arch/sh/mm/Kconfig                    |   3 -
 arch/sparc/include/asm/pgalloc_32.h   |   2 -
 arch/sparc/include/asm/pgalloc_64.h   |   2 -
 arch/sparc/mm/init_32.c               |   1 -
 arch/um/include/asm/pgalloc.h         |   2 -
 arch/unicore32/include/asm/pgalloc.h  |   2 -
 arch/x86/include/asm/pgtable_32.h     |   1 -
 arch/x86/include/asm/pgtable_64.h     |   1 -
 arch/xtensa/include/asm/tlbflush.h    |   3 -
 fs/proc/meminfo.c                     |   4 --
 include/asm-generic/pgalloc.h         |   5 --
 include/linux/quicklist.h             |  94 -------------------------------
 kernel/sched/idle.c                   |   1 -
 lib/show_mem.c                        |   5 --
 mm/Kconfig                            |   5 --
 mm/Makefile                           |   1 -
 mm/mmu_gather.c                       |   2 -
 mm/quicklist.c                        | 103 ----------------------------------
 39 files changed, 16 insertions(+), 446 deletions(-)
 delete mode 100644 include/linux/quicklist.h
 delete mode 100644 mm/quicklist.c

-- 
2.7.4

