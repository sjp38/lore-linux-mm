Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E761BC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F67420693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Uf1FCuDX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F67420693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C6298E002D; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F79A8E002C; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C2058E002A; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B11868E0028
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c31so42657011ede.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vwkKEN+NO/42LLW7V4MVtQKdg9NG9HC4dwr+b7oU7/A=;
        b=ftsIkHDZw8mLoks1TNmGIWWqjcfmdAR1anzGHBwaQXJbYZ0l4vUCxGCj+BIc2aiO/E
         Fj5JricjB5277M1lvlB0ClpvIjYOkOD0wgU2zhbjlO5YSQoDYavLjfL/WtNOtsnE+oYr
         FDeSj1Nnk6dxp1oiIc3YtnsmMy2RFl3VBX8y6YcnSnOQ1sAZmRyM5zGcpf0jEPcOBbyq
         LRmLRIhBx0dwka06RWA7bEAOEWynyA8MNp0RGhAHJYb4/3lAioIzSU6DeqIdbHgxNWMi
         sTZTuCo2Jx9Mn7neH2YslTt9w4LgfKlJiu/qK44413cAeBtpaBAoDBJxgM62L7wVOCaz
         4Sag==
X-Gm-Message-State: APjAAAU2/KMIrGYq3JxVsgqCS5q0MmfDeHsAAIs40tMQgWmznPzJXRI+
	iDTl8aSRnjoOpOm9Bfq3c5Sj8QU+qxZaj83GKH0u7cUm3VwmyBGw6w0lqmsN2gaudrzwp1uXz/u
	+h2x9kEe/qM2ed5diEmUyuFHtb1a63Z+4kpCiHQ3KSzOBBr3/dp9yQL+LyoqW29Y=
X-Received: by 2002:a50:ad01:: with SMTP id y1mr105214758edc.180.1564586036281;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
X-Received: by 2002:a50:ad01:: with SMTP id y1mr105214629edc.180.1564586035006;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586035; cv=none;
        d=google.com; s=arc-20160816;
        b=d9E0SfMgS3I1iiMckVmD3ZAojOmIfUZqsQSNhtcJ8uRiyXVjDlnWMhCdNaRJnRYmpa
         eQ0FyYpyZZaz5WAJT5Lh7eYnHnaCRPveqCbwudrzrSsMEgKCFshFdpQKZW+M5l0Ptoaz
         R3rw7uRrwjvSEqu7gpKv6hu6pPTYzXudEhh3H5nkVoavmbuepJPWcP9z04m4JHkeC2lS
         r3kcgmNqfnrC6GLIXY9INgHBB15mmLemzZ7hYf8KaodenhS2XYmYmzgzULSZlCU64xKq
         To/Q7Eb+YcvuOE+4ZrjpCQMypmXsTUOJnfJCfzR+J6/2gkJbXXMA01fKIXx7nV6Mkz67
         cVJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vwkKEN+NO/42LLW7V4MVtQKdg9NG9HC4dwr+b7oU7/A=;
        b=jVyA8WD6VODXV9ZvZxiBf3J1rsiqiqk+Kfj0YqokSsJsZ3FLI91/Qor9ETve6Rukyo
         M/anHpkwKaIMx38DCvnlHgi2MHGJHk8ctf9qQ9J5fXz8aiDWx2EZdfM4zUrz3M3kDSff
         OuHXGFX3dc4D+KXor2sxcqWPjAPOd3/kXJfyLryyPYN1/1N6B0MVnANlYJTCMNDLqzxa
         kWQoXANlj7aYtMGaTgzYwV8ihSO+48SICwUvLyAqgYvLIFLwKUmeC/LHMy1WmzHdbsdL
         hg/GqX5kJtYnRjY+zAk45VmWiNUCSnMVnp0lh0hSG6/CXbABSBi3+sXHJxdb+CGDr2r0
         +SjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Uf1FCuDX;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p21sor21716655ejj.15.2019.07.31.08.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Uf1FCuDX;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vwkKEN+NO/42LLW7V4MVtQKdg9NG9HC4dwr+b7oU7/A=;
        b=Uf1FCuDX52sEvKUCsJficveOp2kKNYX4EUGxdRJNZykLCtDIIDHpegDxYsp6cPe5pW
         EAoTzT/6HRwwAnq5QnSYpAtuKu32nvYS2kUdpN1mP4PQQ10UlxLyuA/tskPf2FIwxPud
         pUuxivdUf/yz+Tp+pjhIEiW+/6YgFS3K9zGL+Qh3OQ4/mioDDDPpCShm0v2J1MgLE8ff
         LAdvm4H5jX3b3WNwtdu5V9RM3W2HZGEtg1DkZ1XkWQ5ltdRlOKm5W2OJllK1ZO7oeFpf
         AvmUIe2HLJhkTNVz6b9FQaFDlX7qZyFGnnid7IyU8Nt0XiTLAB+dX1L/C7HwTI3yhcZW
         +xaA==
X-Google-Smtp-Source: APXvYqzBhlGdHrkZxNCta+YbwIpYcpSQldx/aTh7wiP6WOvFi0hxTn7lmyACen/6coFCsBG0rQq5SQ==
X-Received: by 2002:a17:906:43c9:: with SMTP id j9mr92667128ejn.248.1564586034633;
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id k10sm17260344eda.9.2019.07.31.08.13.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 103E71045FE; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 40/59] keys/mktme: Block memory hotplug additions when MKTME is enabled
Date: Wed, 31 Jul 2019 18:07:54 +0300
Message-Id: <20190731150813.26289-41-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Intel platforms supporting MKTME need the ability to evaluate
the memory topology before allowing new memory to go online.
That evaluation would determine if the kernel can program the
memory controller. Every memory controller needs to have a
CPU online, capable of programming its MKTME keys.

The kernel uses the ACPI HMAT at boot time to determine a safe
MKTME topology, but at run time, there is no update to the HMAT.
That run time support will come in the future with platform and
kernel support for the _HMA method.

Meanwhile, be safe, and do not allow any MEM_GOING_ONLINE events
when MKTME is enabled.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index b042df73899d..f804d780fc91 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -8,6 +8,7 @@
 #include <linux/init.h>
 #include <linux/key.h>
 #include <linux/key-type.h>
+#include <linux/memory.h>
 #include <linux/mm.h>
 #include <linux/parser.h>
 #include <linux/percpu-refcount.h>
@@ -497,6 +498,26 @@ static int mktme_cpu_teardown(unsigned int cpu)
 	return ret;
 }
 
+static int mktme_memory_callback(struct notifier_block *nb,
+				 unsigned long action, void *arg)
+{
+	/*
+	 * Do not allow the hot add of memory until run time
+	 * support of the ACPI HMAT is available via an _HMA
+	 * method. Without it, the new memory cannot be
+	 * evaluated to determine an MTKME safe topology.
+	 */
+	if (action == MEM_GOING_ONLINE)
+		return NOTIFY_BAD;
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block mktme_memory_nb = {
+	.notifier_call = mktme_memory_callback,
+	.priority = 99,				/* priority ? */
+};
+
 static int __init init_mktme(void)
 {
 	int ret, cpuhp;
@@ -543,10 +564,15 @@ static int __init init_mktme(void)
 	if (cpuhp < 0)
 		goto free_encrypt;
 
+	if (register_memory_notifier(&mktme_memory_nb))
+		goto remove_cpuhp;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	unregister_memory_notifier(&mktme_memory_nb);
+remove_cpuhp:
 	cpuhp_remove_state_nocalls(cpuhp);
 free_encrypt:
 	kvfree(encrypt_count);
-- 
2.21.0

