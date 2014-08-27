Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id DF1B36B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 21:04:44 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so23360511pdb.5
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 18:04:44 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id xg7si6708359pbc.90.2014.08.26.18.04.42
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 18:04:43 -0700 (PDT)
Message-ID: <53FD2E9E.6050809@gentoo.org>
Date: Tue, 26 Aug 2014 21:04:30 -0400
From: Joshua Kinard <kumba@gentoo.org>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/2] mm/highmem: make kmap cache coloring aware
References: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com> <20140825171600.GH25892@linux-mips.org> <53FBCD09.1050003@gentoo.org> <53FBD676.8080307@gmail.com> <53FBF3C3.90509@gentoo.org> <53FCC7CB.8010701@gmail.com>
In-Reply-To: <53FCC7CB.8010701@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Daney <ddaney.cavm@gmail.com>
Cc: Ralf Baechle <ralf@linux-mips.org>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>

On 08/26/2014 13:45, David Daney wrote:
> On 08/25/2014 07:41 PM, Joshua Kinard wrote:
>> On 08/25/2014 20:36, David Daney wrote:
>>> On 08/25/2014 04:55 PM, Joshua Kinard wrote:
>>>> On 08/25/2014 13:16, Ralf Baechle wrote:
>>>>> On Sat, Aug 02, 2014 at 05:11:37AM +0400, Max Filippov wrote:
>>>>>
>>>>>> this series adds mapping color control to the generic kmap code, allowing
>>>>>> architectures with aliasing VIPT cache to use high memory. There's also
>>>>>> use example of this new interface by xtensa.
>>>>>
>>>>> I haven't actually ported this to MIPS but it certainly appears to be
>>>>> the right framework to get highmem aliases handled on MIPS, too.
>>>>>
>>>>> Though I still consider increasing PAGE_SIZE to 16k the preferable
>>>>> solution because it will entirly do away with cache aliases.
>>>>
>>>> Won't setting PAGE_SIZE to 16k break some existing userlands (o32)?  I
>>>> use a
>>>> 4k PAGE_SIZE because the last few times I've tried 16k or 64k, init won't
>>>> load (SIGSEGVs or such, which panicks the kernel).
>>>>
>>>
>>> It isn't supposed to break things.  Using "stock" toolchains should result
>>> in executables that will run with any page size.
>>>
>>> In the past, some geniuses came up with some linker (ld) patches that, in
>>> order to save a few KB of RAM, produced executables that ran only on 4K
>>> pages.
>>>
>>> There were some equally astute Debian emacs package maintainers that were
>>> carrying emacs patches into Debian that would not work on non-4K page size
>>> systems.
>>>
>>> That said, I think such thinking should be punished.  The punishment should
>>> be to not have their software run when we select non-4K page sizes.  The
>>> vast majority of prepackaged software runs just fine with a larger page
>>> size.
>>
>> Well, it does appear to mostly work now w/ 16k PAGE_SIZE.  The Octane booted
>> into userland with just a couple of "illegal instruction" errors from 'rm'
>> and 'mdadm'.  I wonder if that's tied to a hardcoded PAGE_SIZE somewhere.
>> Have to dig around and find something that reproduces the problem on demand.
>>
> 
> What does the output of "readelf -lW" look like for the failing programs? 
> If the "Offset" and "VirtAddr" constraints for the LOAD Program Headers are
> not possible to achieve with the selected PAGE_SIZE, you will see problems. 
> A "correct" toolchain will generate binaries that work with any PAGE_SIZE up
> to 64K.

Well, I recently rebuilt shash, so that might've changed things.  But,
running readelf -lW on shash core dumped readelf itself on the first
invocation (with a SIGBUS instead of SIGILL).  So I instead ran readelf -lW
on itself, which hasn't been recently rebuilt:

# readelf -lW /usr/bin/shash
Bus error (core dumped)
# readelf -lW /usr/bin/readelf

Elf file type is EXEC (Executable file)
Entry point 0x402590
There are 11 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x00400034 0x00400034 0x00160 0x00160 R E 0x4
  INTERP         0x000194 0x00400194 0x00400194 0x0000d 0x0000d R   0x1
      [Requesting program interpreter: /lib/ld.so.1]
  REGINFO        0x0001c4 0x004001c4 0x004001c4 0x00018 0x00018 R   0x4
  LOAD           0x000000 0x00400000 0x00400000 0x72338 0x72338 R E 0x10000
  LOAD           0x0728c8 0x004828c8 0x004828c8 0x01834 0x03d88 RW  0x10000
  DYNAMIC        0x0001dc 0x004001dc 0x004001dc 0x000e0 0x000e0 RWE 0x4
  NOTE           0x0001a4 0x004001a4 0x004001a4 0x00020 0x00020 R   0x4
  GNU_EH_FRAME   0x0722c0 0x004722c0 0x004722c0 0x00024 0x00024 R   0x4
  GNU_RELRO      0x0728c8 0x004828c8 0x004828c8 0x00738 0x00738 R   0x1
  PAX_FLAGS      0x000000 0x00000000 0x00000000 0x00000 0x00000     0x4
  NULL           0x000000 0x00000000 0x00000000 0x00000 0x00000     0x4

 Section to Segment mapping:
  Segment Sections...
   00
   01     .interp
   02     .reginfo
   03     .interp .note.ABI-tag .reginfo .dynamic .hash .dynsym .dynstr
.gnu.version .gnu.version_r .init .text .MIPS.stubs .fini .rodata
.eh_frame_hdr .eh_frame
   04     .ctors .dtors .jcr .data.rel.ro .data .rld_map .got .sdata .sbss .bss
   05     .dynamic
   06     .note.ABI-tag
   07     .eh_frame_hdr
   08     .ctors .dtors .jcr .data.rel.ro
   09
   10

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
