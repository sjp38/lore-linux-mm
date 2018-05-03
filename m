Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B82776B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:15:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r23-v6so12381809wrc.2
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:15:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w77-v6sor6252640wrb.67.2018.05.03.07.15.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 07:15:49 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 0/6] arm64: untag user pointers passed to the kernel
Date: Thu,  3 May 2018 16:15:38 +0200
Message-Id: <cover.1525356769.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

Hi!

arm64 has a feature called Top Byte Ignore, which allows to embed pointer
tags into the top byte of each pointer. Userspace programs (such as
HWASan, a memory debugging tool [1]) might use this feature and pass
tagged user pointers to the kernel through syscalls or other interfaces.

This patch makes a few of the kernel interfaces accept tagged user
pointers. The kernel is already able to handle user faults with tagged
pointers and has the untagged_addr macro, which this patchset reuses.

We're not trying to cover all possible ways the kernel accepts user
pointers in one patchset, so this one should be considered as a start.

Thanks!

[1] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html

Changes in v2:
- Rebased onto 2d618bdf (4.17-rc3+).
- Removed excessive untagging in gup.c.
- Removed untagging pointers returned from __uaccess_mask_ptr.

Changes in v1:
- Rebased onto 4.17-rc1.

Changes in RFC v2:
- Added "#ifndef untagged_addr..." fallback in linux/uaccess.h instead of
  defining it for each arch individually.
- Updated Documentation/arm64/tagged-pointers.txt.
- Dropped a??mm, arm64: untag user addresses in memory syscallsa??.
- Rebased onto 3eb2ce82 (4.16-rc7).

Andrey Konovalov (6):
  arm64: add type casts to untagged_addr macro
  uaccess: add untagged_addr definition for other arches
  arm64: untag user addresses in access_ok and __uaccess_mask_ptr
  mm, arm64: untag user addresses in mm/gup.c
  lib, arm64: untag addrs passed to strncpy_from_user and strnlen_user
  arm64: update Documentation/arm64/tagged-pointers.txt

 Documentation/arm64/tagged-pointers.txt |  5 +++--
 arch/arm64/include/asm/uaccess.h        | 14 +++++++++-----
 include/linux/uaccess.h                 |  4 ++++
 lib/strncpy_from_user.c                 |  2 ++
 lib/strnlen_user.c                      |  2 ++
 mm/gup.c                                |  4 ++++
 6 files changed, 24 insertions(+), 7 deletions(-)

-- 
2.17.0.441.gb46fe60e1d-goog
