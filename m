Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD3C6B03BC
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 13:20:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a7so36872141pgn.1
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 10:20:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q188si2663197pfb.323.2017.03.30.10.20.35
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 10:20:36 -0700 (PDT)
Date: Thu, 30 Mar 2017 18:20:12 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Message-ID: <20170330171701.GA8062@leverpostej>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Tommi Rantala <tommi.t.rantala@nokia.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Eric Biggers <ebiggers@google.com>, Dave Jones <davej@codemonkey.org.uk>

On Thu, Mar 30, 2017 at 09:45:26AM -0700, Kees Cook wrote:
> On Wed, Mar 29, 2017 at 11:44 PM, Tommi Rantala
> <tommi.t.rantala@nokia.com> wrote:
> > Hi,
> >
> > Running:
> >
> >   $ sudo x86info -a
> >
> > On this HP ZBook 15 G3 laptop kills the x86info process with segfault and
> > produces the following kernel BUG.
> >
> >   $ git describe
> >   v4.11-rc4-40-gfe82203
> >
> > It is also reproducible with the fedora kernel: 4.9.14-200.fc25.x86_64
> >
> > Full dmesg output here: https://pastebin.com/raw/Kur2mpZq
> >
> > [   51.418954] usercopy: kernel memory exposure attempt detected from
> > ffff880000090000 (dma-kmalloc-256) (4096 bytes)
> 
> This seems like a real exposure: the copy is attempting to read 4096
> bytes from a 256 byte object.
> 
> > [...]
> > [   51.419063] Call Trace:
> > [   51.419066]  read_mem+0x70/0x120
> > [   51.419069]  __vfs_read+0x28/0x130
> > [   51.419072]  ? security_file_permission+0x9b/0xb0
> > [   51.419075]  ? rw_verify_area+0x4e/0xb0
> > [   51.419077]  vfs_read+0x96/0x130
> > [   51.419079]  SyS_read+0x46/0xb0
> > [   51.419082]  ? SyS_lseek+0x87/0xb0
> > [   51.419085]  entry_SYSCALL_64_fastpath+0x1a/0xa9
> 
> I can't reproduce this myself, so I assume it's some specific /proc or
> /sys file that I don't have. Are you able to get a strace of x86info
> as it runs to see which file it is attempting to read here?

Presumably this is /dev/mem, with read_mem in drivers/char/mem.c.

I guess you may have locked that down on your system anyhow. ;)

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
