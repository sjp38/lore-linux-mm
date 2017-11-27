Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B71B6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:19:55 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v186so10531715wma.9
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 23:19:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t4si4709291edt.483.2017.11.26.23.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 23:19:54 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAR7ImWN120534
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:19:52 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2eg8tr430v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:19:52 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 07:19:50 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v4 0/4] vm: add a syscall to map a process memory into a pipe
Date: Mon, 27 Nov 2017 09:19:37 +0200
Message-Id: <1511767181-22793-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

This patches introduces new process_vmsplice system call that combines
functionality of process_vm_read and vmsplice.

It allows to map the memory of another process into a pipe, similarly to
what vmsplice does for its own address space.

The patch 2/4 ("vm: add a syscall to map a process memory into a pipe")
actually adds the new system call and provides its elaborate description.

The patchset is against -mm tree.

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
