Received: from hpfcla.fc.hp.com (hpfcla.fc.hp.com [15.254.48.2])
	by atlrel1.hp.com (Postfix) with ESMTP id 0056F5F0
	for <linux-mm@kvack.org>; Thu, 17 May 2001 13:14:05 -0400 (EDT)
Received: from gplmail.fc.hp.com (nsmail@wslmail.fc.hp.com [15.1.92.20])
	by hpfcla.fc.hp.com (8.9.3 (PHNE_22672)/8.9.3 SMKit7.01) with ESMTP id LAA03028
	for <linux-mm@kvack.org>; Thu, 17 May 2001 11:14:04 -0600 (MDT)
Received: from fc.hp.com (dome.fc.hp.com [15.1.89.118])
          by gplmail.fc.hp.com (Netscape Messaging Server 3.6)  with ESMTP
          id AAA1CC8 for <linux-mm@kvack.org>;
          Thu, 17 May 2001 11:14:00 -0600
Message-ID: <3B04069C.49787EC2@fc.hp.com>
Date: Thu, 17 May 2001 11:13:00 -0600
From: David Pinedo <dp@fc.hp.com>
MIME-Version: 1.0
Subject: Running out of vmalloc space
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.  My name is David Pinedo and I subscribed to this list a few days
ago.  I work for Hewlett-Packard, and am in the process of porting the
drivers for the FX10 graphics boards from Red Hat 6.2 to Red Hat 7.1.
Our customers are begging us to support the FX10 on RH7.1, primarily
because of the large memory capabilities in the 2.4.2 kernel.
 
I only have minimal knowledge of the Linux kernel, enough to be able to
create the kernel module driver for the FX10.  My apologies for jumping
into this email list and the inevitable newbie mistakes I may make.  I
have a strong business need to get these graphics boards working
correctly in the 2.4.2 kernel, and I think this email list may be the
only place I can get some help. If I should be using some other forum
for my questions, I would appreciate if someone would point me to it.
 
Porting the driver to 2.4.2 was not terribly difficult.  Most of the
changes were in code that translates to and from physical addresses and
virtual addresses.  There were a few changes I had to make due to
difference in the gcc compiler on RH7.1 vs RH6.2.
 
The FX10 has a very large frame buffer and control space (the control
space is where the registers to control the device reside).  The frame
buffer is 16Mbytes and the control space is 32Mbytes.  The address space
for the frame buffer and control space is allocated from the kernel vm
address space, using get_vm_area() in mm/vmalloc.c.
 
On Linux, HP supports up to two FX10 boards in the system.  In order to
use two FX10 boards, the kernel driver needs to map the frame buffer and
control space for both of the boards.  That's a lot of address space,
2*(16M+32M)=96M to be exact.  Using this much virtual address space on a
stock RH7.1 smp kernel on a system with 0.5G of memory didn't seem to
be a problem.  However, a colleague reported a problem to me on his
system with 1.0G of memory -- the X server was exiting with an error
message indicating that it couldn't map both devices.
 
On investigating the problem, I found that a call to get_vm_area was
failing because the kernel was running out of vmalloc space.  It seems
that the vmalloc space is smaller when more memory was installed on the
system:
 
                        .5G RAM           1.0G RAM
                       ----------        ---------
        VMALLOC_END    0xfdffe000        0xfdffe000
        VMALLOC_START  0xe0800000        0xf8800000
                       ----------        ---------
        space avail    0x1d7fe000(471M)  0x057FE000(87M)
 
 
I found that if I reconfigure the kernel with Maximum Virtual Memory set
to 2G (sets CONFIG_2GB), the vmalloc space is larger and the problem
goes away.  I couldn't quite figure out what the implications of
changing Maximum Virtual Memory really are.  The Help button when using
"make xconfig" says there is no help available.  Could someone enlighten
me?  Will this fix also work when I add more memory to the system?
 
Another method of fixing this problem that seems to work is to change
the constant VMALLOC_RESERVE in arch/i386/kernel/setup.c.  I changed the
line that defines it from:
 
   #define VMALLOC_RESERVE (unsigned long)(128 << 20)
 
to:
 
   #define VMALLOC_RESERVE (unsigned long)(256 << 20)
 
What are the implications of making such a change?  Will it work when
there is less or more memory in the system?  Should this be a
configurable kernel parameter?
 
Thanks for any information anyone can provide.
 
David Pinedo
Hewlett-Packard Company
Fort Collins, Colorado
dp@fc.hp.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
