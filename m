Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 399956B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 01:40:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id m33so14152275wrm.23
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 22:40:08 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0135.outbound.protection.outlook.com. [104.47.1.135])
        by mx.google.com with ESMTPS id 10si6613993wrt.64.2017.03.30.22.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 22:40:06 -0700 (PDT)
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk>
 <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170330200100.zcyndf3kimepg77o@codemonkey.org.uk>
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Message-ID: <81379c63-674c-a37f-a6f6-5af385138a25@nokia.com>
Date: Fri, 31 Mar 2017 08:40:00 +0300
MIME-Version: 1.0
In-Reply-To: <20170330200100.zcyndf3kimepg77o@codemonkey.org.uk>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>



On 30.03.2017 23:01, Dave Jones wrote:
> On Thu, Mar 30, 2017 at 12:52:31PM -0700, Kees Cook wrote:
>  > On Thu, Mar 30, 2017 at 12:41 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
>  > > On Thu, Mar 30, 2017 at 09:45:26AM -0700, Kees Cook wrote:
>  > >  > On Wed, Mar 29, 2017 at 11:44 PM, Tommi Rantala
>  > >  > <tommi.t.rantala@nokia.com> wrote:
>  > >  > > Hi,
>  > >  > >
>  > >  > > Running:
>  > >  > >
>  > >  > >   $ sudo x86info -a
>  > >  > >
>  > >  > > On this HP ZBook 15 G3 laptop kills the x86info process with segfault and
>  > >  > > produces the following kernel BUG.
>  > >  > >
>  > >  > >   $ git describe
>  > >  > >   v4.11-rc4-40-gfe82203
>  > >  > >
>  > >  > > It is also reproducible with the fedora kernel: 4.9.14-200.fc25.x86_64
>  > >  > >
>  > >  > > Full dmesg output here: https://pastebin.com/raw/Kur2mpZq
>  > >  > >
>  > >  > > [   51.418954] usercopy: kernel memory exposure attempt detected from
>  > >  > > ffff880000090000 (dma-kmalloc-256) (4096 bytes)
>  > >  >
>  > >  > This seems like a real exposure: the copy is attempting to read 4096
>  > >  > bytes from a 256 byte object.
>  > >
>  > > The code[1] is doing a 4k read from /dev/mem in the range 0x90000 -> 0xa0000
>  > > According to arch/x86/mm/init.c:devmem_is_allowed, that's still valid..
>  > >
>  > > Note that the printk is using the direct mapping address. Is that what's
>  > > being passed down to devmem_is_allowed now ? If so, that's probably what broke.
>  >
>  > So this is attempting to read physical memory 0x90000 -> 0xa0000, but
>  > that's somehow resolving to a virtual address that is claimed by
>  > dma-kmalloc?? I'm confused how that's happening...
>
> The only thing that I can think of would be a rogue ptr in the bios
> table, but that seems unlikely.  Tommi, can you put strace of x86info -mp somewhere?
> That will confirm/deny whether we're at least asking the kernel to do sane things.

Indeed the bug happens when reading from /dev/mem:

https://pastebin.com/raw/ZEJGQP1X

# strace -f -y x86info -mp
[...]
open("/dev/mem", O_RDONLY)              = 3</dev/mem>
lseek(3</dev/mem>, 1038, SEEK_SET)      = 1038
read(3</dev/mem>, "\300\235", 2)        = 2
lseek(3</dev/mem>, 646144, SEEK_SET)    = 646144
read(3</dev/mem>, 
"\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
1024) = 1024
lseek(3</dev/mem>, 1043, SEEK_SET)      = 1043
read(3</dev/mem>, "w\2", 2)             = 2
lseek(3</dev/mem>, 645120, SEEK_SET)    = 645120
read(3</dev/mem>, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
1024) = 1024
lseek(3</dev/mem>, 654336, SEEK_SET)    = 654336
read(3</dev/mem>, 
"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
1024) = 1024
lseek(3</dev/mem>, 983040, SEEK_SET)    = 983040
read(3</dev/mem>, 
"IFE$\245S\0\0\1\0\0\0\0\360y\0\0\360\220\260\30\237{=\23\10\17\0000\276\17\0"..., 
65536) = 65536
lseek(3</dev/mem>, 917504, SEEK_SET)    = 917504
read(3</dev/mem>, 
"\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"..., 
65536) = 65536
lseek(3</dev/mem>, 524288, SEEK_SET)    = 524288
read(3</dev/mem>,  <unfinished ...>)    = ?
+++ killed by SIGSEGV +++

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
