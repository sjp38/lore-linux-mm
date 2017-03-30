Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE002806CB
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:45:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n77so31105610itn.8
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:45:28 -0700 (PDT)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id p11si3243956ioe.152.2017.03.30.09.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 09:45:27 -0700 (PDT)
Received: by mail-it0-x229.google.com with SMTP id 190so78034948itm.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:45:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 30 Mar 2017 09:45:26 -0700
Message-ID: <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tommi Rantala <tommi.t.rantala@nokia.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>, Dave Jones <davej@codemonkey.org.uk>

On Wed, Mar 29, 2017 at 11:44 PM, Tommi Rantala
<tommi.t.rantala@nokia.com> wrote:
> Hi,
>
> Running:
>
>   $ sudo x86info -a
>
> On this HP ZBook 15 G3 laptop kills the x86info process with segfault and
> produces the following kernel BUG.
>
>   $ git describe
>   v4.11-rc4-40-gfe82203
>
> It is also reproducible with the fedora kernel: 4.9.14-200.fc25.x86_64
>
> Full dmesg output here: https://pastebin.com/raw/Kur2mpZq
>
> [   51.418954] usercopy: kernel memory exposure attempt detected from
> ffff880000090000 (dma-kmalloc-256) (4096 bytes)

This seems like a real exposure: the copy is attempting to read 4096
bytes from a 256 byte object.

> [...]
> [   51.419063] Call Trace:
> [   51.419066]  read_mem+0x70/0x120
> [   51.419069]  __vfs_read+0x28/0x130
> [   51.419072]  ? security_file_permission+0x9b/0xb0
> [   51.419075]  ? rw_verify_area+0x4e/0xb0
> [   51.419077]  vfs_read+0x96/0x130
> [   51.419079]  SyS_read+0x46/0xb0
> [   51.419082]  ? SyS_lseek+0x87/0xb0
> [   51.419085]  entry_SYSCALL_64_fastpath+0x1a/0xa9

I can't reproduce this myself, so I assume it's some specific /proc or
/sys file that I don't have. Are you able to get a strace of x86info
as it runs to see which file it is attempting to read here?

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
