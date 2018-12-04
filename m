Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 558D16B6D90
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:37:26 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y88so13328217pfi.9
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:37:26 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s13si14970777pgc.509.2018.12.03.23.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:37:24 -0800 (PST)
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Mon,  3 Dec 2018 23:39:47 -0800
Message-Id: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

Hi Thomas, David,

Here is an updated RFC on the API's to support MKTME.
(Multi-Key Total Memory Encryption)

This RFC presents the 2 API additions to support the creation and
usage of memory encryption keys:
 1) Kernel Key Service type "mktme"
 2) System call encrypt_mprotect()

This patchset is built upon Kirill Shutemov's work for the core MKTME
support.

David: Please let me know if the changes made, based on your review,
are reasonable. I don't think that the new changes touch key service
specific areas (much).

Thomas: Please provide feedback on encrypt_mprotect(). If not a
review, then a direction check would be helpful.

I picked up a few more 'CCs this time in get_maintainer!

Thanks!
Alison


Changes in RFC2
Add a preparser to mktme key service. (dhowells)
Replace key serial no. with key struct point in mktme_map. (dhowells)
Remove patch that inserts a special MKTME case in keyctl revoke. (dhowells)
Updated key usage syntax in the documentation (Kai)
Replaced NO_PKEY, NO_KEYID with a single constant NO_KEY. (Jarkko)
Clarified comments in changelog and code. (Jarkko)
Add clear, no-encrypt, and update key support.
Add mktme_savekeys (Patch 12 ) to give kernel permission to save key data.
Add cpu hotplug support. (Patch 13)

Alison Schofield (13):
  x86/mktme: Document the MKTME APIs
  mm: Generalize the mprotect implementation to support extensions
  syscall/x86: Wire up a new system call for memory encryption keys
  x86/mm: Add helper functions for MKTME memory encryption keys
  x86/mm: Set KeyIDs in encrypted VMAs
  mm: Add the encrypt_mprotect() system call
  x86/mm: Add helpers for reference counting encrypted VMAs
  mm: Use reference counting for encrypted VMAs
  mm: Restrict memory encryption to anonymous VMA's
  keys/mktme: Add the MKTME Key Service type for memory encryption
  keys/mktme: Program memory encryption keys on a system wide basis
  keys/mktme: Save MKTME data if kernel cmdline parameter allows
  keys/mktme: Support CPU Hotplug for MKTME keys

 Documentation/admin-guide/kernel-parameters.rst |   1 +
 Documentation/admin-guide/kernel-parameters.txt |  11 +
 Documentation/x86/mktme/index.rst               |  11 +
 Documentation/x86/mktme/mktme_demo.rst          |  53 +++
 Documentation/x86/mktme/mktme_encrypt.rst       |  58 +++
 Documentation/x86/mktme/mktme_keys.rst          | 109 +++++
 Documentation/x86/mktme/mktme_overview.rst      |  60 +++
 arch/x86/Kconfig                                |   1 +
 arch/x86/entry/syscalls/syscall_32.tbl          |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl          |   1 +
 arch/x86/include/asm/mktme.h                    |  25 +
 arch/x86/mm/mktme.c                             | 179 ++++++++
 fs/exec.c                                       |   4 +-
 include/keys/mktme-type.h                       |  41 ++
 include/linux/key.h                             |   2 +
 include/linux/mm.h                              |  11 +-
 include/linux/syscalls.h                        |   2 +
 include/uapi/asm-generic/unistd.h               |   4 +-
 kernel/fork.c                                   |   2 +
 kernel/sys_ni.c                                 |   2 +
 mm/mprotect.c                                   |  91 +++-
 security/keys/Kconfig                           |  11 +
 security/keys/Makefile                          |   1 +
 security/keys/mktme_keys.c                      | 580 ++++++++++++++++++++++++
 24 files changed, 1249 insertions(+), 12 deletions(-)
 create mode 100644 Documentation/x86/mktme/index.rst
 create mode 100644 Documentation/x86/mktme/mktme_demo.rst
 create mode 100644 Documentation/x86/mktme/mktme_encrypt.rst
 create mode 100644 Documentation/x86/mktme/mktme_keys.rst
 create mode 100644 Documentation/x86/mktme/mktme_overview.rst
 create mode 100644 include/keys/mktme-type.h
 create mode 100644 security/keys/mktme_keys.c

-- 
2.14.1
