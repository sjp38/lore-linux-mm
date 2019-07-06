Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C0E5C0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59BF214AF
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 10:55:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YOcmzSmR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59BF214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C65F6B0003; Sat,  6 Jul 2019 06:55:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 375DE8E0003; Sat,  6 Jul 2019 06:55:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 266358E0001; Sat,  6 Jul 2019 06:55:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC70F6B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 06:55:02 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f16so3155831wrw.5
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 03:55:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=yOnUAiKnAJPyRnwGrmxELUMGxciq9fN4mgsYKTEm4Xo=;
        b=uWpLzUZ6Wbx5ErIn09pyOkYcN5BIvAQZAdnBcHZ1+EDlaZT/QkK86Vi+j6EzhtDO+P
         JDFGL17hUil03s0Ny2aDvcq22zYb7eGasLwadBzE6wxeX0xqKjrVoBPJuoyOSYFfO1dc
         7a6XBknzLRTPzVtT4bf8ApO35c354Rn4N6b2NAVKO1vudY1UPlR6gOjZibX6p3+ZqfaU
         FqiOP9mcloUztfk+7Fn7fXrtNNV2qOwkB9lyIxj7DJJEG+j9fIKJ55pKj48rqMNncOcP
         KpBsSgA0Klew0zSx4GGmCcOkSntHXTh5sVCW8f+xQxAjmq4aAN+9l+MJsGSHOIeYW7ws
         3DbQ==
X-Gm-Message-State: APjAAAXXFV3eKKXO/4aX42hB7hcQpTMSumMYK7v/sB99SJcEotuZ8CSv
	THz5uOyyiZEu8vSFORMnCS5a98cPiiQAJCjgzk/IpqN1OBesnbSf3MRZYLFNrVMBzsa+wz7a+hA
	glzR5Mc7FnIdjh/N+36bDKq9MwusIr3c6gLnMkxWLN9oYGGGeUxdjJeWQKiQxToFzlA==
X-Received: by 2002:a7b:c0d0:: with SMTP id s16mr7400114wmh.136.1562410502227;
        Sat, 06 Jul 2019 03:55:02 -0700 (PDT)
X-Received: by 2002:a7b:c0d0:: with SMTP id s16mr7400003wmh.136.1562410500380;
        Sat, 06 Jul 2019 03:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562410500; cv=none;
        d=google.com; s=arc-20160816;
        b=c2CLWjD8UV1m/3PES/UTEtDi+rw9qJJ/HrOVpuwabBF7cwKoXwHTmhd82rlmdu+Ob7
         g+HEmd9DuzM6sUIH3qReX4flRoT8lxyVfLFYy+4gN8qlYPMivUeyAXUeDUvlphlbqkhO
         9lMcWZvAeagk7dVLOe7KMwU2Qbw25FOqxhgid/tASZsa6mlrihd1jSZFBM3LOWQErYl3
         9K3GNqk3MlTi3XlXeniB+oyDDm3jKP3RChSaJtGYQSJ85R8RkFzEUmYcjLSjYeih55+t
         40xygltp46413ZfKNOeMoR9yDuKcHM6aI9MdjcmBTmtiFCMeTyD4tpZM4UrroKjjdYit
         U8RQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=yOnUAiKnAJPyRnwGrmxELUMGxciq9fN4mgsYKTEm4Xo=;
        b=dvuxNvBp735yR3ZoIJZk45yU+3+gJhMQ/CrmHZ4lZJY820Vj23RhkKIilcMZr9S0oj
         YnVy/XFQJnVNdf9dEGhBMZbQYskmVGO026qP75fIvn1P6+PQ8nsLuRm/FC3GVvWDElEQ
         BIsmIB0UPl9p6i62Byyvu0ucK3uXojNsFJ0Mt0okH0kB32AGx7DCoyg1K0NL5N1eniEg
         mIWGHp7Vghh0oya3W/lggg7q/ZZIW61E1tpZvR0OiXnJcEpxlLP4gIOs0cIXM2xmDs0a
         D/nvUsEEa9TgthJTDWUXskrNqXSzX750sW67JCJbnOC2FRuD5zr69i5KpHxFxHsxoUMd
         sXjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YOcmzSmR;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor8523252wrj.31.2019.07.06.03.55.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 03:55:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YOcmzSmR;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=yOnUAiKnAJPyRnwGrmxELUMGxciq9fN4mgsYKTEm4Xo=;
        b=YOcmzSmR/UNNToD0RLhH7NITw9TRGeoP663jJ1Qvu9Qp/+tNc6FWjGg800f3ZPBgYk
         o9kP2re8kiDwcmAgElw1dKtRyTtM9sl5girSgedRaYR3vqqx2thwgN7a2b0L9mpJn77T
         L/LQA1kpAXw7taw9M2Br3a7nfc4zZL5EuJagvAQkDHTRjd37OTjyM+/BO1mb3MsUamay
         EtgQKJGCj3deL89lIWi0pWi5EcE/0QYW49tle/CM3BxIZ/gCMP8/gHvwIlhUUH5vlJmK
         QjywmNA2YuNcvv56XWLkSxU8oJsQwIu7EACfEL22+o21mg7SBWPg9nHHsgLrj+lUUqSl
         nlOQ==
X-Google-Smtp-Source: APXvYqyT4hM5SFnELvfQsExpct65RD8gLSUboH3nnzvhrMNPcKDDzO0rUDGJrHoUFan8ZIA5zfztxg==
X-Received: by 2002:a5d:4c86:: with SMTP id z6mr3290134wrs.330.1562410499862;
        Sat, 06 Jul 2019 03:54:59 -0700 (PDT)
Received: from localhost (net-93-71-3-102.cust.vodafonedsl.it. [93.71.3.102])
        by smtp.gmail.com with ESMTPSA id h11sm12578794wrx.93.2019.07.06.03.54.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 06 Jul 2019 03:54:59 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Brad Spengler <spender@grsecurity.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Morris <james.l.morris@oracle.com>,
	Jann Horn <jannh@google.com>,
	Kees Cook <keescook@chromium.org>,
	PaX Team <pageexec@freemail.hu>,
	Salvatore Mesoraca <s.mesoraca16@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH v5 00/12] S.A.R.A. a new stacked LSM
Date: Sat,  6 Jul 2019 12:54:41 +0200
Message-Id: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

S.A.R.A. (S.A.R.A. is Another Recursive Acronym) is a stacked Linux
Security Module that aims to collect heterogeneous security measures,
providing a common interface to manage them.
It can be useful to allow minor security features to use advanced
management options, like user-space configuration files and tools, without
too much overhead.
Some submodules that use this framework are also introduced.
The code is quite long, I apologize for this. Thank you in advance to
anyone who will take the time to review this patchset.

S.A.R.A. is meant to be stacked but it needs cred blobs and the procattr
interface, so I temporarily implemented those parts in a way that won't
be acceptable for upstream, but it works for now. I know that there
is some ongoing work to make cred blobs and procattr stackable, as soon
as the new interfaces will be available I'll reimplement the involved
parts.
At the moment I've been able to test it only on x86.

The only submodule introduced in this patchset is WX Protection.

The kernel-space part is complemented by its user-space counterpart:
saractl [1].
A test suite for WX Protection, called sara-test [2], is also available.

WX Protection aims to improve user-space programs security by applying:
- W^X enforcement: program can't have a page of memory that is marked, at
                   the same time, writable and executable.
- W!->X restriction: any page that could have been marked as writable in
                     the past won't ever be allowed to be marked as
                     executable.
- Executable MMAP prevention: prevents the creation of new executable mmaps
                              after the dynamic libraries have been loaded.
All of the above features can be enabled or disabled both system wide
or on a per executable basis through the use of configuration files managed
by "saractl".
It is important to note that some programs may have issues working with
WX Protection. In particular:
- W^X enforcement will cause problems to any programs that needs
  memory pages mapped both as writable and executable at the same time e.g.
  programs with executable stack markings in the PT_GNU_STACK segment.
- W!->X restriction will cause problems to any program that
  needs to generate executable code at run time or to modify executable
  pages e.g. programs with a JIT compiler built-in or linked against a
  non-PIC library.
- Executable MMAP prevention can work only with programs that have at least
  partial RELRO support. It's disabled automatically for programs that
  lack this feature. It will cause problems to any program that uses dlopen
  or tries to do an executable mmap. Unfortunately this feature is the one
  that could create most problems and should be enabled only after careful
  evaluation.
To extend the scope of the above features, despite the issues that they may
cause, they are complemented by:
- procattr interface: can be used by a program to discover which WX
                      Protection features are enabled and/or to tighten
                      them.
- Trampoline emulation: emulates the execution of well-known "trampolines"
                        even when they are placed in non-executable memory.
Parts of WX Protection are inspired by some of the features available in
PaX.

Thanks to the addition of extended attributes support, it's now possible to
use S.A.R.A. without being forced to rely on any special userspace tool.

More information can be found in the documentation introduced in the first
patch and in the "commit message" of the following emails.

Changes in v2:
        - Removed USB filtering submodule and relative hook
        - s/saralib/libsara/ typo
        - STR macro renamed to avoid conflicts
        - check_vmflags hook now returns an error code instead of just 1
          or 0. (suggested by Casey Schaufler)
        - pr_wxp macro rewritten as function for readability
        - Fixed i386 compilation warnings
        - Documentation now states clearly that changes done via procattr
          interface only apply to current thread. (suggested by Jann Horn)

Changes in v3:
        - Documentation has been moved to match the new directory structure.
        - Kernel cmdline arguments are now accessed via module_param interface
          (suggested by Kees Cook).
        - Created "sara_warn_or_return" macro to make WX Protection code more
          readable (suggested by Kees Cook).
        - Added more comments, in the most important places, to clarify my
          intentions (suggested by Kees Cook).
        - The "pagefault_handler" hook has been rewritten in a more "arch
          agnostic" way. Though it only support x86 at the moment
          (suggested by Kees Cook).

Changes in v4:
        - Documentation improved and some mistakes have been fixed.
        - Reduced dmesg verbosity.
        - check_vmflags is now also used to decide whether to ignore 
          GNU executable stack markings or not.
        - Added the check_vmflags hook in setup_arg_pages too.
        - Added support for extended attributes.
        - Moved trampoline emulation to arch/x86/ (suggested by Kees Cook).
        - SARA_WXP_MMAP now depends on SARA_WXP_OTHER.
        - MAC_ADMIN capability is now required also for config read.
        - Some other minor fixes not worth mentionig here.

Changes in v5:
        - Updated the code to use the new stacking interface.
        - Path matching is now done using a DFA

Salvatore Mesoraca (12):
  S.A.R.A.: add documentation
  S.A.R.A.: create framework
  S.A.R.A.: cred blob management
  S.A.R.A.: generic DFA for string matching
  LSM: creation of "check_vmflags" LSM hook
  S.A.R.A.: WX protection
  LSM: creation of "pagefault_handler" LSM hook
  S.A.R.A.: trampoline emulation
  S.A.R.A.: WX protection procattr interface
  S.A.R.A.: XATTRs support
  S.A.R.A.: /proc/*/mem write limitation
  MAINTAINERS: take maintainership for S.A.R.A.

 Documentation/admin-guide/LSM/SARA.rst          | 197 +++++
 Documentation/admin-guide/LSM/index.rst         |   1 +
 Documentation/admin-guide/kernel-parameters.txt |  40 +
 MAINTAINERS                                     |   9 +
 arch/Kconfig                                    |   6 +
 arch/x86/Kbuild                                 |   2 +
 arch/x86/Kconfig                                |   1 +
 arch/x86/mm/fault.c                             |   6 +
 arch/x86/security/Makefile                      |   2 +
 arch/x86/security/sara/Makefile                 |   1 +
 arch/x86/security/sara/emutramp.c               |  57 ++
 arch/x86/security/sara/trampolines32.h          | 137 ++++
 arch/x86/security/sara/trampolines64.h          | 164 ++++
 fs/binfmt_elf.c                                 |   3 +-
 fs/binfmt_elf_fdpic.c                           |   3 +-
 fs/exec.c                                       |   4 +
 fs/proc/base.c                                  |  11 +
 include/linux/lsm_hooks.h                       |  19 +
 include/linux/security.h                        |  17 +
 include/uapi/linux/xattr.h                      |   4 +
 mm/mmap.c                                       |  13 +
 security/Kconfig                                |  11 +-
 security/Makefile                               |   2 +
 security/sara/Kconfig                           | 176 +++++
 security/sara/Makefile                          |   5 +
 security/sara/dfa.c                             | 335 ++++++++
 security/sara/dfa_test.c                        | 135 ++++
 security/sara/include/dfa.h                     |  52 ++
 security/sara/include/dfa_test.h                |  29 +
 security/sara/include/emutramp.h                |  35 +
 security/sara/include/sara.h                    |  29 +
 security/sara/include/sara_data.h               | 100 +++
 security/sara/include/securityfs.h              |  61 ++
 security/sara/include/utils.h                   |  80 ++
 security/sara/include/wxprot.h                  |  29 +
 security/sara/main.c                            | 134 ++++
 security/sara/sara_data.c                       |  77 ++
 security/sara/securityfs.c                      | 565 ++++++++++++++
 security/sara/utils.c                           |  92 +++
 security/sara/wxprot.c                          | 998 ++++++++++++++++++++++++
 security/security.c                             |  16 +
 41 files changed, 3651 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/admin-guide/LSM/SARA.rst
 create mode 100644 arch/x86/security/Makefile
 create mode 100644 arch/x86/security/sara/Makefile
 create mode 100644 arch/x86/security/sara/emutramp.c
 create mode 100644 arch/x86/security/sara/trampolines32.h
 create mode 100644 arch/x86/security/sara/trampolines64.h
 create mode 100644 security/sara/Kconfig
 create mode 100644 security/sara/Makefile
 create mode 100644 security/sara/dfa.c
 create mode 100644 security/sara/dfa_test.c
 create mode 100644 security/sara/include/dfa.h
 create mode 100644 security/sara/include/dfa_test.h
 create mode 100644 security/sara/include/emutramp.h
 create mode 100644 security/sara/include/sara.h
 create mode 100644 security/sara/include/sara_data.h
 create mode 100644 security/sara/include/securityfs.h
 create mode 100644 security/sara/include/utils.h
 create mode 100644 security/sara/include/wxprot.h
 create mode 100644 security/sara/main.c
 create mode 100644 security/sara/sara_data.c
 create mode 100644 security/sara/securityfs.c
 create mode 100644 security/sara/utils.c
 create mode 100644 security/sara/wxprot.c

-- 
1.9.1

