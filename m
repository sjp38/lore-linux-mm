Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F27A8C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:47:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCC742332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCC742332A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27B3F6B0319; Wed, 21 Aug 2019 12:47:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D9C96B031C; Wed, 21 Aug 2019 12:47:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE34C6B031A; Wed, 21 Aug 2019 12:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id B13486B0319
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:47:46 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5B0C5181AC9C4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:47:46 +0000 (UTC)
X-FDA: 75847016532.12.move58_9942f54ff345
X-HE-Tag: move58_9942f54ff345
X-Filterd-Recvd-Size: 3410
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:47:45 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9CAA91576;
	Wed, 21 Aug 2019 09:47:44 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id ECACE3F718;
	Wed, 21 Aug 2019 09:47:42 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Dave P Martin <Dave.Martin@arm.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-doc@vger.kernel.org,
	linux-arch@vger.kernel.org
Subject: [PATCH v9 1/3] mm: untag user pointers in mmap/munmap/mremap/brk
Date: Wed, 21 Aug 2019 17:47:28 +0100
Message-Id: <20190821164730.47450-2-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
In-Reply-To: <20190821164730.47450-1-catalin.marinas@arm.com>
References: <20190821164730.47450-1-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There isn't a good reason to differentiate between the user address
space layout modification syscalls and the other memory
permission/attributes ones (e.g. mprotect, madvise) w.r.t. the tagged
address ABI. Untag the user addresses on entry to these functions.

Acked-by: Will Deacon <will@kernel.org>
Acked-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/mmap.c   | 5 +++++
 mm/mremap.c | 6 +-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..b766b633b7ae 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -201,6 +201,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	bool downgraded =3D false;
 	LIST_HEAD(uf);
=20
+	brk =3D untagged_addr(brk);
+
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
=20
@@ -1573,6 +1575,8 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, u=
nsigned long len,
 	struct file *file =3D NULL;
 	unsigned long retval;
=20
+	addr =3D untagged_addr(addr);
+
 	if (!(flags & MAP_ANONYMOUS)) {
 		audit_mmap_fd(fd, flags);
 		file =3D fget(fd);
@@ -2874,6 +2878,7 @@ EXPORT_SYMBOL(vm_munmap);
=20
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
+	addr =3D untagged_addr(addr);
 	profile_munmap(addr);
 	return __vm_munmap(addr, len, true);
 }
diff --git a/mm/mremap.c b/mm/mremap.c
index 64c9a3b8be0a..1fc8a29fbe3f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -606,12 +606,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigne=
d long, old_len,
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
=20
-	/*
-	 * Architectures may interpret the tag passed to mmap as a background
-	 * colour for the corresponding vma. For mremap we don't allow tagged
-	 * new_addr to preserve similar behaviour to mmap.
-	 */
 	addr =3D untagged_addr(addr);
+	new_addr =3D untagged_addr(new_addr);
=20
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;

