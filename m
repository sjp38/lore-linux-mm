Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E1DC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3A76208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3A76208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EF076B0003; Thu, 20 Jun 2019 01:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 377588E0002; Thu, 20 Jun 2019 01:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23FB18E0001; Thu, 20 Jun 2019 01:03:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC15A6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:03:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so2545615eds.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:03:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=rlfuBatknSoexbXQq8Uk9ryMN1twJ+Icien1yK5z69o=;
        b=MPD70coJfKPS+tUHPjKrT4w3/X0oagGyCaP5K5CVLEPL8F0WOBYl37gYW73Xqmfd9u
         WhCpPMbaYUBBdRlXk6crQ8tUtMPIDXCYxEs5Zgl/3tNnVGN3CbhUjuKH/so4bBZQ7Uto
         RrByY4lJ3RcG8nE6OeTYmivOG/zXymUiNzhWY3Y+u9QEzNEhN92KhEFpvstgCeZdx2PX
         zYXQ1fAdZZflXXPGmgwRYZOBOo6eE+xleUZ3KwIn7KZslywDYOyB1Ch8H5se5ABSg3p7
         3jX6o4DXS5WtGQvqyCXDVwEy9k9a67RrNaWTYyvF653L4vEZhTSn9GsU2J8LqgFpca54
         5nwQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWrAm0NxpvCVsQCgJ5+ceeUCt7lPz0owQCVgD5RYczK5wQnyrTY
	5RZV3Qs7+mY7/gXnIDDXwSK0fHyDqv7PGKuEYTdrPT2ci1AHWE6h1e35CyHJuCcI6gb5dGG1BbM
	djyWd5SWONKGus41ujiR5xP7ydFPHEYIwErjb4bAQFLVywZxTnHbamwquRbq8qgg=
X-Received: by 2002:a17:906:951:: with SMTP id j17mr83597779ejd.174.1561007037315;
        Wed, 19 Jun 2019 22:03:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWs7v5ex8MfsZI/25msPFw27oSrlD/BVWV42ajXHj5s2C7jIW7dXzVmPrFKcu9+p08sgNz
X-Received: by 2002:a17:906:951:: with SMTP id j17mr83597696ejd.174.1561007036026;
        Wed, 19 Jun 2019 22:03:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007036; cv=none;
        d=google.com; s=arc-20160816;
        b=TCtPTFuuIFFDo8hTw2SAimuW+8TCNr4aTkNlXfB2OEHX8wLvZcI56tUjJ9aXi2xuZS
         mN+SUUsKUkjsrD7wqqOmriH9IEcNehK1P/JaHWShGL/PvuHIXJ7cmikVTBciMpisAegK
         W1NBr2fe6PMPlHBwVqiBh1ewvw9ZHGlvrgZ78ZvQHDEO0qyANwpT1KjhxePCF8AQ0rK5
         fI86//xfuZ6OMn24yCxKjpFHnf1wWsh5VfFUSEecYr7a39JNWSPx5qViHdES1zhTfVUH
         yTsAz9mJ3QO4pVDLxNG4Y1tdF7ve3XnXrc1uZXtfq7LfdaBdV8DFL/wm9PyhJ04WILLH
         gVZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=rlfuBatknSoexbXQq8Uk9ryMN1twJ+Icien1yK5z69o=;
        b=OFAt13D249O1BCPbQmZb9DbYMZ/Ms/uJU6C7T8yX9aq4Y5ActpUR+QllkiXaJEKV0c
         KQPJ5GiCA4PG2r5n1zjxNae/viuWFdgDCeB46ZwpfsYUo9purqrVGelIVZjLOUi66Fjz
         04g4EowF5PhVnCmKnI9oVD0uXmydtTR7uVuMm+sKT5jNUel9/1QxRZzfV9RmhZpKLBIX
         dc/uw6RfdlXwXFNjqGMp9KXBh9dTi2VqtmWgzLWw5AN9M1+LzyzyqIcowOJAjv4LdC4O
         tlzIU3qp3DBM4+zUFMZ0Q3/ph941H7xqWFxUcAxPNmTCEzugrp5CLqlxIWrJy+PxCMFX
         EfIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id r14si8441523eju.4.2019.06.19.22.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:03:55 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 3D802100007;
	Thu, 20 Jun 2019 05:03:42 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
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
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH RESEND 0/8] Fix mmap base in bottom-up mmap 
Date: Thu, 20 Jun 2019 01:03:20 -0400
Message-Id: <20190620050328.8942-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series fixes the fallback of the top-down mmap: in case of
failure, a bottom-up scheme can be tried as a last resort between
the top-down mmap base and the stack, hoping for a large unused stack
limit.

Lots of architectures and even mm code start this fallback
at TASK_UNMAPPED_BASE, which is useless since the top-down scheme
already failed on the whole address space: instead, simply use
mmap_base.

Along the way, it allows to get rid of of mmap_legacy_base and
mmap_compat_legacy_base from mm_struct.

Note that arm and mips already implement this behaviour. 

Alexandre Ghiti (8):
  s390: Start fallback of top-down mmap at mm->mmap_base
  sh: Start fallback of top-down mmap at mm->mmap_base
  sparc: Start fallback of top-down mmap at mm->mmap_base
  x86, hugetlbpage: Start fallback of top-down mmap at mm->mmap_base
  mm: Start fallback top-down mmap at mm->mmap_base
  parisc: Use mmap_base, not mmap_legacy_base, as low_limit for
    bottom-up mmap
  x86: Use mmap_*base, not mmap_*legacy_base, as low_limit for bottom-up
    mmap
  mm: Remove mmap_legacy_base and mmap_compat_legacy_code fields from
    mm_struct

 arch/parisc/kernel/sys_parisc.c  |  8 +++-----
 arch/s390/mm/mmap.c              |  2 +-
 arch/sh/mm/mmap.c                |  2 +-
 arch/sparc/kernel/sys_sparc_64.c |  2 +-
 arch/sparc/mm/hugetlbpage.c      |  2 +-
 arch/x86/include/asm/elf.h       |  2 +-
 arch/x86/kernel/sys_x86_64.c     |  4 ++--
 arch/x86/mm/hugetlbpage.c        |  7 ++++---
 arch/x86/mm/mmap.c               | 20 +++++++++-----------
 include/linux/mm_types.h         |  2 --
 mm/debug.c                       |  4 ++--
 mm/mmap.c                        |  2 +-
 12 files changed, 26 insertions(+), 31 deletions(-)

-- 
2.20.1

