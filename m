Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B67BD6B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:33 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v8so8516198wrd.21
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e131sor461060wma.88.2017.11.21.10.26.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:31 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 00/10] S.A.R.A. a new stacked LSM
Date: Tue, 21 Nov 2017 19:26:02 +0100
Message-Id: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

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

[1] https://github.com/smeso/saractl
[2] https://github.com/smeso/sara-test

Salvatore Mesoraca (10):
  S.A.R.A. Documentation
  S.A.R.A. framework creation
  Creation of "check_vmflags" LSM hook
  S.A.R.A. cred blob management
  S.A.R.A. WX Protection
  Creation of "pagefault_handler" LSM hook
  Trampoline emulation
  Allowing for stacking procattr support in S.A.R.A.
  S.A.R.A. WX Protection procattr interface
  XATTRs support

 Documentation/admin-guide/LSM/SARA.rst          |  193 +++++
 Documentation/admin-guide/LSM/index.rst         |    1 +
 Documentation/admin-guide/kernel-parameters.txt |   40 +
 arch/Kconfig                                    |    6 +
 arch/x86/Kbuild                                 |    2 +
 arch/x86/Kconfig                                |    1 +
 arch/x86/mm/fault.c                             |    6 +
 arch/x86/security/Makefile                      |    2 +
 arch/x86/security/sara/Makefile                 |    1 +
 arch/x86/security/sara/emutramp.c               |   55 ++
 arch/x86/security/sara/trampolines32.h          |  122 +++
 arch/x86/security/sara/trampolines64.h          |  148 ++++
 fs/binfmt_elf.c                                 |    3 +-
 fs/binfmt_elf_fdpic.c                           |    3 +-
 fs/exec.c                                       |    4 +
 fs/proc/base.c                                  |   38 +
 include/linux/cred.h                            |    3 +
 include/linux/lsm_hooks.h                       |   24 +
 include/linux/security.h                        |   17 +
 include/uapi/linux/xattr.h                      |    4 +
 mm/mmap.c                                       |   13 +
 security/Kconfig                                |    1 +
 security/Makefile                               |    2 +
 security/sara/Kconfig                           |  154 ++++
 security/sara/Makefile                          |    4 +
 security/sara/include/emutramp.h                |   33 +
 security/sara/include/sara.h                    |   29 +
 security/sara/include/sara_data.h               |   55 ++
 security/sara/include/securityfs.h              |   59 ++
 security/sara/include/utils.h                   |   80 ++
 security/sara/include/wxprot.h                  |   27 +
 security/sara/main.c                            |  117 +++
 security/sara/sara_data.c                       |   79 ++
 security/sara/securityfs.c                      |  563 +++++++++++++
 security/sara/utils.c                           |  151 ++++
 security/sara/wxprot.c                          | 1017 +++++++++++++++++++++++
 security/security.c                             |   37 +-
 37 files changed, 3090 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/admin-guide/LSM/SARA.rst
 create mode 100644 arch/x86/security/Makefile
 create mode 100644 arch/x86/security/sara/Makefile
 create mode 100644 arch/x86/security/sara/emutramp.c
 create mode 100644 arch/x86/security/sara/trampolines32.h
 create mode 100644 arch/x86/security/sara/trampolines64.h
 create mode 100644 security/sara/Kconfig
 create mode 100644 security/sara/Makefile
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
