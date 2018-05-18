Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB5786B0582
	for <linux-mm@kvack.org>; Fri, 18 May 2018 03:20:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a5-v6so2796362lfi.8
        for <linux-mm@kvack.org>; Fri, 18 May 2018 00:20:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e30-v6sor1932134lfb.0.2018.05.18.00.20.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 00:20:31 -0700 (PDT)
Date: Fri, 18 May 2018 10:20:26 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Message-ID: <20180518072026.GY31735@uranus>
References: <20180517233510.24996-1-dima@arista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180517233510.24996-1-dima@arista.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dima@arista.com>
Cc: linux-kernel@vger.kernel.org, Alexey Izbyshev <izbyshev@ispras.ru>, Alexander Monakov <amonakov@ispras.ru>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Dmitry Safonov <0x7f454c46@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, x86@kernel.org, stable@vger.kernel.org

On Fri, May 18, 2018 at 12:35:10AM +0100, Dmitry Safonov wrote:
> The x86 mmap() code selects the mmap base for an allocation depending on
> the bitness of the syscall. For 64bit sycalls it select mm->mmap_base and
> for 32bit mm->mmap_compat_base.
> 
> exec() calls mmap() which in turn uses in_compat_syscall() to check whether
> the mapping is for a 32bit or a 64bit task. The decision is made on the
> following criteria:
> 
>   ia32    child->thread.status & TS_COMPAT
>    x32    child->pt_regs.orig_ax & __X32_SYSCALL_BIT
>   ia64    !ia32 && !x32
> 
> __set_personality_x32() was dropping TS_COMPAT flag, but
> set_personality_64bit() has kept compat syscall flag making
> in_compat_syscall() return true during the first exec() syscall.
> 
> Which in result has user-visible effects, mentioned by Alexey:
> 1) It breaks ASAN
> $ gcc -fsanitize=address wrap.c -o wrap-asan
> $ ./wrap32 ./wrap-asan true
> ==1217==Shadow memory range interleaves with an existing memory mapping. ASan cannot proceed correctly. ABORTING.
> ==1217==ASan shadow was supposed to be located in the [0x00007fff7000-0x10007fff7fff] range.
> ==1217==Process memory map follows:
>         0x000000400000-0x000000401000   /home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
>         0x000000600000-0x000000601000   /home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
>         0x000000601000-0x000000602000   /home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
>         0x0000f7dbd000-0x0000f7de2000   /lib64/ld-2.27.so
>         0x0000f7fe2000-0x0000f7fe3000   /lib64/ld-2.27.so
>         0x0000f7fe3000-0x0000f7fe4000   /lib64/ld-2.27.so
>         0x0000f7fe4000-0x0000f7fe5000
>         0x7fed9abff000-0x7fed9af54000
>         0x7fed9af54000-0x7fed9af6b000   /lib64/libgcc_s.so.1
> [snip]
> 
> 2) It doesn't seem to be great for security if an attacker always knows
> that ld.so is going to be mapped into the first 4GB in this case
> (the same thing happens for PIEs as well).
> 
> The testcase:
> $ cat wrap.c
> 
> int main(int argc, char *argv[]) {
>   execvp(argv[1], &argv[1]);
>   return 127;
> }
> 
> $ gcc wrap.c -o wrap
> $ LD_SHOW_AUXV=1 ./wrap ./wrap true |& grep AT_BASE
> AT_BASE:         0x7f63b8309000
> AT_BASE:         0x7faec143c000
> AT_BASE:         0x7fbdb25fa000
> 
> $ gcc -m32 wrap.c -o wrap32
> $ LD_SHOW_AUXV=1 ./wrap32 ./wrap true |& grep AT_BASE
> AT_BASE:         0xf7eff000
> AT_BASE:         0xf7cee000
> AT_BASE:         0x7f8b9774e000
> 
> Fixes:
> commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit mmap()")
> commit ada26481dfe6 ("x86/mm: Make in_compat_syscall() work during exec")
> 
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Dmitry Safonov <0x7f454c46@gmail.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: <linux-mm@kvack.org>
> Cc: <x86@kernel.org>
> Cc: <stable@vger.kernel.org> # v4.12+
> Reported-by: Alexey Izbyshev <izbyshev@ispras.ru>
> Bisected-by: Alexander Monakov <amonakov@ispras.ru>
> Investigated-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Dmitry Safonov <dima@arista.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thanks a lot! (At first I had to scratch my head for a second
to realize that the key moment is executing 64 bit application
from inside of a compat process :-)
