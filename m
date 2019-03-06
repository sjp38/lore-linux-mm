Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 045ECC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C066B20645
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:00:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C066B20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7174D8E0006; Wed,  6 Mar 2019 14:00:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C7188E0002; Wed,  6 Mar 2019 14:00:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B6B38E0006; Wed,  6 Mar 2019 14:00:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 01B6C8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:00:24 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 29so6708638eds.12
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:00:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=BfWJYZ2J24t6kH8BtPo7VG82cFv6GMI/3MLWu1tNCfU=;
        b=IInGPOgMeQ9+ZqafTEeQ+jceyB67t7X/IOOPJwziIr220z2jnLUfg2rqMtKTObwtiC
         LWJeX4QUuBJsE/AmQ+4GFcL8ZDCnzq+t5IXpU+Qf4dn9SoaH934CyYZbTfkjYFQ3uZxa
         S3TJT4dqdtTfUyrZ/6k/gqWfukOQqBZhVl9R2Hr83Wr1wYg2/l/aybhytYBNwnhH0+kS
         NDc45LEWWPl1oX0UJfrKA51eJzcPq8i21PS0TM9cx2qVU9hyrqRQoVmEttzD7TlAhoSB
         RXSpfHcRW2+d6uqnTPo3bbGuLkcUU09dKMTRnBAj4k/FkO7PxzSBIBcrETiiCbCx2MBE
         Y1WA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXB/F7jWttNZ5QQ5XoIr7pNoQGpZchBDS2V96ULfVAvBXdrHvCo
	Jp9cJ5IgvpNJ6hbmZaZM34X7P0PBs46RcIX2y1wlwB0E1/x01rhEmNS9KGw7B/qEvc1tgsMRBJz
	ijzzvbjdrUyshn2GSaiO/7mffdiYHOWgxJoTTsBdqcEadbNGnZUPx+GlJAB8UzOg=
X-Received: by 2002:a50:b646:: with SMTP id c6mr25146023ede.149.1551898823157;
        Wed, 06 Mar 2019 11:00:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqw52DvU3j2NXzyHRWLJbUrVeC0VgvTOzyVQjo6HlyTEEbQ48lJa7qQkz1CGmIPYZEgnvyFo
X-Received: by 2002:a50:b646:: with SMTP id c6mr25145930ede.149.1551898821352;
        Wed, 06 Mar 2019 11:00:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551898821; cv=none;
        d=google.com; s=arc-20160816;
        b=mbvEoCRRTvn1MAu/vjhxibrE8QAheDVZ6mdGhnr7RDyg8PzQK+OQgAZ326sfTTQiuQ
         /QBVz6EQIKt+cibYucgfXEw8nIEzeVEiW4QOYSAQaxeb6GNvRD17jImtczRQuSWPJjUI
         Ya5ZKk/YfddGwWHrf8J+9pKdktiJC+f+36f0sMRFUpedsm0k3QzycdELVdAc86vvFfcJ
         CxxdcVUgU8nWQ5V4RwJpZstax6gWi5hCYhfNQaFv4FPmwLRAON3FtXNXjGRy0MmVR8K4
         00NjGRxms3BpSCaZfOZRpR67nH30y7/FkM4JqdPTT7+Buio/mMBzoJLnE5lUIXbHYf11
         Juwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=BfWJYZ2J24t6kH8BtPo7VG82cFv6GMI/3MLWu1tNCfU=;
        b=jklDta2ln2p8p5vCwLPZQta0I7K8t5yxYKEEdtbiVaE5I3nDnulSRKzHCPk0t2FSL2
         AFjwzQkOrwsm8KX1n4rxG0WEHXPeLp7cyzzXrvVNbTrxMlrotxCGvsniwmvqprskG6D8
         wD8lNivr45WKWJWBtlV8Gnd1a72Nzf+9IG994s43iAJAqV/0PihKgDnKck9Cnc/+T18s
         Z10EzxhY2yD4PGVCjXNMZd1QjqI3/AEArNCONIqy2ki36zTmOKEX4sNgmFqCug87/gJc
         ceW+miYya+qGtHyqSpgVZ4V3S07hRE2ukD+YpYKAVUdi5HPQLeccZtgqiNukSaqwF9ln
         TrhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id w27si987578edi.262.2019.03.06.11.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 11:00:21 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 8D8ED24000D;
	Wed,  6 Mar 2019 19:00:06 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Vlastimil Babka <vbabka@suse.cz>,
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
Subject: [PATCH v5 0/4] Fix free/allocation of runtime gigantic pages
Date: Wed,  6 Mar 2019 14:00:01 -0500
Message-Id: <20190306190005.7036-1-alex@ghiti.fr>
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

*** BLURB HERE ***

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
 mm/hugetlb.c                                 | 54 ++++++++++++--------
 mm/page_alloc.c                              |  7 ++-
 15 files changed, 48 insertions(+), 50 deletions(-)

-- 
2.20.1

