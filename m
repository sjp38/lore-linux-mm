Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0581C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6002206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:07:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6002206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 092386B0007; Mon, 12 Aug 2019 12:07:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 019776B0008; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4A7E6B000C; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id ADA096B0007
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:07:18 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4D5A0180AD7C3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:18 +0000 (UTC)
X-FDA: 75814255356.01.coach44_53e8d4e0664a
X-HE-Tag: coach44_53e8d4e0664a
X-Filterd-Recvd-Size: 2269
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:07:15 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ED1F515A2;
	Mon, 12 Aug 2019 09:06:46 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id DDF7B3F718;
	Mon, 12 Aug 2019 09:06:45 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3 0/3] mm: kmemleak: Use a memory pool for kmemleak object allocations
Date: Mon, 12 Aug 2019 17:06:39 +0100
Message-Id: <20190812160642.52134-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Following the discussions on v2 of this patch(set) [1], this series
takes slightly different approach:

- it implements its own simple memory pool that does not rely on the
  slab allocator

- drops the early log buffer logic entirely since it can now allocate
  metadata from the memory pool directly before kmemleak is fully
  initialised

- CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE option is renamed to
  CONFIG_DEBUG_KMEMLEAK_MEM_POOL_SIZE

- moves the kmemleak_init() call earlier (mm_init())

- to avoid a separate memory pool for struct scan_area, it makes the
  tool robust when such allocations fail as scan areas are rather an
  optimisation

[1] http://lkml.kernel.org/r/20190727132334.9184-1-catalin.marinas@arm.co=
m

Catalin Marinas (3):
  mm: kmemleak: Make the tool tolerant to struct scan_area allocation
    failures
  mm: kmemleak: Simple memory allocation pool for kmemleak objects
  mm: kmemleak: Use the memory pool for early allocations

 init/main.c       |   2 +-
 lib/Kconfig.debug |  11 +-
 mm/kmemleak.c     | 325 ++++++++++++----------------------------------
 3 files changed, 91 insertions(+), 247 deletions(-)


