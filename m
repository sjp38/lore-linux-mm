Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA4A41
          for <linux-mm@kvack.org>; Tue, 1 May 2001 08:06:22 -0500
Received: from link.com ([130.210.5.51]) by issun5.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA26B2
          for <linux-mm@kvack.org>; Tue, 1 May 2001 08:33:36 -0500
Message-ID: <3AEEBB22.9030801@link.com>
Date: Tue, 01 May 2001 09:33:22 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: About reading /proc/*/mem
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok, so as a rehash, the ptrace & open(),lseek() on /proc/*/mem should 
both work about the same.  After a lot of struggling, I've gotten the 
ptrace to work right & spit out the data I want/need.  However there is 
one small problem, SIGSTOP.

ptrace() appears to set up the child process to do a SIGSTOP whenever 
any interrupt is received.  Which is kind of a bad thing for what I'm 
looking to do.  I guess I'm trying to write a non-intrusive debugger 
that can be used to view static variables stored in the heap of an 
application.

On other OS's, this can be done just by popping open /proc/*/mem, and 
reading the data as needed, allowing the child process to continue 
processing away as if nothing is going on.  I'm looking to do the same 
sort of task under Linux. 

Unfortunately, ptrace() probobally isn't going to allow me to do that.  
So my next question is does opening /proc/*/mem force the child process 
to stop on every interrupt (just like ptrace?)

Second, I would imagine opening /dev/mem (or /proc/kcore) would get me 
into the physical memory of the system itself.  How would I know what 
the starting physical memory addresses of a processes data is to start at:

What I do see is under /proc/*/maps is the entries:
08048000-08049000 r-xp 00000000 03:01 718368     /devel/mem_probe/child
08049000-0804a000 rw-p 00000000 03:01 718368     /devel/mem_probe/child
40000000-40015000 r-xp 00000000 03:01 310089     /lib/ld-2.2.so
40015000-40016000 rw-p 00014000 03:01 310089     /lib/ld-2.2.so
40016000-40017000 rwxp 00000000 00:00 0
40017000-40018000 rw-p 00000000 00:00 0
40027000-4013f000 r-xp 00000000 03:01 310096     /lib/libc-2.2.so
4013f000-40144000 rw-p 00117000 03:01 310096     /lib/libc-2.2.so
40144000-40148000 rw-p 00000000 00:00 0
bfffe000-c0000000 rwxp fffff000 00:00 0


I would assume that this tells me that memory addresses 
0x08049000-0x804a000 are mapped to the physical address of 0x718368.  
However Going to this address, and then doing an lseek(SEEK_CUR)out to 
my expected variable offset doesn't get me the result I'm expecting.  Is 
the 0x718368 the right location to be looking at, or is there some 
translation that needs to get done (* by page size, translate into 
hex/from hex, etc.) I can't find any documentation indicating what each 
column represents so it's just a stab on my part.

Thanks for the good information so far.

--Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
