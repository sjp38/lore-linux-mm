Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8BFD6B0534
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:16:33 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id z18-v6so2319869lfg.17
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:16:33 -0700 (PDT)
Received: from mail.ispras.ru (mail.ispras.ru. [83.149.199.45])
        by mx.google.com with ESMTP id k26-v6si2153220lfb.3.2018.05.17.13.16.32
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 13:16:32 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 17 May 2018 23:16:31 +0300
From: Alexey Izbyshev <izbyshev@ispras.ru>
Subject: [4.11 Regression] 64-bit process gets AT_BASE in the first 4 GB if
 exec'ed from 32-bit process
Message-ID: <82328ad006ebacb399d04d638f8dad4a@ispras.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Monakov <amonakov@ispras.ru>, linux-mm@kvack.org

Hello everyone,

I've discovered the following strange behavior of a 4.15.13-based kernel 
(bisected to
  
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1b028f784e8c341e762c264f70dc0ca1418c8b7a 
between 4.11-rc2 and -rc3 thanks to Alexander Monakov).

I've reported it as 
"https://bugzilla.kernel.org/show_bug.cgi?id=199739".

$ cat wrap.c
#include <unistd.h>

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

On kernels before the referenced commit the second AT_BASE is at the 
same range as the third one.

The consequences:

1) It breaks ASAN

$ gcc -fsanitize=address wrap.c -o wrap-asan
$ ./wrap32 ./wrap-asan true
==1217==Shadow memory range interleaves with an existing memory mapping. 
ASan cannot proceed correctly. ABORTING.
==1217==ASan shadow was supposed to be located in the 
[0x00007fff7000-0x10007fff7fff] range.
==1217==Process memory map follows:
         0x000000400000-0x000000401000   
/home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
         0x000000600000-0x000000601000   
/home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
         0x000000601000-0x000000602000   
/home/izbyshev/test/gcc/asan-exec-from-32bit/wrap-asan
         0x0000f7dbd000-0x0000f7de2000   /lib64/ld-2.27.so
         0x0000f7fe2000-0x0000f7fe3000   /lib64/ld-2.27.so
         0x0000f7fe3000-0x0000f7fe4000   /lib64/ld-2.27.so
         0x0000f7fe4000-0x0000f7fe5000
         0x7fed9abff000-0x7fed9af54000
         0x7fed9af54000-0x7fed9af6b000   /lib64/libgcc_s.so.1
[snip]

2) It doesn't seem to be great for security if an attacker always knows 
that ld.so is going to be mapped into the first 4GB in this case (the 
same thing happens for PIEs as well).

Am I right that this is not the intended behavior?

-Alexey
