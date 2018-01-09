Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D39496B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 01:31:08 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q185so7640521qke.2
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 22:31:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q68si2770051qkb.79.2018.01.08.22.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 22:31:07 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w096Ob1C044355
	for <linux-mm@kvack.org>; Tue, 9 Jan 2018 01:31:07 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fcm8x1nqb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jan 2018 01:31:06 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 9 Jan 2018 06:31:04 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v5 0/4] vm: add a syscall to map a process memory into a pipe
Date: Tue,  9 Jan 2018 08:30:49 +0200
Message-Id: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

This patches introduces new process_vmsplice system call that combines
functionality of process_vm_read and vmsplice.

It allows to map the memory of another process into a pipe, similarly to
what vmsplice does for its own address space.

The patch 2/4 ("vm: add a syscall to map a process memory into a pipe")
actually adds the new system call and provides its elaborate description.

The patchset is against -mm tree.

v5: update changelog with more elaborate usecase description
v4: skip test when process_vmsplice syscall is not available
v3: minor refactoring to reduce code duplication
v2: move this syscall under CONFIG_CROSS_MEMORY_ATTACH
    give correct flags to get_user_pages_remote()


Andrei Vagin (3):
  vm: add a syscall to map a process memory into a pipe
  x86: wire up the process_vmsplice syscall
  test: add a test for the process_vmsplice syscall

Mike Rapoport (1):
  fs/splice: introduce pages_to_pipe helper

 arch/x86/entry/syscalls/syscall_32.tbl             |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl             |   2 +
 fs/splice.c                                        | 262 +++++++++++++++++++--
 include/linux/compat.h                             |   3 +
 include/linux/syscalls.h                           |   4 +
 include/uapi/asm-generic/unistd.h                  |   5 +-
 kernel/sys_ni.c                                    |   2 +
 tools/testing/selftests/process_vmsplice/Makefile  |   5 +
 .../process_vmsplice/process_vmsplice_test.c       | 196 +++++++++++++++
 9 files changed, 458 insertions(+), 22 deletions(-)
 create mode 100644 tools/testing/selftests/process_vmsplice/Makefile
 create mode 100644 tools/testing/selftests/process_vmsplice/process_vmsplice_test.c

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
