Message-ID: <3A96C430.C028E954@amis.com>
Date: Fri, 23 Feb 2001 13:12:32 -0700
From: Eric Whiting <ewhiting@amis.com>
MIME-Version: 1.0
Subject: Re: large mem, heavy paging issues (256M VmStk on Athlon)
References: <Pine.LNX.4.31.0102211937460.21127-100000@localhost.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rick,

Thanks for the info -- but I'm not sure I understand what the fix is
to be. Does my lisp engine need to be recompiled with a newer glibc?
Do I need to change something else?

I think the strace showed the process is using mainly malloc (mmap)
for memory allocation. I do see some brk() calls at the first. (these
appear to be returning a 2G number not a 1G number like you suggested)

access_test/ruby> egrep -i 'brk' strace.log
brk(0)                                  = 0x8051a48
brk(0)                                  = 0x8051a48
brk(0x8051e60)                          = 0x8051e60
brk(0x8052000)                          = 0x8052000
brk(0x8054000)                          = 0x8054000
brk(0x8055000)                          = 0x8055000
brk(0x8056000)                          = 0x8056000
brk(0x8059000)                          = 0x8059000
brk(0x805a000)                          = 0x805a000

And later: (mainly mmap calls) (I assume the mmap calls of interest
are the ones that contain MAP_ANONYMOUS which come from a malloc call)

old_mmap(0x4011f000, 11804, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x4011f000
old_mmap(0x40192000, 104095, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x40192000
old_mmap(0xbf008000, 991232, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xbf008000
old_mmap(0x51444000, 24576, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x51444000
old_mmap(0x51ed4000, 77348864, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x51ed4000
old_mmap(0x568a0000, 10092544, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x568a0000
old_mmap(0x57246000, 10149888, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x57246000

HERE is a successful malloc of 1.7G

old_mmap(0x57bf4000, 1731616768, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x57bf4000
old_mmap(0x402dc000, 7260, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x402dc000
old_mmap(0x40347000, 648, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x40347000
old_mmap(0x40417000, 124, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x40417000
old_mmap(0x40438000, 6864, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x40438000
old_mmap(0x56898000, 10149888, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x56898000
old_mmap(0x57246000, 10149888, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x57246000
old_mmap(0x57bf4000, 7340032, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x57bf4000
old_mmap(0x582f4000, 5505024, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x582f4000
old_mmap(0x58834000, 5767168, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x58834000
old_mmap(0x58db4000, 10747904, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x58db4000

<SNIP> A ton of these follow as the program runs.

Is there something I can change on the linux box? Or is this something
the application has to change?

Thanks,
eric




Rik van Riel wrote:
> 
> On Tue, 20 Feb 2001, Eric Whiting wrote:
> 
> > I'm working with an application in Lisp. It runs on a Solaris
> > box and uses about 1.3G of RAM and 9M stack before it exits
> > after 2hours of running.
> >
> > I have been trying to run the same application on linux. It's
> > memory usage hits about 1.2G and then it loses it's brain.
> 
> > This problem is either
> > 1. an application problem
> > 2. a linux vm/mm problem
> > 3. a wacky HW problem.
> > 4. ???
> 
> It's a glibc problem in combination with an oddity in the Linux
> VM layer.
> 
> At 1GB, Linux starts with the mmap() areas, so brk() will only
> work up to 1GB. When going over that, glibc's malloc() should
> use mmap() instead to get more memory...
> 
> > What other things can I do?
> 
> > Last valid maps output (for PIII)
> > -------------------------
> > 08048000-0804b000 r-xp 00000000 00:0c 29261935   /home/pendsm1/access/bin11/linux/access
> > 0804b000-0804d000 rw-p 00002000 00:0c 29261935   /home/pendsm1/access/bin11/linux/access
> > 0804d000-0805a000 rwxp 00000000 00:00 0
> > 40000000-40013000 r-xp 00000000 03:03 275293     /lib/ld-2.1.3.so
>   ^^^^^^^^
> 
> Mapped at 1GB, so brk() will hit this point...
> 
> regards,
> 
> Rik
> --
> Virtual memory is like a game you can't win;
> However, without VM there's truly nothing to lose...
> 
>                 http://www.surriel.com/
> http://www.conectiva.com/       http://distro.conectiva.com.br/

-- 
__________________________________________________________________
Eric T. Whiting					AMI Semiconductors   
(208) 234-6717					2300 Buckskin Road
(208) 234-6659 (fax)				Pocatello,ID 83201
ewhiting@poci.amis.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
