Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 534466B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 00:39:00 -0500 (EST)
From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Date: Thu, 17 Dec 2009 11:08:31 +0530
Subject: CPU consumption is going as high as 95% on ARM Cortex A8
Message-ID: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am seeing some strange behavior while accessing buffers through User Spac=
e (mapped using mmap call)

Background :-=20
------------
Platform - TI AM3517
CPU - ARM Cortex A8

root@am3517-evm:~#
root@am3517-evm:~# cat /proc/cpuinfo
Processor       : ARMv7 Processor rev 7 (v7l)
BogoMIPS        : 499.92
Features        : swp half thumb fastmult vfp edsp neon vfpv3
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x1
CPU part        : 0xc08
CPU revision    : 7
Hardware        : OMAP3517/AM3517 EVM
Revision        : 0020
Serial          : 0000000000000000
root@omap3517-evm:~#


Issue/Usage :-=20
-------------
The V4l2-Capture driver captures the data from video decoder into buffer an=
d the application does some processing on this buffer. The mmap implementat=
ion can be found at drivers/media/video/videobuf-dma-contig.c, function__vi=
deobuf_mmap_mapper().

Observation -=20
The CPU consumption goes as high as 95% on read buffer operation, please no=
te that write operation on these buffers also gives 60-70% CPU consumption.=
 (Using memcpy/memset API's for read and write operation).

Some more inputs :-=20
------------------
- If I specify PAGE_READONLY or PAGE_SHARED (actual flag is L_PTE_USER) whi=
le mapping the buffer to UserSpace in mmap system call, the CPU consumption=
 goes down to expected value (20-27%).=20
Then I reached till the function cpu_v7_set_pte_ext, where we are configuri=
ng level 2 translation table entries, which makes use of these flags.

- Below is the value of r0, r1 and r2 register (ptep, pteval, ext) in both =
the cases -


Without PAGE_READONLY/PAGE_SHARED

ptep - cfb5de10, pte - 8d200383, ext - 800
ptep - cfb5de14, pte - 8d201383, ext - 800

Important bits are [0-9] - 0x383

With PAGE_READONLY/PAGE_SHARED set

ptep - cfb30e10, pte - 8d10038f, ext - 800
ptep - cfb30e14, pte - 8d10138f, ext - 800

Important bits are [0-9] - 0x38F

The lines inside function "cpu_v7_set_pte_ext", is using the flag as shown =
below -

   tst     r1, #L_PTE_USER
   orrne   r3, r3, #PTE_EXT_AP1
   tstne   r3, #PTE_EXT_APX
   bicne   r3, r3, #PTE_EXT_APX | PTE_EXT_AP0

Without PAGE_READONLY/PAGE_SHARED		With flags set

Access perm =3D reserved				Access Perm =3D Read Only

- I tried the same thing with another platform (ARM9) and it works fine the=
re.

Can somebody help me to understand the flag PAGE_SHARED/PAGE_READONLY and a=
ccess permissions? Am I debugging this into right path? Does anybody have s=
een/observed similar issue before?


Thanks in advance.

Thanks,
Vaibhav Hiremath

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
