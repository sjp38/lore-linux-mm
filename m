Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9144F6B02B4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 12:43:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 56so4295216wrx.5
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:43:43 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id n45si605864wrn.91.2017.06.15.09.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 09:43:36 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id x23so4287832wrb.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 09:43:36 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v2 0/9] S.A.R.A. a new stacked LSM
Date: Thu, 15 Jun 2017 18:42:47 +0200
Message-Id: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

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

[1] https://github.com/smeso/saractl
[2] https://github.com/smeso/sara-test

Salvatore Mesoraca (9):
  S.A.R.A. Documentation
  S.A.R.A. framework creation
  Creation of "check_vmflags" LSM hook
  S.A.R.A. cred blob management
  S.A.R.A. WX Protection
  Creation of "pagefault_handler_x86" LSM hook
  Trampoline emulation
  Allowing for stacking procattr support in S.A.R.A.
  S.A.R.A. WX Protection procattr interface

 Documentation/admin-guide/kernel-parameters.txt |  23 +
 Documentation/security/00-INDEX                 |   2 +
 Documentation/security/SARA.rst                 | 170 +++++
 arch/x86/mm/fault.c                             |   6 +
 fs/proc/base.c                                  |  38 +
 include/linux/cred.h                            |   3 +
 include/linux/lsm_hooks.h                       |  21 +
 include/linux/security.h                        |  17 +
 mm/mmap.c                                       |  13 +
 security/Kconfig                                |   1 +
 security/Makefile                               |   2 +
 security/sara/Kconfig                           | 134 ++++
 security/sara/Makefile                          |   4 +
 security/sara/include/sara.h                    |  29 +
 security/sara/include/sara_data.h               |  47 ++
 security/sara/include/securityfs.h              |  59 ++
 security/sara/include/trampolines.h             | 171 +++++
 security/sara/include/utils.h                   |  69 ++
 security/sara/include/wxprot.h                  |  27 +
 security/sara/main.c                            | 107 +++
 security/sara/sara_data.c                       |  79 ++
 security/sara/securityfs.c                      | 560 +++++++++++++++
 security/sara/utils.c                           | 151 ++++
 security/sara/wxprot.c                          | 910 ++++++++++++++++++++++++
 security/security.c                             |  37 +-
 25 files changed, 2678 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/security/SARA.rst
 create mode 100644 security/sara/Kconfig
 create mode 100644 security/sara/Makefile
 create mode 100644 security/sara/include/sara.h
 create mode 100644 security/sara/include/sara_data.h
 create mode 100644 security/sara/include/securityfs.h
 create mode 100644 security/sara/include/trampolines.h
 create mode 100644 security/sara/include/utils.h
 create mode 100644 security/sara/include/wxprot.h
 create mode 100644 security/sara/main.c
 create mode 100644 security/sara/sara_data.c
 create mode 100644 security/sara/securityfs.c
 create mode 100644 security/sara/utils.c
 create mode 100644 security/sara/wxprot.c

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
