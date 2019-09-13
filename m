Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C54DDC4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:55:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95C3620717
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:55:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95C3620717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FDED6B0005; Fri, 13 Sep 2019 05:55:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AEF56B0006; Fri, 13 Sep 2019 05:55:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C4A96B0007; Fri, 13 Sep 2019 05:55:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id DA9B96B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:55:14 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 87EAB181AC9B4
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:55:14 +0000 (UTC)
X-FDA: 75929439348.30.coast81_4ac6c27e7035e
X-HE-Tag: coast81_4ac6c27e7035e
X-Filterd-Recvd-Size: 2551
Received: from mga05.intel.com (mga05.intel.com [192.55.52.43])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:55:13 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Sep 2019 02:55:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,489,1559545200"; 
   d="scan'208";a="336850934"
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga004.jf.intel.com with ESMTP; 13 Sep 2019 02:55:09 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 5317DF3; Fri, 13 Sep 2019 12:55:08 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	x86@kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/mm: Enable 5-level paging support by default
Date: Fri, 13 Sep 2019 12:54:52 +0300
Message-Id: <20190913095452.40592-1-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Support of boot-time switching between 4- and 5-level paging mode is
upstream since 4.17.

We run internal testing with 5-level paging support enabled for a while
and it doesn't not cause any functional or performance regression on
4-level paging hardware.

The only 5-level paging related regressions I saw were in early boot
code that runs independently from CONFIG_X86_5LEVEL.

The next major release of distributions expected to have
CONFIG_X86_5LEVEL=3Dy.

Enable the option by default. It may help to catch obscure bugs early.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..2f7cb91d850e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1483,6 +1483,7 @@ config X86_PAE
=20
 config X86_5LEVEL
 	bool "Enable 5-level page tables support"
+	default y
 	select DYNAMIC_MEMORY_LAYOUT
 	select SPARSEMEM_VMEMMAP
 	depends on X86_64
--=20
2.21.0


