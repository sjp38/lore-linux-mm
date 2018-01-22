Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86C33828CD
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:53:55 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id a21so15903728qtd.6
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:53:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f28sor10627044qtf.53.2018.01.22.10.53.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:53:54 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 22/24] selftests/vm: Fix deadlock in protection_keys.c
Date: Mon, 22 Jan 2018 10:52:15 -0800
Message-Id: <1516647137-11174-23-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
References: <1516647137-11174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>

The sig_chld() handler calls dprintf2() taking care of setting
dprint_in_signal so that sigsafe_printf() won't call printf().
Unfortunately, this precaution is is negated by dprintf_level(), which
has a call to fflush().

This function acquires a lock, which means that if the signal interrupts an
ongoing fflush() the process will deadlock. At least on powerpc this is
easy to trigger, resulting in the following backtrace when attaching to the
frozen process:

  (gdb) bt
  #0  0x00007fff9f96c7d8 in __lll_lock_wait_private () from /lib64/power8/libc.so.6
  #1  0x00007fff9f8cba4c in _IO_flush_all_lockp () from /lib64/power8/libc.so.6
  #2  0x00007fff9f8cbd1c in __GI__IO_flush_all () from /lib64/power8/libc.so.6
  #3  0x00007fff9f8b7424 in fflush () from /lib64/power8/libc.so.6
  #4  0x00000000100504f8 in sig_chld (x=17) at protection_keys.c:283
  #5  <signal handler called>
  #6  0x00007fff9f8cb8ac in _IO_flush_all_lockp () from /lib64/power8/libc.so.6
  #7  0x00007fff9f8cbd1c in __GI__IO_flush_all () from /lib64/power8/libc.so.6
  #8  0x00007fff9f8b7424 in fflush () from /lib64/power8/libc.so.6
  #9  0x0000000010050b50 in pkey_get (pkey=7, flags=0) at protection_keys.c:379
  #10 0x0000000010050dc0 in pkey_disable_set (pkey=7, flags=2) at protection_keys.c:423
  #11 0x0000000010051414 in pkey_write_deny (pkey=7) at protection_keys.c:486
  #12 0x00000000100556bc in test_ptrace_of_child (ptr=0x7fff9f7f0000, pkey=7) at protection_keys.c:1288
  #13 0x0000000010055f60 in run_tests_once () at protection_keys.c:1414
  #14 0x00000000100561a4 in main () at protection_keys.c:1459

The fix is to refrain from calling fflush() when inside a signal handler.
The output may not be as pretty but at least the testcase will be able to
move on.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>

 tools/testing/selftests/vm/pkey-helpers.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
---
 tools/testing/selftests/vm/pkey-helpers.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 9d06b4a..965cfcd 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -131,7 +131,8 @@ static inline void sigsafe_printf(const char *format, ...)
 #define dprintf_level(level, args...) do {	\
 	if (level <= DEBUG_LEVEL)		\
 		sigsafe_printf(args);		\
-	fflush(NULL);				\
+	if (!dprint_in_signal)			\
+		fflush(NULL);			\
 } while (0)
 #define dprintf0(args...) dprintf_level(0, args)
 #define dprintf1(args...) dprintf_level(1, args)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
