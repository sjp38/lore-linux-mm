Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94483C4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 16:32:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6361A20693
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 16:32:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6361A20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCE746B0008; Fri, 13 Sep 2019 12:32:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA40F6B000A; Fri, 13 Sep 2019 12:32:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE31A6B000C; Fri, 13 Sep 2019 12:32:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id B15926B0008
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 12:32:54 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6407A180AD801
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 16:32:54 +0000 (UTC)
X-FDA: 75930441468.29.jeans30_366348cf15925
X-HE-Tag: jeans30_366348cf15925
X-Filterd-Recvd-Size: 2559
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 16:32:53 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 72A141000;
	Fri, 13 Sep 2019 09:32:52 -0700 (PDT)
Received: from localhost.localdomain (entos-thunderx2-02.shanghai.arm.com [10.169.40.54])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id DF2B53F67D;
	Fri, 13 Sep 2019 09:32:47 -0700 (PDT)
From: Jia He <justin.he@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>,
	Marc Zyngier <maz@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: Punit Agrawal <punitagrawal@gmail.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Alex Van Brunt <avanbrunt@nvidia.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	hejianet@gmail.com,
	Jia He <justin.he@arm.com>
Subject: [PATCH v3 0/2] fix double page fault on arm64
Date: Sat, 14 Sep 2019 00:32:37 +0800
Message-Id: <20190913163239.125108-1-justin.he@arm.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we tested pmdk unit test vmmalloc_fork TEST1 in arm64 guest, there
will be a double page fault in __copy_from_user_inatomic of cow_user_page.

As told by Catalin: "On arm64 without hardware Access Flag, copying from
user will fail because the pte is old and cannot be marked young. So we
always end up with zeroed page after fork() + CoW for pfn mappings. we
don't always have a hardware-managed access flag on arm64."

Changes
v3: add vmf->ptl lock/unlock (by Kirill A. Shutemov)
    add arch_faults_on_old_pte (Matthew, Catalins)
v2: remove FAULT_FLAG_WRITE when setting pte access flag (by Catalin)
Jia He (2):
  arm64: mm: implement arch_faults_on_old_pte() on arm64
  mm: fix double page fault on arm64 if PTE_AF is cleared

 arch/arm64/include/asm/pgtable.h | 11 +++++++++++
 mm/memory.c                      | 29 ++++++++++++++++++++++++-----
 2 files changed, 35 insertions(+), 5 deletions(-)

-- 
2.17.1


