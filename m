Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20E81C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDCC520881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDCC520881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C6E46B0008; Thu, 23 May 2019 11:03:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 675C56B000C; Thu, 23 May 2019 11:03:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53DFF6B000D; Thu, 23 May 2019 11:03:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B916B0008
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:03:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k10so2976012wrx.23
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:03:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=bVDo0THxeO51nkrrBUawcD/WrYVdCaK6r4AceU5MAFg=;
        b=Z+n8bly27V0ADZ0EIPl9C3hxlIawfIW6GSonhXLXrPNu4/oVgUUsMKf1z0lSrs7F5v
         3sgNR261OFWSZuaBrHILYOwsgOqhwmHQ77Zy/M1z/o2dZz9chWUBzKjTaRxXh11Kh9dH
         kFnBstFi3nQxHJ4KQZHa5322dyS9BvsXDZud1IaYxIE8XPameqz14lWzMTt9ORYD8VNA
         SvQHctFhEQkL+biPoTOzt11TJus0Hf1WuHV7sn0jYnV8TaMz+YsofIT9SfAcBGVD33MP
         nGBRVgE5/2JwzDu2ccbat1Ur/rYhy+6Dhy9IosR0CBxHGPOHfeEp5+JkOpiqTeFlKoLe
         75SA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAU0xrxNPqDYWW+tQvMMKH5PS5Tf27mIzAmNLFLnFABiwxgkcLQF
	zpfr3d/i9hIrsPpzwOPCLCwA7u5Y03YC4Irdw7GhzgOE8gclQ8/LfEXzHa3e0nvZdo9S1xxEKv4
	pzLOpiM8lVlZgJX7lDEajDYI7jUulTpNuqrYvMM05KydojjvhNplM5yN5K//0vnrKXQ==
X-Received: by 2002:a1c:7d8e:: with SMTP id y136mr11847738wmc.129.1558623804529;
        Thu, 23 May 2019 08:03:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJMVvLWNdXlvrHnZ+/BiafuVY2rQnA0BHkTx6YGD2etMuXArlWomTc/WCKURYBrlu0BCIC
X-Received: by 2002:a1c:7d8e:: with SMTP id y136mr11847576wmc.129.1558623803006;
        Thu, 23 May 2019 08:03:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558623802; cv=none;
        d=google.com; s=arc-20160816;
        b=dmv9QNGlHy0ThJN3J8k6MpR+FiGgYMGAgzBLSs2io1I/zxSmYvSAH0UFRCpDcz98Et
         BvmncocltBpRhuOuslOmDT6zT57j/16UP/dJoJ76kf7l80jumMvKFvzQdmUX+ABig4Av
         BPlYEAzF4Jgr8ivwQMoB6E1q6G+j1Ag/mmIiLYXdI39eiB9PZ27s4n5xBd/lcv+3agzi
         l9Jrgs54gikc2c3B/raAqKwEovAc77rTCKa4/uGehiULhQG60apDuLWiOsmPnAGr8W0a
         /dc7z8n9+6xFpNs0R9h4ncZ1tMitSRTAtOfYJvUcsYSQvUQ7sTW3edBsbMERiVqhcVwm
         bxwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=bVDo0THxeO51nkrrBUawcD/WrYVdCaK6r4AceU5MAFg=;
        b=tI3VOSpp2PVkoNv5zSSHZ6BHhTsJCkH6McvXONmg3YMwp8utNEXAoB69eKaH4xhXXr
         3cnBLt75UXPmBP+kiHrgysmna4WjBIernVXUorBoqLgsYvQ6dNE1VTycOeDx3lS/+Xgi
         yS+rnZkgXKgFuwUHFWBneO8MDFQ2RegPEL8OoqdKZFWgWh24cpil0w1pdvi/NYEmBDH6
         iZ7AW6V7afdbLGxnvwo0Xkl4flctIGNqFTQipTBTcOb81tCDoE0d5B+3lb3x9Aww4yP0
         SQH9RyGfQuT04p39l6nOjqw2eNqGd0Vyp5lkMe+KGAljwShqKz/Xj/BmGNofzEKuT56U
         s3kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b7si438742ejb.160.2019.05.23.08.03.22
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:03:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E5FC580D;
	Thu, 23 May 2019 08:03:21 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 852053F690;
	Thu, 23 May 2019 08:03:20 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 0/4] Devmap cleanups + arm64 support
Date: Thu, 23 May 2019 16:03:12 +0100
Message-Id: <cover.1558547956.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Here's a refresh of my devmap stuff, now including the end goal as
well. Patches #1 to #3 are just a rebase of v2, and I hope are ready to
be picked up in the mm tree (#1 is currently doing double-duty in Dan's
subsection series as well). Patch #4 could either go via mm if Will and
Catalin agree, or could go via arm64 with a small tweak to let it build
(but otherwise do nothing) until it meets up with #3 again.

Robin.


Robin Murphy (4):
  mm/memremap: Rename and consolidate SECTION_SIZE
  mm: clean up is_device_*_page() definitions
  mm: introduce ARCH_HAS_PTE_DEVMAP
  arm64: mm: Implement pte_devmap support

 arch/arm64/Kconfig                           |  1 +
 arch/arm64/include/asm/pgtable-prot.h        |  1 +
 arch/arm64/include/asm/pgtable.h             | 19 ++++++++
 arch/powerpc/Kconfig                         |  2 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h |  1 -
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/pgtable.h               |  4 +-
 arch/x86/include/asm/pgtable_types.h         |  1 -
 include/linux/mm.h                           | 47 +++++++-------------
 include/linux/mmzone.h                       |  1 +
 include/linux/pfn_t.h                        |  4 +-
 kernel/memremap.c                            | 10 ++---
 mm/Kconfig                                   |  5 +--
 mm/gup.c                                     |  2 +-
 mm/hmm.c                                     |  2 -
 15 files changed, 50 insertions(+), 52 deletions(-)

-- 
2.21.0.dirty

