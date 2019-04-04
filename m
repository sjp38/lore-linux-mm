Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96AA9C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4938920855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:51:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4938920855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8E8F6B000D; Thu,  4 Apr 2019 01:51:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3C1A6B000E; Thu,  4 Apr 2019 01:51:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C54006B0266; Thu,  4 Apr 2019 01:51:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 790C76B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:51:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c40so777085eda.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:51:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=YdGdDJHeCmQC+RW7k1h8mpRrLzlQKPKkXRLdFADEvXU=;
        b=Ht8jBZBIA/QhT6fhP0rjGpvHfU/oVwJ1o25MoHxuduNStRlUMUJkdyxuouDPF42EJo
         qU6p6d09JM6OT8MkFuzCmkZt3RE9rBHIGIxWbbvafrLUpEJ5GiCj3f/PTidZxRyMm/F0
         pjtTDypbvz2wseMWNe3alZajypuEtCf3MI8Oci5oZAbte39HJJqYJSF6OIQ/w4EYvoTw
         JIX8bNOzXN9piT2IynK63BVu5JQyl2C1LSggV92CN/Oa7ZgJ1k/C+iYgYtJW2G+F9wnG
         kJhpZLm/WTavjRyKSKMlgKD6DJL83+Gid5P1z9SDKmFl7sVUjb3mxEvgSRKE/YqsKRlL
         kxrg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAU2PDrOCup2dzVjOHoepC/Pns3NgviLcuTy8OaEDFK5oSAuntN0
	WSYFBJTFs6APqDIHxvn0eP+oOa1KHIhFjqxDB/suqnvuaRJiWvEtncMnc7e/pI9Ws80ofk+jpCQ
	EorEcpNY19EN2XY6EPLBSPQTQjVKDdzUJ9OSmmK832sZRK/3xHTA+mw05+D/22KM=
X-Received: by 2002:a17:906:4f19:: with SMTP id t25mr2306397eju.165.1554357096975;
        Wed, 03 Apr 2019 22:51:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUHpVPr8P3E4jOpY8gjxVJPipzyE4wvFjJphS6L+K0bkHHcm9GbVtsHKTb49lLMmlx0zl7
X-Received: by 2002:a17:906:4f19:: with SMTP id t25mr2306347eju.165.1554357095859;
        Wed, 03 Apr 2019 22:51:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554357095; cv=none;
        d=google.com; s=arc-20160816;
        b=XLayBCENYNUPI81+ODS72d5ZHITqofqBoa/N3QNSiop5j8bsEZplALYwUNzSU36rHz
         IJtTFejqGG3Cbi69/orv3bxHMueUvozhxc/qdA83FxiVWokBMhEuV3MTwQ7K5sJGfwTp
         B5srDXp5tIs9LJ6FzagegF+ij9V2ww1y7IswxVPEr9vvUvGGlQuUVVfKJWBZiLCis0tO
         lcO7qr65+CU47UFCA8Eqt44MCXUFU+Rgd+BHk+4bHOCt9Z2GDRZuSS2qXR5opM25oGnv
         4E5xfJf3k9snIMmJbeAryBA8Xu7H+u3GrmNYiEREyXLveUhOpMn4zbMGCjOk4MkVFXrn
         ALfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=YdGdDJHeCmQC+RW7k1h8mpRrLzlQKPKkXRLdFADEvXU=;
        b=zvOqsTnv5kja44nEpCb+W3v26xENcYmqyDZgsuUgYX+gJdql1r/zBwKC7rm7/lqF/m
         zPUW6NQ1mEGP9OMXT3pkdkI/2FaW3S9GOgvslzGvtiCukti1nO3OtalptlmXZUMGr0n7
         6fvrJeVzCcT72M2pv9LG/OhDimvDFTlYgm2Tz8RxpwOPbKeyYuANEUZEdxaPIPQLTKrV
         1YB7ZUG9mkIfEyTkQHusMr7cnc7jjj5WKLhoZUARZhKWcSdWroGRwTzSb2NXIsZd27We
         65W3XOfSD4A1p1QSgKSasXq6OAvDBA7Deiu6C8vLRq2ig19ztH0WP32wo+O+nwZwETNj
         rl+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id j30si119188eda.42.2019.04.03.22.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 22:51:35 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id D845CFF808;
	Thu,  4 Apr 2019 05:51:29 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v2 0/5] Provide generic top-down mmap layout functions 
Date: Thu,  4 Apr 2019 01:51:23 -0400
Message-Id: <20190404055128.24330-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series introduces generic functions to make top-down mmap layout
easily accessible to architectures, in particular riscv which was
the initial goal of this series.
The generic implementation was taken from arm64 and used successively
by arm, mips and finally riscv.

Note that in addition the series fixes 2 issues:
- stack randomization was taken into account even if not necessary.
- [1] fixed an issue with mmap base which did not take into account
  randomization but did not report it to arm and mips, so by moving
  arm64 into a generic library, this problem is now fixed for both
  architectures.

This work is an effort to factorize architecture functions to avoid
code duplication and oversights as in [1].

[1]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Changes in v2 as suggested by Christoph Hellwig:
  - Preparatory patch that moves randomize_stack_top
  - Fix duplicate config in riscv
  - Align #if defined on next line => this gives rise to a checkpatch
    warning. I found this pattern all around the tree, in the same proportion
    as the previous pattern which was less pretty:
    git grep -C 1 -n -P "^#if defined.+\|\|.*\\\\$" 

Alexandre Ghiti (5):
  mm, fs: Move randomize_stack_top from fs to mm
  arm64, mm: Move generic mmap layout functions to mm
  arm: Use generic mmap top-down layout
  mips: Use generic mmap top-down layout
  riscv: Make mmap allocation top-down by default

 arch/Kconfig                       |  8 +++
 arch/arm/Kconfig                   |  1 +
 arch/arm/include/asm/processor.h   |  2 -
 arch/arm/mm/mmap.c                 | 52 ----------------
 arch/arm64/Kconfig                 |  1 +
 arch/arm64/include/asm/processor.h |  2 -
 arch/arm64/mm/mmap.c               | 72 ----------------------
 arch/mips/Kconfig                  |  1 +
 arch/mips/include/asm/processor.h  |  5 --
 arch/mips/mm/mmap.c                | 57 -----------------
 arch/riscv/Kconfig                 | 11 ++++
 fs/binfmt_elf.c                    | 20 ------
 include/linux/mm.h                 |  2 +
 kernel/sysctl.c                    |  6 +-
 mm/util.c                          | 99 +++++++++++++++++++++++++++++-
 15 files changed, 126 insertions(+), 213 deletions(-)

-- 
2.20.1

