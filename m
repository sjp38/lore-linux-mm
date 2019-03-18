Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8D5CC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89331205C9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:35:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89331205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DC996B0003; Mon, 18 Mar 2019 12:35:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 064126B0006; Mon, 18 Mar 2019 12:35:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6CE96B0007; Mon, 18 Mar 2019 12:35:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 906586B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:35:56 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n125so2635582wmn.1
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:35:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ok73Cd0+1oOdATm9yISCwTjN9oEDZNi1QdCRZyqCgiw=;
        b=kK7YGEIOQgQllwfQwp/b15Vr1WL+PTIRD3bVvw83WO7Oy9khBAVBX/4L0RbIp1Sf/S
         Wkklg4B6K0sGBOJUhNO8JIa241zi5uNLuEvoOW9eWssTIfAB9L64m0h1ESJM7ZpDuEJ9
         Q0Y6rYDc7H8nacSVJxEb04AyaDOy3gBdOCYjKOnxsLvMCdaXGKzbm7t12sQ/Jnyjyn3f
         29GIwPoHob4H/lYaEsByuxY9rYHlHYqU6FVe6X0/6UseA39vTxHDeZ06oahThr6sjQym
         fB8MN6IfkwBbNme0kKxllo1f6V8CsQpC9/mir+9j7QxS4P8LOUYrGGqAv44xeQ3Sl+va
         m0vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUi1kVCSWVONDHQQfL5rL/QG6MWUOcAP6hbw5NMEbYk6DZa6CjZ
	9oFUV5kj8tZyJJ3TIJd5d2EHOjGEitsQjwwfocFlIq9ArxIi7IiBQpMUsLFdoHIyFoXTAL0r4xJ
	SPWPnAhAY+LuoZ7ekY1fmUzSVMT2IG7bPFP/BYorfuzrBJiBS7s1Wsyl56hCS2oOnTQ==
X-Received: by 2002:a1c:234d:: with SMTP id j74mr11077774wmj.130.1552926955881;
        Mon, 18 Mar 2019 09:35:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1/uYhDutaRUGBDGWrr8KBfuBRnrQcQ6qS529Q8pFVwf02IabtKC9KW1qmqJq4BEwTuJHi
X-Received: by 2002:a1c:234d:: with SMTP id j74mr11077670wmj.130.1552926953966;
        Mon, 18 Mar 2019 09:35:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552926953; cv=none;
        d=google.com; s=arc-20160816;
        b=s60GfCOjudoT+cye91IrpLJV884g6IJN5qf5l/WMfPRtCEQccmuDSK2B9GQVKaqpc/
         mrRTYmz8U9XT8+ug115U1NH7PZYNGTntgEhHrHYNxQQD7+ep/KRByI7wEHHUEWxSr2ik
         kYgAej2QgCHQW14owknTWmwp7yyNw4OYtLB7iw/uHxsjsGGqI8DY4gNemTpoP+MSZx6c
         KToshm8xrJ0CG3xcLRNtlc/uKwkeheuxedRc4RDpjZqUfkfrTLz9rR6YL65oF7NCIn51
         RQC1HMx6syzYaXeVof/XxZYvQxHOI9TIFk80r5+KxhndEkzYN8rZuQVIMj+rI6IVyO49
         3QaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Ok73Cd0+1oOdATm9yISCwTjN9oEDZNi1QdCRZyqCgiw=;
        b=B55UXRw/69EdSbb1Z+I7ARZ6r/wseARYwD4P0XvkMpprT0THfGMhUmh9oLgfEGWYlB
         G4A+OPRwllx2Ndg8m5VKOZ9ShLIFw+LBPrIiccBjyDV8WHxLasMp5XtUop02MVymLiNE
         5bXQMWGlfURIwvd8NZeVck3Mq8f94yOwPWp34V0qyKbYSsdxrmCot9m67emvOoocGZQH
         jeob3SQVEBAUwxI8+/CzP4yjYQXo2DTwf0EleG1g4EiW/aGlr/dGkHAU1mR5GcinqYDL
         +Q+E0RqAsf1rGGyYscchUhlQ/dYpsIEChe0RNrhvBsPlkOr4D5AIGC7G3pTj+sji/Sxm
         zNwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 66si6666132wmd.127.2019.03.18.09.35.53
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 09:35:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AB48D1650;
	Mon, 18 Mar 2019 09:35:52 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 85D5F3F614;
	Mon, 18 Mar 2019 09:35:46 -0700 (PDT)
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
Subject: [PATCH v2 0/4] arm64 relaxed ABI
Date: Mon, 18 Mar 2019 16:35:29 +0000
Message-Id: <20190318163533.26838-1-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
References: <cover.1552679409.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On arm64 the TCR_EL1.TBI0 bit has been always enabled in the Linux
kernel hence the userspace (EL0) is allowed to set a non-zero value
in the top byte but the resulting pointers are not allowed at the
user-kernel syscall ABI boundary.

This patchset proposes a relaxation of the ABI and a mechanism to
advertise it to the userspace via an AT_FLAGS.

The rationale behind the choice of AT_FLAGS is that the Unix System V
ABI defines AT_FLAGS as "flags", leaving some degree of freedom in
interpretation.
There are two previous attempts of using AT_FLAGS in the Linux Kernel
for different reasons: the first was more generic and was used to expose
the support for the GNU STACK NX feature [1] and the second was done for
the MIPS architecture and was used to expose the support of "MIPS ABI
Extension for IEEE Std 754 Non-Compliant Interlinking" [2].
Both the changes are currently _not_ merged in mainline.
The only architecture that reserves some of the bits in AT_FLAGS is
currently MIPS, which introduced the concept of platform specific ABI
(psABI) reserving the top-byte [3].

When ARM64_AT_FLAGS_SYSCALL_TBI is set the kernel is advertising
to the userspace that a relaxed ABI is supported hence this type
of pointers are now allowed to be passed to the syscalls when they are
in memory ranges obtained by anonymous mmap() or brk().

The userspace _must_ verify that the flag is set before passing tagged
pointers to the syscalls allowed by this relaxation.

More in general, exposing the ARM64_AT_FLAGS_SYSCALL_TBI flag and mandating
to the software to check that the feature is present, before using the
associated functionality, it provides a degree of control on the decision
of disabling such a feature in future without consequently breaking the
userspace.

The change required a modification of the elf common code, because in Linux
the AT_FLAGS are currently set to zero by default by the kernel.

The newly added flag has been verified on arm64 using the code below.
#include <stdio.h>
#include <stdbool.h>
#include <sys/auxv.h>

#define ARM64_AT_FLAGS_SYSCALL_TBI     (1 << 0)

bool arm64_syscall_tbi_is_present(void)
{
        unsigned long at_flags = getauxval(AT_FLAGS);
        if (at_flags & ARM64_AT_FLAGS_SYSCALL_TBI)
                return true;

        return false;
}

void main()
{
        if (arm64_syscall_tbi_is_present())
                printf("ARM64_AT_FLAGS_SYSCALL_TBI is present\n");
}

This patchset should be merged together with [4].

[1] https://patchwork.ozlabs.org/patch/579578/
[2] https://lore.kernel.org/patchwork/cover/618280/
[3] ftp://www.linux-mips.org/pub/linux/mips/doc/ABI/psABI_mips3.0.pdf
[4] https://patchwork.kernel.org/cover/10674351/

ABI References:
---------------
Sco SysV ABI: http://www.sco.com/developers/gabi/2003-12-17/contents.html
PowerPC AUXV: http://openpowerfoundation.org/wp-content/uploads/resources/leabi/content/dbdoclet.50655242_98651.html
AMD64 ABI: https://www.cs.tufts.edu/comp/40-2012f/readings/amd64-abi.pdf
x86 ABI: https://www.uclibc.org/docs/psABI-i386.pdf
MIPS ABI: ftp://www.linux-mips.org/pub/linux/mips/doc/ABI/psABI_mips3.0.pdf
ARM ABI: http://infocenter.arm.com/help/topic/com.arm.doc.ihi0044f/IHI0044F_aaelf.pdf
SPARC ABI: http://math-atlas.sourceforge.net/devel/assembly/abi_sysV_sparc.pdf

CC: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Branislav Rankov <Branislav.Rankov@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Dave Martin <Dave.Martin@arm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Graeme Barnes <Graeme.Barnes@arm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Jacob Bramley <Jacob.Bramley@arm.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Lee Smith <Lee.Smith@arm.com>
Cc: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

Changes:
--------
v2:
  - Rebased on 5.1-rc1
  - Addressed review comments
  - Modified tagged-pointers.txt to be compliant with the
    new ABI relaxation

Vincenzo Frascino (4):
  elf: Make AT_FLAGS arch configurable
  arm64: Define Documentation/arm64/elf_at_flags.txt
  arm64: Relax Documentation/arm64/tagged-pointers.txt
  arm64: elf: Advertise relaxed ABI

 Documentation/arm64/elf_at_flags.txt    | 133 ++++++++++++++++++++++++
 Documentation/arm64/tagged-pointers.txt |  23 ++--
 arch/arm64/include/asm/atflags.h        |   7 ++
 arch/arm64/include/asm/elf.h            |   5 +
 arch/arm64/include/uapi/asm/atflags.h   |   8 ++
 fs/binfmt_elf.c                         |   6 +-
 fs/binfmt_elf_fdpic.c                   |   6 +-
 fs/compat_binfmt_elf.c                  |   5 +
 8 files changed, 184 insertions(+), 9 deletions(-)
 create mode 100644 Documentation/arm64/elf_at_flags.txt
 create mode 100644 arch/arm64/include/asm/atflags.h
 create mode 100644 arch/arm64/include/uapi/asm/atflags.h

-- 
2.21.0

