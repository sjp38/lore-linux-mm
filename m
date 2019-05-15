Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCB79C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B6E72084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B6E72084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD77D6B0006; Wed, 15 May 2019 11:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE3B06B000A; Wed, 15 May 2019 11:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936F26B0007; Wed, 15 May 2019 11:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22E616B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:11:34 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id z15so457430ljj.15
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ZpcaA7VN6vMI3XLyf20y8pejyNByYJW9fpibn7OB86k=;
        b=f1aium3fdeQ3tc8Rt2+n83b6uyuP6J++IhS8PyxCEtfzoBcw+JtOKuFKQUJEJRvb0P
         4APTiED2E9thCF9ajFbrtwkPmKPfcNSFm0HPjU+PGvp1+BnxSJJE6Q4N57ydMDco+ry0
         V4BoJJzX/QwT55Qt6VtU+v8z/IpAW02F3o8SWznSb7f4vgJoTciJVY78X4bHCWnzdB8O
         NdOj3Am3JnOXe7XM7mi99RoG4y9S20+FQLznUnVbiwvI05aEgy+VVlO1QsdFYZBEuxxF
         AvHJo/v4C4hO5JzdaoZd3kg5JwxdOUmbWicsydGfn8GfCYRIbf5ss713yxjH1X4ff4iq
         fkvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXfMfEKix50C4XKEh4UvxIkIcGLqHVqW5qoSttV/LAEVA9ojVyV
	+vUydPHD9Fc46dzGy6VU9ei9D4TEsZ6ripCb+DgiMKifpxL38pz+uYW3A6YchIluMpRRkcRPPS6
	O5JK/rFTDiRQpo30pVzqTtaZPdnc154y/ApAyuMq1N4kDeYenRD3e6d/Yx2/oZt0raQ==
X-Received: by 2002:ac2:4471:: with SMTP id y17mr11099794lfl.23.1557933093356;
        Wed, 15 May 2019 08:11:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+eSQZnssZUfgHO7ShTOx/V5nJGnNcboqgAfHNPOstimtXTnKeZ05y7zD6NAt2LuvBfHpw
X-Received: by 2002:ac2:4471:: with SMTP id y17mr11099742lfl.23.1557933092265;
        Wed, 15 May 2019 08:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933092; cv=none;
        d=google.com; s=arc-20160816;
        b=ZK90Ie8dhsiuuGDlC8ZxQTk4mUe8r5CuRwGwjGnVWkSWzB/8TtWXy5KESVzkWTSk8X
         qhXZn5ax8LXrfwe4BocJiowjvADJYILKfeEqt+0U7xQ6BmaubMhxukxq/dcBw346BeYJ
         g9Ebk8D4USGZseYlHvcZqSJ6+T2WHvhqKZzBspZ13PLbN2xNarg1dGYX/8QXR42FjSyf
         2DJZ+lTdo2IQKI1oUr6zJFHMteMSj+2bVPH6wB7Z3xfNiwS/cOVmmvfLCe13blAsihKE
         k1JOUrrM5k7sZyJkmYW0mrEYFRu+SuEZfW006rkXmNhUO57lUTSP+jhsajDuXdejxol0
         0tTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=ZpcaA7VN6vMI3XLyf20y8pejyNByYJW9fpibn7OB86k=;
        b=fbiA/dRHqxZotDEnhvQqvDQCvSAoah5HVLPL6nNYNvnoq/noGB2x34WLP4Mx4v1ayt
         HGBh9C/LQDjRWYnIhEcStwnV05vLSCLlYkGVPmh8klOoQ/bFOELN/4ngeOqExUu6HK/1
         PEEDtREe8h/wDsckVIoQEx4aNmVLKTa5NTk8mzIMrHuIS7pz/t5RZetDMnMJrAazUotl
         tls59xyH8baR2eNN/JS1LTFZrQnrD8plnZCUMnZPpGWza8l8QdY0/wy6CEvwxNXKcxZ7
         19uVRhCtZ4movhlbwZfVoSx3Pr+IBBZxOPK/E/83q2Q6Aw+dJUOI+SnVsvwHxT/U+qSm
         xgig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id a30si1909560lfo.17.2019.05.15.08.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQvYw-0001X8-JJ; Wed, 15 May 2019 18:11:22 +0300
Subject: [PATCH RFC 1/5] mm: Add process_vm_mmap() syscall declaration
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 15 May 2019 18:11:22 +0300
Message-ID: <155793308232.13922.18307403112092259417.stgit@localhost.localdomain>
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to process_vm_readv() and process_vm_writev(),
add declarations of a new syscall, which will allow
to map memory from or to another process.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 arch/x86/entry/syscalls/syscall_64.tbl |    2 ++
 include/linux/syscalls.h               |    5 +++++
 include/uapi/asm-generic/unistd.h      |    5 ++++-
 init/Kconfig                           |    9 +++++----
 kernel/sys_ni.c                        |    2 ++
 6 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 4cd5f982b1e5..bf8cc5de918f 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -438,3 +438,4 @@
 425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
 426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
 427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
+428	i386	process_vm_mmap		sys_process_vm_mmap		__ia32_compat_sys_process_vm_mmap
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 64ca0d06259a..5af619c2d512 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -355,6 +355,7 @@
 425	common	io_uring_setup		__x64_sys_io_uring_setup
 426	common	io_uring_enter		__x64_sys_io_uring_enter
 427	common	io_uring_register	__x64_sys_io_uring_register
+428	common	process_vm_mmap		__x64_sys_process_vm_mmap
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
@@ -398,3 +399,4 @@
 545	x32	execveat		__x32_compat_sys_execveat/ptregs
 546	x32	preadv2			__x32_compat_sys_preadv64v2
 547	x32	pwritev2		__x32_compat_sys_pwritev64v2
+548	x32	process_vm_mmap		__x32_compat_sys_process_vm_mmap
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e2870fe1be5b..7d8ae36589cf 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -997,6 +997,11 @@ asmlinkage long sys_fspick(int dfd, const char __user *path, unsigned int flags)
 asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
 				       siginfo_t __user *info,
 				       unsigned int flags);
+asmlinkage long sys_process_vm_mmap(pid_t pid,
+				    unsigned long src_addr,
+				    unsigned long len,
+				    unsigned long dst_addr,
+				    unsigned long flags);
 
 /*
  * Architecture-specific system calls
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index dee7292e1df6..1273d86bf546 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -832,9 +832,12 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
 __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
 #define __NR_io_uring_register 427
 __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
+#define __NR_process_vm_mmap 428
+__SC_COMP(__NR_process_vm_mmap, sys_process_vm_mmap, \
+          compat_sys_process_vm_mmap)
 
 #undef __NR_syscalls
-#define __NR_syscalls 428
+#define __NR_syscalls 429
 
 /*
  * 32 bit systems traditionally used different
diff --git a/init/Kconfig b/init/Kconfig
index 8b9ffe236e4f..604db5f14718 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -320,13 +320,14 @@ config POSIX_MQUEUE_SYSCTL
 	default y
 
 config CROSS_MEMORY_ATTACH
-	bool "Enable process_vm_readv/writev syscalls"
+	bool "Enable process_vm_readv/writev/mmap syscalls"
 	depends on MMU
 	default y
 	help
-	  Enabling this option adds the system calls process_vm_readv and
-	  process_vm_writev which allow a process with the correct privileges
-	  to directly read from or write to another process' address space.
+	  Enabling this option adds the system calls process_vm_readv,
+	  process_vm_writev and process_vm_mmap, which allow a process
+	  with the correct privileges to directly read from or write to
+	  or mmap another process' address space.
 	  See the man page for more details.
 
 config USELIB
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 4d9ae5ea6caf..6f51634f4f7e 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -316,6 +316,8 @@ COND_SYSCALL(process_vm_readv);
 COND_SYSCALL_COMPAT(process_vm_readv);
 COND_SYSCALL(process_vm_writev);
 COND_SYSCALL_COMPAT(process_vm_writev);
+COND_SYSCALL(process_vm_mmap);
+COND_SYSCALL_COMPAT(process_vm_mmap);
 
 /* compare kernel pointers */
 COND_SYSCALL(kcmp);

