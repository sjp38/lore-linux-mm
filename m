Subject: Oops in kernel 2.4.19-pre10-ac2-preempt
Message-ID: <OF4C1E1763.D4BE6432-ON86256BDE.0055BDB6@hou.us.ray.com>
From: Mark_H_Johnson@Raytheon.com
Date: Thu, 20 Jun 2002 11:01:22 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kpreempt-tech@lists.sourceforge.net, linux-mm@kvack.org
Cc: Robert_Horton@Raytheon.com, James_P_Cassidy@Raytheon.com, Stanley_R_Allen@Raytheon.com
List-ID: <linux-mm.kvack.org>

I'd like to put out a warning on using the
preempt-kernel-2.4.19-pre10-ac2.patch. The best I can determine, the
pre10-ac2 kernel includes the new rmap memory management. However, there
was a message on the linux-mm mailing list from Bill Irwin stating...

>On Wed, Jun 19, 2002 at 04:18:00AM -0700, Craig Kulesa wrote:
>> Where:  http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/
>> This patch implements Rik van Riel's patches for a reverse mapping VM
>> atop the 2.5.23 kernel infrastructure.  The principal sticky bits in
>
>There is a small bit of trouble here: pte_chain_lock() needs to
>preempt_disable() and pte_chain_unlock() needs to preempt_enable(),
>as they are meant to protect critical sections.

This was in reference to a port of rmap to the 2.5 kernel series, but I
think this also applies to rmap on 2.4 as well. I highly recommend avoiding
applying the kernel preemption patches to this kernel (2.4.19-pre10-ac2)
until the preemption cleanup is completed on rmap. Since I have two
different Oopses, I can't tell if the fix posted on the linux-mm is
complete or not.

In testing yesterday, we got a pair of oops as follows. The first one is...

kernel BUG at rmap.c:267!
invalid operand: 0000
CPU: 1
EIP: 0010 [<c01419837>] not tainted
EFLAGS: 00010202
eax: 01014099  ebx: c16c0e70  ecx: c16c0e70  edx: 00000010
esi: c16c0e70  edi: d1720000  ebp: 00000000  esp: d1721f44
ds: 0018  es: 0018 ss: 0018
Process kswapd (pid: 7, stack page = d1721000)
Stack : c16c0e70  c16c0e8c  d1720000  d1720000
        00000000  c0288824  c013a054  0000107d
        000001d0  c0288824  00000000  c16coe86
        00000000  c0288854  d1720000  0000107d
        ...
Call trace [<c013a054>] [<c013a56e>] [<c013af52>] [<co13b277>]
           [<c01072db>]
Code: 0f 0b 0b 01 40 0a 25 c0 8b 46 18 a8 01 75 08 0f 0b 0d 01 40
<3> kswapd[7] exited with preempt_count 1

The second one is...

Unable to handle kernel NULL pointer deference at virtual address 00000078
printing EIP:
c0141a4b
*pde=00000000
Oops: 0000
CPU: 1
EIP: 0010 [<c0141a4b>] not tainted
EFLAGS: 00010206
eax: 00000000  ebx: c1000030  ecx: d1d5dbe0  edx: 0001bd33
esi: c13f234c  edi: d1720000  ebp: d1720000  esp: d1721f74
ds: 0018  es: 0018  ss: 0018
Process kswapd (pid: 7, stack page = d1721000)
Stack: c13f2330  c013a9f6  00000000  000037f0
       c0288824  0008e000  00000000  00000000
       c028884c  d1720000  00000000  00000000
       00000000  00000000  00000000  00000000
       d1720000  00000000  00000000  000037f0
       000001e9  c013b43d  c0288b24  00000006
Call trace [<c013a9f6>] [<c013b43d>] [<c01072db>]
Code: 8b 50 78 85 d2 74 05 39 50 64 77 09 31 c0 eb 10 90 8d 74 26
<3> kswapd[7] exited with preempt_count 1


I also had problems with unmounting disks at shutdown - occasionally the
system shutdown script would get stuck at that step and require a hard
reboot as well. It may be related to rmap race conditions if cache flushes
from memory to disk were getting screwed up.

For now, we have gone back to a 2.4.16 based kernel for further work w/
kernel preemption. Let me know if you need additional information to help
diagnose the problems. I'm going on vacation for a few weeks "tonight", but
I can check on messages & arrange for someone to forward additional data if
needed.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
