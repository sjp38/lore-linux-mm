Received: from scs.ch (nutshell.scs.ch [172.18.1.10])
	by mail.scs.ch (8.11.6/8.11.6) with ESMTP id g0I9Ds124274
	for <linux-mm@kvack.org>; Fri, 18 Jan 2002 10:13:54 +0100
Message-ID: <3C47E752.FAF5AA48@scs.ch>
Date: Fri, 18 Jan 2002 10:13:54 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: timing of access to I/O memory
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I am writing a driver for a PCI device. In order to start a certain functionality on the device,
I need to successively write two (different) values (value1 and value2) into a register. In
addition the register must hold value1 for (at least) x microseconds, before value2 is written
into the register.
The PCI device maps the register into an I/O memory region, thus the register is accessible through I/O memory, which the driver maps by an ioremap_nocache() call into the
kernel's virtual address space (i.e. the
driver can write to the register by writing to an address reg1).

I first thought the following lines of code should do the job:
  ....
  writeb(value1, reg1);
  /* a memory barrier to ensure the write of value1 completes befor a subsequent write is
      executed */
  wmb();
  /* a delay to ensure that value1 is in the register for at least x microseconds, before being
      overwritten by value2 */
  udelay(x);
  writeb(value2, reg1);
  ....
However I am not quite sure, if this works correctly, for the following reason:
Although the wmb() guarantees that write of value1 will complete, before value2 is written
(see the description of memory barriers in Rubini&Corbet's Device Driver Book, p. 228),
there is no guarantee that the write of value1 will complete, before execution of udelay() starts, nor that the execution of udelay() completes before value2 is written
into the register.
Thus there is no guarantee that value1 will have been in the register for at least x microseconds,
before it is overwritten by value2.
I.e. I fear the following scenario:
--> (time flows in this direction)
write of value1          [start]------------[completion]
execution of udelay()              [start]-------------[completion]
write of value2                                  [start]----------[completion]

Now my questions:
- Do the above lines of code guarantee a correct timing (and if so, why - i.e. where does the guarantee come from, that udelay() is executed after completion of the first
writeb(), and before
the completion of the second writeb())?
- If correct timing is not guaranteed by the above lines of code, how can correct timing be achieved?
- How is the udelay() function implemented (in particular does it do any read/write memory access)?

Thank you in advance,
regards
Martin

P.S. Please put me cc on your reply, since I am not in the list.

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
IRC Channel:   irc.openprojects.net / #kernelnewbies
Web Page:      http://www.kernelnewbies.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
