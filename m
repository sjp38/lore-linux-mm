Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C974D6B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 15:52:33 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 68so277127itx.12
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:52:33 -0700 (PDT)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id z186si129949itd.89.2017.03.30.12.52.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 12:52:33 -0700 (PDT)
Received: by mail-it0-x229.google.com with SMTP id y18so683341itc.1
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:52:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com> <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 30 Mar 2017 12:52:31 -0700
Message-ID: <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Kees Cook <keescook@chromium.org>, Tommi Rantala <tommi.t.rantala@nokia.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On Thu, Mar 30, 2017 at 12:41 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Thu, Mar 30, 2017 at 09:45:26AM -0700, Kees Cook wrote:
>  > On Wed, Mar 29, 2017 at 11:44 PM, Tommi Rantala
>  > <tommi.t.rantala@nokia.com> wrote:
>  > > Hi,
>  > >
>  > > Running:
>  > >
>  > >   $ sudo x86info -a
>  > >
>  > > On this HP ZBook 15 G3 laptop kills the x86info process with segfault and
>  > > produces the following kernel BUG.
>  > >
>  > >   $ git describe
>  > >   v4.11-rc4-40-gfe82203
>  > >
>  > > It is also reproducible with the fedora kernel: 4.9.14-200.fc25.x86_64
>  > >
>  > > Full dmesg output here: https://pastebin.com/raw/Kur2mpZq
>  > >
>  > > [   51.418954] usercopy: kernel memory exposure attempt detected from
>  > > ffff880000090000 (dma-kmalloc-256) (4096 bytes)
>  >
>  > This seems like a real exposure: the copy is attempting to read 4096
>  > bytes from a 256 byte object.
>
> The code[1] is doing a 4k read from /dev/mem in the range 0x90000 -> 0xa0000
> According to arch/x86/mm/init.c:devmem_is_allowed, that's still valid..
>
> Note that the printk is using the direct mapping address. Is that what's
> being passed down to devmem_is_allowed now ? If so, that's probably what broke.

So this is attempting to read physical memory 0x90000 -> 0xa0000, but
that's somehow resolving to a virtual address that is claimed by
dma-kmalloc?? I'm confused how that's happening...

-Kees

>
>         Dave
>
> [1] https://github.com/kernelslacker/x86info/blob/master/mptable.c



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
