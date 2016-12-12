Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E56CB6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 14:22:48 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 136so49695867iou.7
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:22:48 -0800 (PST)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id 78si20387394ith.107.2016.12.12.11.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 11:22:47 -0800 (PST)
Date: Mon, 12 Dec 2016 12:22:23 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v7] powerpc: Do not make the entire heap executable
Message-ID: <20161212192223.GA30784@obsidianresearch.com>
References: <20161109170644.15821-1-dvlasenk@redhat.com>
 <CAGXu5jLKFAAwgR=AoSdvhK-DtNrMk3SEOpoCHhMqrFWFiuBL5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLKFAAwgR=AoSdvhK-DtNrMk3SEOpoCHhMqrFWFiuBL5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 02:15:27PM -0800, Kees Cook wrote:
> Can you resend this patch with /proc/$pid/maps output showing the
> before/after effects of this change also included here? Showing that
> reduction in executable mapping should illustrate the benefit of
> avoiding having the execute bit set on the brk area (which is a clear
> security weakness, having writable/executable code in the process's
> memory segment, especially when it was _not_ requested by the ELF
> headers).

Denys, I'll leave it to you to re-sumbit again..

I suggest this reworded commit message:

powerpc: Do not make the entire heap executable

gcc has a configure option to generate ELF files that are W^X:
--enable-secureplt

However the PPC32 kernel is hardwired to add PROT_EXEC to the heap and
BSS segments, totally defeating this security protection.

This is done because the common ELF loader does not properly respect
the load header permissions when mapping a region that is not file
backed.

For example, non-secure PPC creates these segments:

  [21] .data             PROGBITS        10061254 051254 001868 00  WA  0   0  4
  [22] .got              PROGBITS        10062abc 052abc 000014 04 WAX  0   0  4
  [23] .sdata            PROGBITS        10062ad0 052ad0 000058 00  WA  0   0  4
  [24] .sbss             NOBITS          10062b28 052b28 000040 00  WA  0   0  8
  [25] .plt              NOBITS          10062b68 052b28 000d38 00 WAX  0   0  4
  [26] .bss              NOBITS          100638a0 052b28 006424 00  WA  0   0 16

Which results in an ELF load header covering those segments:

  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x051160 0x10061160 0x10061160 0x019c8 0x08b64 RWE 0x10000

If we just remove the PROT_EXEC PPC32 hack then the kernel will do
something like:

10061000-10063000 rwxp 00051000 07:00 3208784    /app/bin/busybox.dynamic
10063000-1006a000 rw-p 00000000 00:00 0
104a6000-104c7000 rw-p 00000000 00:00 0          [heap]

The 2nd mapping is the anonymous 0 filled pages requested by FileSiz <
MemSiz, but it is not executable. This causes instant crashes of
normal PPC32 ELFs as their PLT and GOTs must be executable.

This patches fixes the above bug in the ELF loader and removes the
forced PROT_EXEC from PPC32.

The improvement is seen in /proc/PID/maps. After the patch a normal
ELF looks like:

10061000-10063000 rwxp 00051000 07:00 3208784    /app/bin/busybox.dynamic
10063000-1006a000 rwxp 00000000 00:00 0
104a6000-104c7000 rw-p 00000000 00:00 0          [heap]

while a secure-PLT ELF looks like:

10050000-10052000 rw-p 00050000 07:00 3208780    /app/bin/busybox.dynamic
10052000-10059000 rw-p 00000000 00:00 0 
10740000-10761000 rw-p 00000000 00:00 0          [heap]

Critically, with this patch applied all of the maps within a
secure-plt ELF are W^X.

While before this patch we see undeseriable W&X.

normal ELF:

10061000-10063000 rwxp 00051000 07:00 3208784    /app/bin/busybox.dynamic
10063000-1006a000 rwxp 00000000 00:00 0
104a6000-104c7000 rwxp 00000000 00:00 0          [heap]

secure-plt ELF:

10050000-10052000 rw-p 00050000 07:00 3208780    /app/bin/busybox.dynamic
10052000-10059000 rwxp 00000000 00:00 0 
104c7000-104e8000 rwxp 00000000 00:00 0          [heap]

-----------------

Andrew/Kees/Denys:

Here are full dumps from my PPC405 system.

Before patch (secure-plt):

00100000-00103000 r-xp 00000000 00:00 0          [vdso]
0fe25000-0fe30000 r-xp 00000000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe30000-0fe44000 ---p 0000b000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe44000-0fe45000 r--p 0000f000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe45000-0fe46000 rw-p 00010000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe46000-0fe4c000 rw-p 00000000 00:00 0 
0fe5c000-0ffd2000 r-xp 00000000 07:00 4094672    /app/lib/libc-2.23.so
0ffd2000-0ffe8000 ---p 00176000 07:00 4094672    /app/lib/libc-2.23.so
0ffe8000-0ffec000 r--p 0017c000 07:00 4094672    /app/lib/libc-2.23.so
0ffec000-0ffed000 rw-p 00180000 07:00 4094672    /app/lib/libc-2.23.so
0ffed000-0fff0000 rw-p 00000000 00:00 0 
10000000-1004e000 r-xp 00000000 07:00 3208780    /app/bin/busybox.dynamic
10050000-10052000 rw-p 00050000 07:00 3208780    /app/bin/busybox.dynamic
10052000-10059000 rwxp 00000000 00:00 0 
104c7000-104e8000 rwxp 00000000 00:00 0          [heap]
b7ab1000-b7ad2000 r-xp 00000000 07:00 4009940    /app/lib/ld-2.23.so
b7aee000-b7af0000 rw-p 00000000 00:00 0 
b7af0000-b7af1000 r--p 0002f000 07:00 4009940    /app/lib/ld-2.23.so
b7af1000-b7af2000 rw-p 00030000 07:00 4009940    /app/lib/ld-2.23.so
bfee1000-bff02000 rw-p 00000000 00:00 0          [stack]

After Patch (secure-plt):

00100000-00103000 r-xp 00000000 00:00 0          [vdso]
0fe25000-0fe30000 r-xp 00000000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe30000-0fe44000 ---p 0000b000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe44000-0fe45000 r--p 0000f000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe45000-0fe46000 rw-p 00010000 07:00 6557504    /app/lib/libnss_files-2.23.so
0fe46000-0fe4c000 rw-p 00000000 00:00 0 
0fe5c000-0ffd2000 r-xp 00000000 07:00 4094672    /app/lib/libc-2.23.so
0ffd2000-0ffe8000 ---p 00176000 07:00 4094672    /app/lib/libc-2.23.so
0ffe8000-0ffec000 r--p 0017c000 07:00 4094672    /app/lib/libc-2.23.so
0ffec000-0ffed000 rw-p 00180000 07:00 4094672    /app/lib/libc-2.23.so
0ffed000-0fff0000 rw-p 00000000 00:00 0 
10000000-1004e000 r-xp 00000000 07:00 3208780    /app/bin/busybox.dynamic
10050000-10052000 rw-p 00050000 07:00 3208780    /app/bin/busybox.dynamic
10052000-10059000 rw-p 00000000 00:00 0 
10740000-10761000 rw-p 00000000 00:00 0          [heap]
b7bff000-b7c20000 r-xp 00000000 07:00 4009940    /app/lib/ld-2.23.so
b7c3c000-b7c3e000 rw-p 00000000 00:00 0 
b7c3e000-b7c3f000 r--p 0002f000 07:00 4009940    /app/lib/ld-2.23.so
b7c3f000-b7c40000 rw-p 00030000 07:00 4009940    /app/lib/ld-2.23.so
bf891000-bf8b2000 rw-p 00000000 00:00 0          [stack]

Program Headers (secure-plt):
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x10000034 0x10000034 0x00100 0x00100 R E 0x4
  INTERP         0x000134 0x10000134 0x10000134 0x0000d 0x0000d R   0x1
      [Requesting program interpreter: /lib/ld.so.1]
  LOAD           0x000000 0x10000000 0x10000000 0x4da28 0x4da28 R E 0x10000
  LOAD           0x050000 0x10050000 0x10050000 0x01e44 0x08288 RW  0x10000
  DYNAMIC        0x050020 0x10050020 0x10050020 0x000d0 0x000d0 RW  0x4
  NOTE           0x000144 0x10000144 0x10000144 0x00020 0x00020 R   0x4
  GNU_EH_FRAME   0x04d8f0 0x1004d8f0 0x1004d8f0 0x00034 0x00034 R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x10

Before patch (normal):

00100000-00103000 r-xp 00000000 00:00 0          [vdso]
0fe25000-0fe30000 r-xp 00000000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe30000-0fe44000 ---p 0000b000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe44000-0fe45000 r--p 0000f000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe45000-0fe46000 rw-p 00010000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe46000-0fe4c000 rw-p 00000000 00:00 0 
0fe5c000-0ffd2000 r-xp 00000000 07:00 4101308    /app/lib/libc-2.23.so
0ffd2000-0ffe8000 ---p 00176000 07:00 4101308    /app/lib/libc-2.23.so
0ffe8000-0ffec000 r--p 0017c000 07:00 4101308    /app/lib/libc-2.23.so
0ffec000-0ffed000 rw-p 00180000 07:00 4101308    /app/lib/libc-2.23.so
0ffed000-0fff0000 rw-p 00000000 00:00 0 
10000000-10052000 r-xp 00000000 07:00 3208784    /app/bin/busybox.dynamic
10061000-10063000 rwxp 00051000 07:00 3208784    /app/bin/busybox.dynamic
10063000-1006a000 rwxp 00000000 00:00 0 
101f2000-10213000 rwxp 00000000 00:00 0          [heap]
b7e9a000-b7ebb000 r-xp 00000000 07:00 4016576    /app/lib/ld-2.23.so
b7ed7000-b7ed9000 rw-p 00000000 00:00 0 
b7ed9000-b7eda000 r--p 0002f000 07:00 4016576    /app/lib/ld-2.23.so
b7eda000-b7edb000 rw-p 00030000 07:00 4016576    /app/lib/ld-2.23.so
bf8d4000-bf8f5000 rw-p 00000000 00:00 0          [stack]

After patch (normal):

00100000-00103000 r-xp 00000000 00:00 0          [vdso]
0fe25000-0fe30000 r-xp 00000000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe30000-0fe44000 ---p 0000b000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe44000-0fe45000 r--p 0000f000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe45000-0fe46000 rw-p 00010000 07:00 6564140    /app/lib/libnss_files-2.23.so
0fe46000-0fe4c000 rw-p 00000000 00:00 0 
0fe5c000-0ffd2000 r-xp 00000000 07:00 4101308    /app/lib/libc-2.23.so
0ffd2000-0ffe8000 ---p 00176000 07:00 4101308    /app/lib/libc-2.23.so
0ffe8000-0ffec000 r--p 0017c000 07:00 4101308    /app/lib/libc-2.23.so
0ffec000-0ffed000 rw-p 00180000 07:00 4101308    /app/lib/libc-2.23.so
0ffed000-0fff0000 rw-p 00000000 00:00 0 
10000000-10052000 r-xp 00000000 07:00 3208784    /app/bin/busybox.dynamic
10061000-10063000 rwxp 00051000 07:00 3208784    /app/bin/busybox.dynamic
10063000-1006a000 rwxp 00000000 00:00 0 
104a6000-104c7000 rw-p 00000000 00:00 0          [heap]
b7aab000-b7acc000 r-xp 00000000 07:00 4016576    /app/lib/ld-2.23.so
b7ae8000-b7aea000 rw-p 00000000 00:00 0 
b7aea000-b7aeb000 r--p 0002f000 07:00 4016576    /app/lib/ld-2.23.so
b7aeb000-b7aec000 rw-p 00030000 07:00 4016576    /app/lib/ld-2.23.so
bf9e0000-bfa01000 rw-p 00000000 00:00 0          [stack]

Program Headers (normal):
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x10000034 0x10000034 0x00100 0x00100 R E 0x4
  INTERP         0x000134 0x10000134 0x10000134 0x0000d 0x0000d R   0x1
      [Requesting program interpreter: /lib/ld.so.1]
  LOAD           0x000000 0x10000000 0x10000000 0x51160 0x51160 R E 0x10000
  LOAD           0x051160 0x10061160 0x10061160 0x019c8 0x08b64 RWE 0x10000
  DYNAMIC        0x05118c 0x1006118c 0x1006118c 0x000c8 0x000c8 RW  0x4
  NOTE           0x000144 0x10000144 0x10000144 0x00020 0x00020 R   0x4
  GNU_EH_FRAME   0x050d88 0x10050d88 0x10050d88 0x000ac 0x000ac R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x4

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
