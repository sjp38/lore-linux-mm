Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78F70C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AA9E20665
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:44:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AA9E20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9F766B02A2; Thu, 15 Aug 2019 11:44:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4F846B02A4; Thu, 15 Aug 2019 11:44:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A66036B02A5; Thu, 15 Aug 2019 11:44:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id 86A896B02A2
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 11:44:11 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 382184FEC
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:44:11 +0000 (UTC)
X-FDA: 75825083502.15.cat62_7b8920b745f32
X-HE-Tag: cat62_7b8920b745f32
X-Filterd-Recvd-Size: 3390
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:44:08 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D9BA528;
	Thu, 15 Aug 2019 08:44:07 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 339C33F706;
	Thu, 15 Aug 2019 08:44:06 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Dave P Martin <Dave.Martin@arm.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-doc@vger.kernel.org,
	linux-arch@vger.kernel.org
Subject: [PATCH v8 0/2] arm64 tagged address ABI
Date: Thu, 15 Aug 2019 16:43:58 +0100
Message-Id: <20190815154403.16473-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This series contains an update to the arm64 tagged address ABI
documentation posted here (v7):

http://lkml.kernel.org/r/20190807155321.9648-1-catalin.marinas@arm.com

together some adjustments to Andrey's patches (already queued through
different trees) following the discussions on the ABI documents:

http://lkml.kernel.org/r/cover.1563904656.git.andreyknvl@google.com

If there are not objections, I propose that that patch 1 (mm: untag user
pointers in mmap...) goes via the mm tree while the other 4 are routed
via the arm64 tree.

Changes in v8:

- removed mmap/munmap/mremap/brk from the list of syscalls not accepting
  tagged pointers

- added ioctl() to the list of syscalls not accepting tagged pointers

- added shmat/shmdt to a list of syscalls not accepting tagged pointers

- prctl() now requires all unused arguments to be 0

- note about two-stage ABI relaxation since even without the prctl()
  opt-in, the tag is still ignored on a few syscalls (untagged_addr() in
  the kernel is unconditional)

- compilable example code together with syscall use

- added a note on tag preservation in the tagged-pointers.rst document

- various rewordings and cleanups


Catalin Marinas (3):
  mm: untag user pointers in mmap/munmap/mremap/brk
  arm64: Tighten the PR_{SET,GET}_TAGGED_ADDR_CTRL prctl() unused
    arguments
  arm64: Change the tagged_addr sysctl control semantics to only prevent
    the opt-in

Vincenzo Frascino (2):
  arm64: Define Documentation/arm64/tagged-address-abi.rst
  arm64: Relax Documentation/arm64/tagged-pointers.rst

 Documentation/arm64/tagged-address-abi.rst | 155 +++++++++++++++++++++
 Documentation/arm64/tagged-pointers.rst    |  23 ++-
 arch/arm64/kernel/process.c                |  17 ++-
 kernel/sys.c                               |   4 +
 mm/mmap.c                                  |   5 +
 mm/mremap.c                                |   6 +-
 6 files changed, 191 insertions(+), 19 deletions(-)
 create mode 100644 Documentation/arm64/tagged-address-abi.rst


