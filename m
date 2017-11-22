Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C52C6B02A0
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:36:46 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l4so8352138wre.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:36:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g32si1078203edd.421.2017.11.22.11.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 11:36:45 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAMJYBHs095279
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:36:43 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2edfbxrs6r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:36:43 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 22 Nov 2017 19:36:41 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 0/4] vm: add a syscall to map a process memory into a pipe
Date: Wed, 22 Nov 2017 21:36:27 +0200
Message-Id: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Yossi Kuperman <yossiku@il.ibm.com>

From: Yossi Kuperman <yossiku@il.ibm.com>

Hi,

This patches introduces new process_vmsplice system call that combines
functionality of process_vm_read and vmsplice.

It allows to map the memory of another process into a pipe, similarly to
what vmsplice does for its own address space.

The patch 2/4 ("vm: add a syscall to map a process memory into a pipe")
actually adds the new system call and provides its elaborate description.

The patchset is against -mm tree.

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
 .../process_vmsplice/process_vmsplice_test.c       | 188 +++++++++++++++
 9 files changed, 450 insertions(+), 22 deletions(-)
 create mode 100644 tools/testing/selftests/process_vmsplice/Makefile
 create mode 100644 tools/testing/selftests/process_vmsplice/process_vmsplice_test.c

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
