Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA0D76B0008
	for <linux-mm@kvack.org>; Mon, 21 May 2018 17:24:16 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b31-v6so10816609plb.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 14:24:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j6-v6si11744799pgp.534.2018.05.21.14.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 14:24:15 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.16 050/110] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Date: Mon, 21 May 2018 23:11:47 +0200
Message-Id: <20180521210509.418263210@linuxfoundation.org>
In-Reply-To: <20180521210503.823249477@linuxfoundation.org>
References: <20180521210503.823249477@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Alexey Izbyshev <izbyshev@ispras.ru>, Dmitry Safonov <dima@arista.com>, Thomas Gleixner <tglx@linutronix.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Alexander Monakov <amonakov@ispras.ru>, Dmitry Safonov <0x7f454c46@gmail.com>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

4.16-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dmitry Safonov <dima@arista.com>

commit acf46020012ccbca1172e9c7aeab399c950d9212 upstream.

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

Fixes: 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit mmap()")
Fixes: ada26481dfe6 ("x86/mm: Make in_compat_syscall() work during exec")
Reported-by: Alexey Izbyshev <izbyshev@ispras.ru>
Bisected-by: Alexander Monakov <amonakov@ispras.ru>
Investigated-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Dmitry Safonov <dima@arista.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: Alexander Monakov <amonakov@ispras.ru>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: stable@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Link: https://lkml.kernel.org/r/20180517233510.24996-1-dima@arista.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/kernel/process_64.c |    1 +
 1 file changed, 1 insertion(+)

--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -528,6 +528,7 @@ void set_personality_64bit(void)
 	clear_thread_flag(TIF_X32);
 	/* Pretend that this comes from a 64bit execve */
 	task_pt_regs(current)->orig_ax = __NR_execve;
+	current_thread_info()->status &= ~TS_COMPAT;
 
 	/* Ensure the corresponding mm is not marked. */
 	if (current->mm)
