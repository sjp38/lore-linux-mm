Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1FA6B054C
	for <linux-mm@kvack.org>; Thu, 17 May 2018 19:35:13 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q67-v6so4032110wrb.12
        for <linux-mm@kvack.org>; Thu, 17 May 2018 16:35:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d23-v6sor4652196edp.18.2018.05.17.16.35.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 16:35:12 -0700 (PDT)
From: Dmitry Safonov <dima@arista.com>
Subject: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Date: Fri, 18 May 2018 00:35:10 +0100
Message-Id: <20180517233510.24996-1-dima@arista.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dima@arista.com>, Alexey Izbyshev <izbyshev@ispras.ru>, Alexander Monakov <amonakov@ispras.ru>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, x86@kernel.org, stable@vger.kernel.org

The x86 mmap() code selects the mmap base for an allocation depending on
the bitness of the syscall. For 64bit sycalls it select mm->mmap_base and
for 32bit mm->mmap_compat_base.

exec() calls mmap() which in turn uses in_compat_syscall() to check whether
the mapping is for a 32bit or a 64bit task. The decision is made on the
following criteria:

  ia32    child->thread.status & TS_COMPAT
   x32    child->pt_regs.orig_ax & __X32_SYSCALL_BIT
  ia64    !ia32 && !x32

__set_personality_x32() was dropping TS_COMPAT flag, but
set_personality_64bit() has kept compat syscall flag making
in_compat_syscall() return true during the first exec() syscall.

Which in result has user-visible effects, mentioned by Alexey:
1) It breaks ASAN
$ gcc -fsanitize=address wrap.c -o wrap-asan
$ ./wrap32 ./wrap-asan true
==1217==Shadow memory range interleaves with an existing memory mapping. ASan cannot proceed correctly. ABORTING.
==1217==ASan shadow was supposed to be located in the [0x00007fff7000-0x10007fff7fff] range.
==1217==Process memory map follows:
        0x000000400000-0x000000401000   /home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
        0x000000600000-0x000000601000   /home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
        0x000000601000-0x000000602000   /home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
        0x0000f7dbd000-0x0000f7de2000   /lib64/ld-2.27.so
        0x0000f7fe2000-0x0000f7fe3000   /lib64/ld-2.27.so
        0x0000f7fe3000-0x0000f7fe4000   /lib64/ld-2.27.so
        0x0000f7fe4000-0x0000f7fe5000
        0x7fed9abff000-0x7fed9af54000
        0x7fed9af54000-0x7fed9af6b000   /lib64/libgcc_s.so.1
[snip]

2) It doesn't seem to be great for security if an attacker always knows
that ld.so is going to be mapped into the first 4GB in this case
(the same thing happens for PIEs as well).

The testcase:
$ cat wrap.c

int main(int argc, char *argv[]) {
  execvp(argv[1], &argv[1]);
  return 127;
}

$ gcc wrap.c -o wrap
$ LD_SHOW_AUXV=1 ./wrap ./wrap true |& grep AT_BASE
AT_BASE:         0x7f63b8309000
AT_BASE:         0x7faec143c000
AT_BASE:         0x7fbdb25fa000

$ gcc -m32 wrap.c -o wrap32
$ LD_SHOW_AUXV=1 ./wrap32 ./wrap true |& grep AT_BASE
AT_BASE:         0xf7eff000
AT_BASE:         0xf7cee000
AT_BASE:         0x7f8b9774e000

Fixes:
commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit mmap()")
commit ada26481dfe6 ("x86/mm: Make in_compat_syscall() work during exec")

Cc: Borislav Petkov <bp@suse.de>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: <linux-mm@kvack.org>
Cc: <x86@kernel.org>
Cc: <stable@vger.kernel.org> # v4.12+
Reported-by: Alexey Izbyshev <izbyshev@ispras.ru>
Bisected-by: Alexander Monakov <amonakov@ispras.ru>
Investigated-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Dmitry Safonov <dima@arista.com>
---
 arch/x86/kernel/process_64.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 4b100fe0f508..12bb445fb98d 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -542,6 +542,7 @@ void set_personality_64bit(void)
 	clear_thread_flag(TIF_X32);
 	/* Pretend that this comes from a 64bit execve */
 	task_pt_regs(current)->orig_ax = __NR_execve;
+	current_thread_info()->status &= ~TS_COMPAT;
 
 	/* Ensure the corresponding mm is not marked. */
 	if (current->mm)
-- 
2.13.6
