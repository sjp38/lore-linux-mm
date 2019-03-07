Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46097C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:20:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F1E82081B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:20:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F1E82081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D5358E0004; Thu,  7 Mar 2019 08:20:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9867D8E0002; Thu,  7 Mar 2019 08:20:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875248E0004; Thu,  7 Mar 2019 08:20:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 324918E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 08:20:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 29so8012191eds.12
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 05:20:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=lVTZ4imBtKZC+hfTYze7WWtrbKrEBxNSoCcd375OhOc=;
        b=dgEVAGDJwQaamPIMnEsQPmh8Z3+Rd5C8OB8I4CVRYV7/hkZhrtKsdkfokGs/R+5MVZ
         L4n4qldeqRL/dsJzyPm2HSTUvoJbzRQuwnFWJrCGXZU2TKllDz3Cu4tJ2TnzWt6ssbtf
         mXsnOlgvPBgUR3hJwgGO3EdJoc7xe3Hg3ICqdl/UE/sXH1f5ZCD2VRFtPawLlF0Lmedt
         w0Fru1h2HPPu8qIcoH7JUU54jVuKAl3bb+LB2RbsUXFamtZxbM7yaC09h91JXfvKxN/O
         Q/e2KvXyWdoh6Vm7yLrzAXHa8Lm0tRxUV6tvcJY+mHeqgjYJI/euer2+8nB+c5aisvO8
         P+FA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUWZ9xjV+4Z4M5uFlsC7v1MTo8kj1NUEye6kH6nmsh63QCPbmbw
	cZdH9DbzLZQZl37UCpatnDYvr/cEfYZ4+yBoUPgKIIrVDn/djklpwo241PbTdY+KgmoJQjPmKeN
	sLRakbA7bL9saLvf1KTv+Bt45SVnIqmjgdekHKpecxrL3aIY5wEuufcKdR8iD2Vs=
X-Received: by 2002:a50:b482:: with SMTP id w2mr28383357edd.41.1551964828335;
        Thu, 07 Mar 2019 05:20:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqw5fEp6AHWZNmPQmfoS9xaujVp83YvNsj0B9tdfvTl1/rm0YoMD4TtTsiA9JM3cPRy3H+JJ
X-Received: by 2002:a50:b482:: with SMTP id w2mr28383274edd.41.1551964827055;
        Thu, 07 Mar 2019 05:20:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551964827; cv=none;
        d=google.com; s=arc-20160816;
        b=VHdfx6oGcqpRcjzN+DzCCwFbcJvRYY5ZkaGseE8mQZkFDtDq6i8KRS1eeXeUsw8X74
         K+U+dSCa3chzfX0O3xGV63ct+SeZ5GZOKInTCqYomTVAs+kLl1EMmUAMVZ4N3Kmzbal1
         Yk4jXh8tcUuxkRPUeWAxaoDYXwfMhlbIu09E4AI1+tfWPP7HVz4lp9eTu7A9/JN4SrAt
         m8mf+hpJUGBDY9iiLFxvr84s71eQgx1vqMYFZoKolU88q4mGmS8NtwEOWCyeycHuTXp9
         gsvJJxSddLr5yl5xsWQ8YD6yApeicZwKnq8uQ6YpQheYU23xBD2jMDl4HVlU0gqHN+lR
         7zew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=lVTZ4imBtKZC+hfTYze7WWtrbKrEBxNSoCcd375OhOc=;
        b=g9lFdkq/c2FlpFrgn5OE8T9f9EI/+P1KCNbYGFByxrMpNVqBLkIGnfj+8bSbPEzr+Z
         Wj8nuk1LuowVAVkDz4eyC9v+3wOYiql0H8M8EmAr7wgbXSZsfdgeJNULYNNUKwNXuq/k
         xOGBoC3cqRWQcHzg8IIYmlarVdOc0QKXJah0kvLd9M0xNZUR5XYNwmqja+W8hhJMhDAR
         cW102zKJUO1tn4ryGZW06i5JMf/ZwacYLSvglwbEojgB1t9q20k4zV5Fd4MghwQSmfJ9
         D5Vz8jLWGiYOfPVLbYz09E3Z3Yy74md1iG9Hd9dpMnW2WFzt0CsBT4qybNnJz2Hmgy8D
         9OIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id x37si509402eda.332.2019.03.07.05.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 05:20:27 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 48D78FF807;
	Thu,  7 Mar 2019 13:20:17 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 0/4] Fix free/allocation of runtime gigantic pages
Date: Thu,  7 Mar 2019 08:20:11 -0500
Message-Id: <20190307132015.26970-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series fixes sh and sparc that did not advertise their gigantic page
support and then were not able to allocate and free those pages at runtime.
It renames MEMORY_ISOLATION && COMPACTION || CMA condition into the more
accurate CONTIG_ALLOC, since it allows the definition of alloc_contig_range
function.
Finally, it then fixes the wrong definition of ARCH_HAS_GIGANTIC_PAGE config
that, without MEMORY_ISOLATION && COMPACTION || CMA defined, did not allow
architectures to free boottime allocated gigantic pages although unrelated.

Changes in v6:
- Remove unnecessary goto since the fallthrough path does the same and is
  the 'normal' behaviour, as suggested by Dave Hensen
- Be more explicit in comment in set_max_huge_page: we return an error
  if alloc_contig_range is not defined and the user tries to allocate a
  gigantic page (we keep the same behaviour as before this patch), but we
  now let her free boottime gigantic page, as suggested by Dave Hensen
- Add Acked-by, thanks. 

Changes in v5:
- Fix bug in previous version thanks to Mike Kravetz
- Fix block comments that did not respect coding style thanks to Dave Hensen
- Define ARCH_HAS_GIGANTIC_PAGE only for sparc64 as advised by David Miller
- Factorize "def_bool" and "depends on" thanks to Vlastimil Babka

Changes in v4 as suggested by Dave Hensen:
- Split previous version into small patches
- Do not compile alloc_gigantic** functions for architectures that do not
  support those pages
- Define correct ARCH_HAS_GIGANTIC_PAGE in all arch that support them to avoid
  useless runtime check
- Add comment in set_max_huge_pages to explain that freeing is possible even
  without CONTIG_ALLOC defined
- Remove gigantic_page_supported function across all archs

Changes in v3 as suggested by Vlastimil Babka and Dave Hansen:
- config definition was wrong and is now in mm/Kconfig
- COMPACTION_CORE was renamed in CONTIG_ALLOC

Changes in v2 as suggested by Vlastimil Babka:
- Get rid of ARCH_HAS_GIGANTIC_PAGE
- Get rid of architecture specific gigantic_page_supported
- Factorize CMA or (MEMORY_ISOLATION && COMPACTION) into COMPACTION_CORE 

Alexandre Ghiti (4):
  sh: Advertise gigantic page support
  sparc: Advertise gigantic page support
  mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA into CONTIG_ALLOC
  hugetlb: allow to free gigantic pages regardless of the configuration

 arch/arm64/Kconfig                           |  2 +-
 arch/arm64/include/asm/hugetlb.h             |  4 --
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
 arch/powerpc/platforms/Kconfig.cputype       |  2 +-
 arch/s390/Kconfig                            |  2 +-
 arch/s390/include/asm/hugetlb.h              |  3 --
 arch/sh/Kconfig                              |  1 +
 arch/sparc/Kconfig                           |  1 +
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/hugetlb.h               |  4 --
 arch/x86/mm/hugetlbpage.c                    |  2 +-
 include/linux/gfp.h                          |  4 +-
 mm/Kconfig                                   |  3 ++
 mm/hugetlb.c                                 | 57 ++++++++++++--------
 mm/page_alloc.c                              |  7 ++-
 15 files changed, 50 insertions(+), 51 deletions(-)

-- 
2.20.1

