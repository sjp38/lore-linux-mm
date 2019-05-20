Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89A40C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2E35216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2E35216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 348196B0005; Mon, 20 May 2019 10:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F8B06B0007; Mon, 20 May 2019 10:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8746B0008; Mon, 20 May 2019 10:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADBC26B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:20 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id k27so2626600lfj.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=P9jpEkBpQw4ZOTJz/Lsq/b2TN30uIH42X6duHPmvzHQ=;
        b=sYhOSgTsdFnRBGcmO0M9WgQ9Z4i2jgQDKvJ6q0W5Pyew/EGEX4GVxc5l8RYRmHi9+L
         khA2b2KUcF1B/Xm5XkB1LtchHh3mMjzZS1TLEeD+79iBHV14JN05FoVnbMvqnpDMlifn
         978/zs4NjJVdlN8mxCD+Ab5e/aqtFFqTfVlIwHBkyeufHpgRnTLluqu0r8T4RZ8HtWFJ
         RnKz+rqJHj6XNqjZTjDMJtV+IOXqY1jLntCSSBhxSO0c6dPxl9sKsHuXP3Nm2ht1cvCV
         Nvi9Jrrq7Sso9N1CRzZz7Y2Cj1q3Jpqf4E/F2fgySSC3PTtz6rFmLtNkt9Ns5wFu60Ld
         c8FQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV2GWivJ+w9rPdnX4dRbC/YZiKWY/gYJhBxwv8Uop3rk7w8tlca
	kM6Jj/W9gC7qI6pwdEALiCK2g+DP0hTU4xHfehQnrG6zUp+u09JX7SJLS/i8xOI/l18Q+NovUV7
	C+wqwJOJtRrJU2Be5wLxQWMpcH0AE2Naq7WSaiUnzgUW7OHxme9Kjsm/VDLNh4I0vmg==
X-Received: by 2002:a2e:6c01:: with SMTP id h1mr11453377ljc.103.1558360820084;
        Mon, 20 May 2019 07:00:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvIFY2gmflkBFAm0egeSOWhkwbXSrar61W7xgpDkbLNIg6pQ9PwBSiOOuHSDXl195uZsCD
X-Received: by 2002:a2e:6c01:: with SMTP id h1mr11453292ljc.103.1558360818877;
        Mon, 20 May 2019 07:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360818; cv=none;
        d=google.com; s=arc-20160816;
        b=G6oblSEckf18kH+mrThEc8lgErKiViB37+QilLIJGQ33pk3GO3AJSbaNc0Xu76HH7K
         wKbmSR1MUwUUIXuukEQbkbdYZ58D50Qswdi18klAetAs8+IzHHmtZ+LBBtUOj6orrCkv
         Gx7ZsRV4dEsQ6458mCyXmuEXx0/BT07aeBad0wYxbjl4xDAW6mExD5yH6kXVam0Ur7mE
         VkAmvc8oMLk9L4TFfKsSCMcA4uAwUZ3YHRlwtndi2j5WPUTJ1s77evjWFIKuO6MIPIwW
         joFpHMVocPjukvbDxuGznwTdKEf1HHX2VBWyfxwk0NgHjTSACJmcEqxEn3IYW5793uAf
         MMxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=P9jpEkBpQw4ZOTJz/Lsq/b2TN30uIH42X6duHPmvzHQ=;
        b=St1IlvzuHRfF5/1q5aSqh/iu4u7UaXHn/hjFCOIybU3InMRE012X+cq4MwVz4VmoXF
         XIrMYZaYOTYf+n8emxGrKx3V5ImqtpcK7qHqqP4niFbi/PLq7p8Hl8JSkmSZy+saH6n9
         GEXqQwM+EOYC0CMnnzaEKzGFSAb7DPbesLclpEYnmAGB/5niXkNS7kVv0KZ9d6l6MzSP
         hLBY1un8cKjLa/XqW3Kge1qAsxqNrXtKa2OAYBDY1lFqTFFzSvR7EjFMMnMd/5ZPvg5q
         XHkvXNCnGFtW/2bmGHQkjNqdjYJli5hI5rWkw+ve9Hq7gyLQYhgdMc9iqRg5nMOl2WtX
         kslQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id b24si11314377lji.187.2019.05.20.07.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSipj-00082Z-CF; Mon, 20 May 2019 17:00:07 +0300
Subject: [PATCH v2 1/7] mm: Add process_vm_mmap() syscall declaration
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:07 +0300
Message-ID: <155836080726.2441.11153759042802992469.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
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
index ad968b7bac72..99d6e0085576 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -438,3 +438,4 @@
 431	i386	fsconfig		sys_fsconfig			__ia32_sys_fsconfig
 432	i386	fsmount			sys_fsmount			__ia32_sys_fsmount
 433	i386	fspick			sys_fspick			__ia32_sys_fspick
+434	i386	process_vm_mmap		sys_process_vm_mmap		__ia32_compat_sys_process_vm_mmap
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index b4e6f9e6204a..46d7d2898f7a 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -355,6 +355,7 @@
 431	common	fsconfig		__x64_sys_fsconfig
 432	common	fsmount			__x64_sys_fsmount
 433	common	fspick			__x64_sys_fspick
+434	common	process_vm_mmap		__x64_sys_process_vm_mmap
 
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
index a87904daf103..b7aaa5ae02da 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -844,9 +844,12 @@ __SYSCALL(__NR_fsconfig, sys_fsconfig)
 __SYSCALL(__NR_fsmount, sys_fsmount)
 #define __NR_fspick 433
 __SYSCALL(__NR_fspick, sys_fspick)
+#define __NR_process_vm_mmap 424
+__SC_COMP(__NR_process_vm_mmap, sys_process_vm_mmap, \
+          compat_sys_process_vm_mmap)
 
 #undef __NR_syscalls
-#define __NR_syscalls 434
+#define __NR_syscalls 435
 
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

