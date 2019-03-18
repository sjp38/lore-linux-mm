Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C52B7C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82EA72133F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82EA72133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 373B46B0006; Mon, 18 Mar 2019 12:36:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 321A16B0007; Mon, 18 Mar 2019 12:36:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8576B0008; Mon, 18 Mar 2019 12:36:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEC936B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:36:01 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t190so3441228wmt.8
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:36:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W7fYsGKRBlmTW3CD7cbX3LbedsaSpni9GuqLbWnL0zM=;
        b=kp/V4dr/OiD58aROKoDzSuW/0rAxB/5Ra8V1hl6PFJerVf6xm0xylOql1jf6Wie0cL
         1YWBpXpdWyrECu9VdC1asD+nNOyk9oafgUzR3GCcJVO5KD9Crp6D+ZqZaTlRxcxGlQyw
         NLJf5Q1XkDo9gkAoa6rdpvWA9ODFRyuKiQrCPlzIG0LNf3HnIV6IlTzybkFqjeRO7fmM
         oGpH6zxrRHnk0jq6/eaFaRi3ENdCYSS81lRaUChWA6d3GpntAF7VUtQKtxpLXF8LKugW
         LTFXnq6RKIU6dj1uAAJE61oh44/rdmD5s5efSDwZx3plQhRP6uYxlwDeOcdC9g8t2stx
         /WLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUqCpS97ZrvQULEg42klt6bgUYu22Bg2UGjvQi4Ju9nM31mQiFj
	xb2VCRrqLCS4YpKNH35siH/1iXynfqCzsvCv/w1AuHRG6fc08LYJ2KpN9fxkPjkiDm9AI6CK4tk
	S9f0M52vM4YMGr/Bh6hP6q2lXJAM/YWDO3zyB3M8QnqbNu+gk8h2bDbbcLJ5GfYPu9Q==
X-Received: by 2002:a5d:4710:: with SMTP id y16mr4492405wrq.176.1552926961207;
        Mon, 18 Mar 2019 09:36:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD/iPhfC1aLLwNsKyX96aiVPG5ixxS5wd8RskceyZNJMHXxvGjjNsXgBTSDISgiKS+4gb0
X-Received: by 2002:a5d:4710:: with SMTP id y16mr4492357wrq.176.1552926960367;
        Mon, 18 Mar 2019 09:36:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552926960; cv=none;
        d=google.com; s=arc-20160816;
        b=YpOWwV/qXH1shSYZJiBAwlU5BMU59E0ojpRqHXfGxG+UYaZzEIXto+1OeNzCdaVtWA
         BwJaJ6ckSzy92fkspCiTVGEITGg30wZ7ZcuFR3hPySU5c1lEHmD8GMuSIuVt42KBL4DG
         aQyfP+8csdNvqAfSVe8OP0n0Lva6t+s7b+CFRpluRXqs94spzS0INLAhMZSUh1cWLFPV
         t1zaYrINE62c+zPW1JTDVR8zn3H+2h4GWL4ax2cr9GlrV2K1TLPdGtRPw/bffUr3ZyBW
         BIpnYVEOgicj8/CpuhvFsa4f7Es6G9l+ua3Iis96iNcd90/wasmdj+rrDnJhWetQu1kA
         33+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W7fYsGKRBlmTW3CD7cbX3LbedsaSpni9GuqLbWnL0zM=;
        b=lAvTPw45Jh2FKG55CgAxbeNwEhMD85MFTcfDMBQjB7JDSevk/XDVkEwKPEBFXAVWSS
         yTaGi/zlrj3VM6P6Pko2gX2ClZcetnSanOugagEUqZcQYV8pWJOgOP2f7yM102dMzAj4
         Sw79FD2/f171tC05EFElRM6NehABAR4GpCdlXKxJeM4y6SZn1xPjGJgApLMt4VAtqDEg
         3AcjPt54+ev8n9lt0IK77HXN9oh1WF3PK54+V2u/H8TXJuZkI3mDZymGBABQ0et1szX8
         QQvB+4cLjgYsz/Mx35eTXEvgtr4VlqQxqM0IE6zZicY2VUpFMDInzwiaP7hPm6vscSHP
         Nghg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v184si6390929wma.96.2019.03.18.09.35.59
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 09:36:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 20D71165C;
	Mon, 18 Mar 2019 09:35:59 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ED7E23F614;
	Mon, 18 Mar 2019 09:35:52 -0700 (PDT)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Alexei Starovoitov <ast@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Branislav Rankov <Branislav.Rankov@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Dave Martin <Dave.Martin@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Graeme Barnes <Graeme.Barnes@arm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Kostya Serebryany <kcc@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Shuah Khan <shuah@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 1/4] elf: Make AT_FLAGS arch configurable
Date: Mon, 18 Mar 2019 16:35:30 +0000
Message-Id: <20190318163533.26838-2-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190318163533.26838-1-vincenzo.frascino@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <20190318163533.26838-1-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, the AT_FLAGS in the elf auxiliary vector are set to 0
by default by the kernel.
Some architectures might need to expose to the userspace a non-zero
value to advertise some platform specific ABI functionalities.

Make AT_FLAGS configurable by the architectures that require it.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 fs/binfmt_elf.c        | 6 +++++-
 fs/binfmt_elf_fdpic.c  | 6 +++++-
 fs/compat_binfmt_elf.c | 5 +++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 7d09d125f148..f699a9ef5112 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -84,6 +84,10 @@ static int elf_core_dump(struct coredump_params *cprm);
 #define ELF_CORE_EFLAGS	0
 #endif
 
+#ifndef ELF_AT_FLAGS
+#define ELF_AT_FLAGS	0
+#endif
+
 #define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
 #define ELF_PAGEOFFSET(_v) ((_v) & (ELF_MIN_ALIGN-1))
 #define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))
@@ -249,7 +253,7 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	NEW_AUX_ENT(AT_PHENT, sizeof(struct elf_phdr));
 	NEW_AUX_ENT(AT_PHNUM, exec->e_phnum);
 	NEW_AUX_ENT(AT_BASE, interp_load_addr);
-	NEW_AUX_ENT(AT_FLAGS, 0);
+	NEW_AUX_ENT(AT_FLAGS, ELF_AT_FLAGS);
 	NEW_AUX_ENT(AT_ENTRY, exec->e_entry);
 	NEW_AUX_ENT(AT_UID, from_kuid_munged(cred->user_ns, cred->uid));
 	NEW_AUX_ENT(AT_EUID, from_kuid_munged(cred->user_ns, cred->euid));
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index b53bb3729ac1..cf1e680a6b88 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -82,6 +82,10 @@ static int elf_fdpic_map_file_by_direct_mmap(struct elf_fdpic_params *,
 static int elf_fdpic_core_dump(struct coredump_params *cprm);
 #endif
 
+#ifndef ELF_AT_FLAGS
+#define ELF_AT_FLAGS	0
+#endif
+
 static struct linux_binfmt elf_fdpic_format = {
 	.module		= THIS_MODULE,
 	.load_binary	= load_elf_fdpic_binary,
@@ -651,7 +655,7 @@ static int create_elf_fdpic_tables(struct linux_binprm *bprm,
 	NEW_AUX_ENT(AT_PHENT,	sizeof(struct elf_phdr));
 	NEW_AUX_ENT(AT_PHNUM,	exec_params->hdr.e_phnum);
 	NEW_AUX_ENT(AT_BASE,	interp_params->elfhdr_addr);
-	NEW_AUX_ENT(AT_FLAGS,	0);
+	NEW_AUX_ENT(AT_FLAGS,	ELF_AT_FLAGS);
 	NEW_AUX_ENT(AT_ENTRY,	exec_params->entry_addr);
 	NEW_AUX_ENT(AT_UID,	(elf_addr_t) from_kuid_munged(cred->user_ns, cred->uid));
 	NEW_AUX_ENT(AT_EUID,	(elf_addr_t) from_kuid_munged(cred->user_ns, cred->euid));
diff --git a/fs/compat_binfmt_elf.c b/fs/compat_binfmt_elf.c
index 15f6e96b3bd9..a21cf99701ae 100644
--- a/fs/compat_binfmt_elf.c
+++ b/fs/compat_binfmt_elf.c
@@ -79,6 +79,11 @@
 #define	ELF_HWCAP2		COMPAT_ELF_HWCAP2
 #endif
 
+#ifdef	COMPAT_ELF_AT_FLAGS
+#undef	ELF_AT_FLAGS
+#define	ELF_AT_FLAGS		COMPAT_ELF_AT_FLAGS
+#endif
+
 #ifdef	COMPAT_ARCH_DLINFO
 #undef	ARCH_DLINFO
 #define	ARCH_DLINFO		COMPAT_ARCH_DLINFO
-- 
2.21.0

