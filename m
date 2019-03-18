Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EFC5C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29D0D2133F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29D0D2133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFF916B0007; Mon, 18 Mar 2019 12:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAC966B0008; Mon, 18 Mar 2019 12:36:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B036B000A; Mon, 18 Mar 2019 12:36:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 541E56B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:36:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id l20so4532634wrf.23
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:36:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OisYVOBbP2Vpq4E/v0HrS0vXKqDoNwWJhpOlxjcmyYc=;
        b=r7617mWwPlaKRPXCI1JlQ0IW8+on3LvpaY5EBveJs8IAhrl4jGUa6+naSpvD9o8NaG
         wUzbib14e1MktU8CYKyW0uq6BQUxAri9+CSNSnPir6M9yeH00HklKXVj304eCpEtIZFa
         lZg3QmpVxY9gUR+FOfJ7QV9/IqI+kJe6HqQUvN+7X8ph5zvMGRSEwOAXeV6tMhMLe107
         AXj3/g4iDLbGdH/C7ouufRVT3Ma3V/3PTl7MSdcvSHHZQh7vLK4mNMInUANQ3HX8Qdzx
         MFokr/oNdXMS2rSUg5LJO1cpyn/cWszO/M9Z6LfCCxcwqnW+g/HmeijNJR0GZrg8AmMK
         zujw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAVBy1zpnlxsAWwS5VuejIKuOIkTRT1Yo3G9oq8UeJfA+NGzKNXt
	DTns+1gVhUjL6aeCazmrxt1/7nZ7vipmbRKI9CfEWi5lptHcu6RrxZTNJAy95LR5zGErzIw3ciV
	P0Saj08HwoAz6jTzm9F5s185D9zGi4MkuSRYMIT1MuxWZjk7wviNFwEh7uNofUEZLUw==
X-Received: by 2002:a5d:458d:: with SMTP id p13mr3563358wrq.224.1552926967763;
        Mon, 18 Mar 2019 09:36:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlYMKY060xx5Y309sszHS0wVtFWDpuOBM7myvCetgClR1/Re5mk4fVx4IDW3nCnX9XqAPY
X-Received: by 2002:a5d:458d:: with SMTP id p13mr3563282wrq.224.1552926966656;
        Mon, 18 Mar 2019 09:36:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552926966; cv=none;
        d=google.com; s=arc-20160816;
        b=VXCKbHknfBHjNo6XwTCvNzHPOx1k0b2iLmqSt06gTZ152lcnNkZ9KyZqW7hnRsY6cW
         v0s8cmPIloM0rBN2nvmD9tAAG3Ja6mor0R5xIc0Bx0FlFuZk1cyJpwffXX05/y/aYrUl
         Q+gWD+eYOWiQF84Js6WpiMl2Zn7upC6TN6TerdGEOWYP447M/k9qSesqC3Rl8YQAj2oJ
         1INrIn0qVAjbZSPD4MhSi0RcNNY7R2TWNhoPUAbkiQKHwMoN8qUVU1wvLC9vjpZLCb0m
         UaKG9v6/ANc03FhzjvKZIS/WZ+ka1hg+Hr36+yY8hIWjpWx8EJFdrP0M70yqNR9ALvAl
         mGbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=OisYVOBbP2Vpq4E/v0HrS0vXKqDoNwWJhpOlxjcmyYc=;
        b=B6NFvqnwYQxHsFYQDd5rO1SCIBRWwq7MZ6mREegy/ah4+PqOcEIFV1dg+z1nJtirQ3
         KFUSc1B/nqocZuALdlOmDj2V3449gJXWlNTOZsLuB2e9p6kh1PmWVw5CvH4qw6ZdYNn5
         m7fIjrwOLR+1XGKKVOyJLXDdELPWnbFtuIkbf1WFTocPA37BaD/F0hDLjLKxjpWbzjZw
         VO7GPcECsdHUT7+9jquZVPXQ1EE+4i6yU1G6dS7GNqekXXGvdqaRC4hS3A5El952AHQx
         2U/bz01TcHwxsORcxRysOYyv8K43MAKRXfkcBhVprH/vqVHi4QTorDXZAqvDTchvDcQc
         /KXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r6si891432wmf.99.2019.03.18.09.36.06
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 09:36:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 87E5A1682;
	Mon, 18 Mar 2019 09:36:05 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 63E6A3F614;
	Mon, 18 Mar 2019 09:35:59 -0700 (PDT)
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
Subject: [PATCH v2 2/4] arm64: Define Documentation/arm64/elf_at_flags.txt
Date: Mon, 18 Mar 2019 16:35:31 +0000
Message-Id: <20190318163533.26838-3-vincenzo.frascino@arm.com>
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

On arm64 the TCR_EL1.TBI0 bit has been always enabled hence
the userspace (EL0) is allowed to set a non-zero value in the
top byte but the resulting pointers are not allowed at the
user-kernel syscall ABI boundary.

With the relaxed ABI proposed through this document, it is now possible
to pass tagged pointers to the syscalls, when these pointers are in
memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap() or brk().

This change in the ABI requires a mechanism to inform the userspace
that such an option is available.

Specify and document the way in which AT_FLAGS can be used to advertise
this feature to the userspace.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

Squash with "arm64: Define Documentation/arm64/elf_at_flags.txt"
---
 Documentation/arm64/elf_at_flags.txt | 133 +++++++++++++++++++++++++++
 1 file changed, 133 insertions(+)
 create mode 100644 Documentation/arm64/elf_at_flags.txt

diff --git a/Documentation/arm64/elf_at_flags.txt b/Documentation/arm64/elf_at_flags.txt
new file mode 100644
index 000000000000..9b3494207c14
--- /dev/null
+++ b/Documentation/arm64/elf_at_flags.txt
@@ -0,0 +1,133 @@
+ARM64 ELF AT_FLAGS
+==================
+
+This document describes the usage and semantics of AT_FLAGS on arm64.
+
+1. Introduction
+---------------
+
+AT_FLAGS is part of the Auxiliary Vector, contains the flags and it
+is set to zero by the kernel on arm64 unless one or more of the
+features detailed in paragraph 2 are present.
+
+The auxiliary vector can be accessed by the userspace using the
+getauxval() API provided by the C library.
+getauxval() returns an unsigned long and when a flag is present in
+the AT_FLAGS, the corresponding bit in the returned value is set to 1.
+
+The AT_FLAGS with a "defined semantics" on arm64 are exposed to the
+userspace via user API (uapi/asm/atflags.h).
+The AT_FLAGS bits with "undefined semantics" are set to zero by default.
+This means that the AT_FLAGS bits to which this document does not assign
+an explicit meaning are to be intended reserved for future use.
+The kernel will populate all such bits with zero until meanings are
+assigned to them. If and when meanings are assigned, it is guaranteed
+that they will not impact the functional operation of existing userspace
+software. Userspace software should ignore any AT_FLAGS bit whose meaning
+is not defined when the software is written.
+
+The userspace software can test for features by acquiring the AT_FLAGS
+entry of the auxiliary vector, and testing whether a relevant flag
+is set.
+
+Example of a userspace test function:
+
+bool feature_x_is_present(void)
+{
+	unsigned long at_flags = getauxval(AT_FLAGS);
+	if (at_flags & FEATURE_X)
+		return true;
+
+	return false;
+}
+
+Where the software relies on a feature advertised by AT_FLAGS, it
+must check that the feature is present before attempting to
+use it.
+
+2. Features exposed via AT_FLAGS
+--------------------------------
+
+bit[0]: ARM64_AT_FLAGS_SYSCALL_TBI
+
+    On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64
+    kernel, hence the userspace (EL0) is allowed to set a non-zero value
+    in the top byte but the resulting pointers are not allowed at the
+    user-kernel syscall ABI boundary.
+    When bit[0] is set to 1 the kernel is advertising to the userspace
+    that a relaxed ABI is supported hence this type of pointers are now
+    allowed to be passed to the syscalls, when these pointers are in
+    memory ranges privately owned by a process and obtained by the
+    process in accordance with the definition of "valid tagged pointer"
+    in paragraph 3.
+    In these cases the tag is preserved as the pointer goes through the
+    kernel. Only when the kernel needs to check if a pointer is coming
+    from userspace an untag operation is required.
+
+3. ARM64_AT_FLAGS_SYSCALL_TBI
+-----------------------------
+
+From the kernel syscall interface prospective, we define, for the purposes
+of this document, a "valid tagged pointer" as a pointer that either it has
+a zero value set in the top byte or it has a non-zero value, it is in memory
+ranges privately owned by a userspace process and it is obtained in one of
+the following ways:
+  - mmap() done by the process itself, where either:
+    * flags = MAP_PRIVATE | MAP_ANONYMOUS
+    * flags = MAP_PRIVATE and the file descriptor refers to a regular
+      file or "/dev/zero"
+  - a mapping below sbrk(0) done by the process itself
+  - any memory mapped by the kernel in the process's address space during
+    creation and following the restrictions presented above (i.e. data, bss,
+    stack).
+
+When the ARM64_AT_FLAGS_SYSCALL_TBI flag is set by the kernel, the following
+behaviours are guaranteed by the ABI:
+
+  - Every current or newly introduced syscall can accept any valid tagged
+    pointers.
+
+  - If a non valid tagged pointer is passed to a syscall then the behaviour
+    is undefined.
+
+  - Every valid tagged pointer is expected to work as an untagged one.
+
+  - The kernel preserves any valid tagged pointers and returns them to the
+    userspace unchanged in all the cases except the ones documented in the
+    "Preserving tags" paragraph of tagged-pointers.txt.
+
+A definition of the meaning of tagged pointers on arm64 can be found in:
+Documentation/arm64/tagged-pointers.txt.
+
+Example of correct usage (pseudo-code) for a userspace application:
+
+bool arm64_syscall_tbi_is_present(void)
+{
+	unsigned long at_flags = getauxval(AT_FLAGS);
+	if (at_flags & ARM64_AT_FLAGS_SYSCALL_TBI)
+			return true;
+
+	return false;
+}
+
+void main(void)
+{
+	char *addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
+			  MAP_ANONYMOUS, -1, 0);
+
+	int fd = open("test.txt", O_WRONLY);
+
+	/* Check if the relaxed ABI is supported */
+	if (arm64_syscall_tbi_is_present()) {
+		/* Add a tag to the pointer */
+		addr = tag_pointer(addr);
+	}
+
+	strcpy("Hello World\n", addr);
+
+	/* Write to a file */
+	write(fd, addr, sizeof(addr));
+
+	close(fd);
+}
+
-- 
2.21.0

