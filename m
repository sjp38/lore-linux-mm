Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEC16B0271
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 06:48:57 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id v193so9088423qka.15
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 03:48:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 103si48373qkr.136.2018.01.09.03.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 03:48:55 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w09BmnNY121953
	for <linux-mm@kvack.org>; Tue, 9 Jan 2018 06:48:54 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fct022qvf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jan 2018 06:48:53 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 9 Jan 2018 11:48:51 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org>
 <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com>
 <20180105084631.GG2801@dhcp22.suse.cz>
 <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com>
 <20180107090229.GB24862@dhcp22.suse.cz>
 <87mv1phptq.fsf@concordia.ellerman.id.au>
 <7a44f42e-39d0-1c4b-19e0-7df1b0842c18@linux.vnet.ibm.com>
 <87tvvw80f2.fsf@concordia.ellerman.id.au>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 9 Jan 2018 17:18:38 +0530
MIME-Version: 1.0
In-Reply-To: <87tvvw80f2.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <96458c0a-e273-3fb9-a33b-f6f2d536f90b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/09/2018 03:42 AM, Michael Ellerman wrote:
> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> 
>> On 01/07/2018 04:56 PM, Michael Ellerman wrote:
>>> Michal Hocko <mhocko@kernel.org> writes:
>>>
>>>> On Sun 07-01-18 12:19:32, Anshuman Khandual wrote:
>>>>> On 01/05/2018 02:16 PM, Michal Hocko wrote:
>>>> [...]
>>>>>> Could you give us more information about the failure please. Debugging
>>>>>> patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
>>>>>> should help to see what is the clashing VMA.
>>>>> Seems like its re-requesting the same mapping again.
>>>> It always seems to be the same mapping which is a bit strange as we
>>>> have multiple binaries here. Are these binaries any special? Does this
>>>> happen to all bianries (except for init which has obviously started
>>>> successfully)? Could you add an additional debugging (at the do_mmap
>>>> layer) to see who is requesting the mapping for the first time?
>>>>
>>>>> [   23.423642] 9148 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
>>>>> [   23.423706] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
>>>> I also find it a bit unexpected that this is an anonymous mapping
>>>> because the elf loader should always map a file backed one.
>>> Anshuman what machine is this on, and what distro and toolchain is it running?
>>>
>>> I don't see this on any of my machines, so I wonder if this is
>>> toolchain/distro specific.
>>
>> POWER9, RHEL 7.4, gcc (GCC) 4.8.5 20150623, GNU Make 3.82 etc.
> 
> So what does readelf -a of /bin/sed look like?

Please find here.

=================================================================================================
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           PowerPC64
  Version:                           0x1
  Entry point address:               0x10002b70
  Start of program headers:          64 (bytes into file)
  Start of section headers:          135560 (bytes into file)
  Flags:                             0x2, abiv2
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         10
  Size of section headers:           64 (bytes)
  Number of section headers:         28
  Section header string table index: 27

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .interp           PROGBITS         0000000010000270  00000270
       0000000000000011  0000000000000000   A       0     0     1
  [ 2] .note.ABI-tag     NOTE             0000000010000284  00000284
       0000000000000020  0000000000000000   A       0     0     4
  [ 3] .note.gnu.build-i NOTE             00000000100002a4  000002a4
       0000000000000024  0000000000000000   A       0     0     4
  [ 4] .gnu.hash         GNU_HASH         00000000100002c8  000002c8
       000000000000003c  0000000000000000   A       5     0     8
  [ 5] .dynsym           DYNSYM           0000000010000308  00000308
       0000000000000a98  0000000000000018   A       6     1     8
  [ 6] .dynstr           STRTAB           0000000010000da0  00000da0
       0000000000000456  0000000000000000   A       0     0     1
  [ 7] .gnu.version      VERSYM           00000000100011f6  000011f6
       00000000000000e2  0000000000000002   A       5     0     2
  [ 8] .gnu.version_r    VERNEED          00000000100012d8  000012d8
       0000000000000020  0000000000000000   A       6     1     8
  [ 9] .rela.dyn         RELA             00000000100012f8  000012f8
       0000000000000168  0000000000000018   A       5     0     8
  [10] .rela.plt         RELA             0000000010001460  00001460
       0000000000000948  0000000000000018   A       5    22     8
  [11] .init             PROGBITS         0000000010001dc0  00001dc0
       000000000000004c  0000000000000000  AX       0     0     32
  [12] .text             PROGBITS         0000000010001e20  00001e20
       000000000000e550  0000000000000000  AX       0     0     32
  [13] .fini             PROGBITS         0000000010010370  00010370
       0000000000000024  0000000000000000  AX       0     0     4
  [14] .rodata           PROGBITS         0000000010010398  00010398
       0000000000001738  0000000000000000   A       0     0     8
  [15] .eh_frame_hdr     PROGBITS         0000000010011ad0  00011ad0
       00000000000004b4  0000000000000000   A       0     0     4
  [16] .eh_frame         PROGBITS         0000000010011f88  00011f88
       0000000000001b04  0000000000000000   A       0     0     8
  [17] .init_array       INIT_ARRAY       000000001002fd40  0001fd40
       0000000000000008  0000000000000000  WA       0     0     8
  [18] .fini_array       FINI_ARRAY       000000001002fd48  0001fd48
       0000000000000008  0000000000000000  WA       0     0     8
  [19] .jcr              PROGBITS         000000001002fd50  0001fd50
       0000000000000008  0000000000000000  WA       0     0     8
  [20] .dynamic          DYNAMIC          000000001002fd58  0001fd58
       0000000000000200  0000000000000010  WA       6     0     8
  [21] .got              PROGBITS         000000001002ff58  0001ff58
       00000000000000a8  0000000000000008  WA       0     0     8
  [22] .plt              NOBITS           0000000010030000  00020000
       0000000000000328  0000000000000008  WA       0     0     8
  [23] .data             PROGBITS         0000000010030328  00020328
       0000000000000384  0000000000000000  WA       0     0     8
  [24] .bss              NOBITS           00000000100306b0  000206ac
       0000000000009118  0000000000000000  WA       0     0     8
  [25] .gnu_debuglink    PROGBITS         0000000000000000  000206ac
       0000000000000010  0000000000000000           0     0     4
  [26] .gnu_debugdata    PROGBITS         0000000000000000  000206bc
       00000000000009c4  0000000000000000           0     0     1
  [27] .shstrtab         STRTAB           0000000000000000  00021080
       0000000000000104  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  p (processor specific)

There are no section groups in this file.

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  PHDR           0x0000000000000040 0x0000000010000040 0x0000000010000040
                 0x0000000000000230 0x0000000000000230  R E    8
  INTERP         0x0000000000000270 0x0000000010000270 0x0000000010000270
                 0x0000000000000011 0x0000000000000011  R      1
      [Requesting program interpreter: /lib64/ld64.so.2]
  LOAD           0x0000000000000000 0x0000000010000000 0x0000000010000000
                 0x0000000000013a8c 0x0000000000013a8c  R E    10000
  LOAD           0x000000000001fd40 0x000000001002fd40 0x000000001002fd40
                 0x00000000000002c0 0x00000000000005e8  RW     10000
  LOAD           0x0000000000020328 0x0000000010030328 0x0000000010030328
                 0x0000000000000384 0x00000000000094a0  RW     10000
  DYNAMIC        0x000000000001fd58 0x000000001002fd58 0x000000001002fd58
                 0x0000000000000200 0x0000000000000200  RW     8
  NOTE           0x0000000000000284 0x0000000010000284 0x0000000010000284
                 0x0000000000000044 0x0000000000000044  R      4
  GNU_EH_FRAME   0x0000000000011ad0 0x0000000010011ad0 0x0000000010011ad0
                 0x00000000000004b4 0x00000000000004b4  R      4
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     10
  GNU_RELRO      0x000000000001fd40 0x000000001002fd40 0x000000001002fd40
                 0x00000000000002c0 0x00000000000002c0  R      1

 Section to Segment mapping:
  Segment Sections...
   00     
   01     .interp 
   02     .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .text .fini .rodata .eh_frame_hdr .eh_frame 
   03     .init_array .fini_array .jcr .dynamic .got .plt 
   04     .data .bss 
   05     .dynamic 
   06     .note.ABI-tag .note.gnu.build-id 
   07     .eh_frame_hdr 
   08     
   09     .init_array .fini_array .jcr .dynamic .got 

Dynamic section at offset 0x1fd58 contains 27 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libselinux.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000c (INIT)               0x10001dd0
 0x000000000000000d (FINI)               0x10010370
 0x0000000000000019 (INIT_ARRAY)         0x1002fd40
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x1002fd48
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x100002c8
 0x0000000000000005 (STRTAB)             0x10000da0
 0x0000000000000006 (SYMTAB)             0x10000308
 0x000000000000000a (STRSZ)              1110 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000003 (PLTGOT)             0x10030000
 0x0000000000000002 (PLTRELSZ)           2376 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x10001460
 0x0000000070000000 (PPC64_GLINK)        0x100101a0
 0x0000000070000003 (PPC64_OPT)          0x0
 0x0000000000000007 (RELA)               0x100012f8
 0x0000000000000008 (RELASZ)             360 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffffe (VERNEED)            0x100012d8
 0x000000006fffffff (VERNEEDNUM)         1
 0x000000006ffffff0 (VERSYM)             0x100011f6
 0x0000000000000000 (NULL)               0x0

Relocation section '.rela.dyn' at offset 0x12f8 contains 15 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
00001002ff60  003400000026 R_PPC64_ADDR64    0000000000000000 __gmon_start__ + 0
00001002ff88  000c00000026 R_PPC64_ADDR64    0000000000000000 stderr@GLIBC_2.17 + 0
00001002ffb8  000c00000026 R_PPC64_ADDR64    0000000000000000 stderr@GLIBC_2.17 + 0
00001002ffd0  000c00000026 R_PPC64_ADDR64    0000000000000000 stderr@GLIBC_2.17 + 0
00001002fff0  000c00000026 R_PPC64_ADDR64    0000000000000000 stderr@GLIBC_2.17 + 0
00001002ff90  002100000026 R_PPC64_ADDR64    0000000000000000 stdout@GLIBC_2.17 + 0
00001002ffb0  002100000026 R_PPC64_ADDR64    0000000000000000 stdout@GLIBC_2.17 + 0
00001002ffd8  002100000026 R_PPC64_ADDR64    0000000000000000 stdout@GLIBC_2.17 + 0
00001002ffe8  002100000026 R_PPC64_ADDR64    0000000000000000 stdout@GLIBC_2.17 + 0
00001002fff8  002100000026 R_PPC64_ADDR64    0000000000000000 stdout@GLIBC_2.17 + 0
00001002ff98  000f00000026 R_PPC64_ADDR64    0000000000000000 optarg@GLIBC_2.17 + 0
00001002ffa0  001700000026 R_PPC64_ADDR64    0000000000000000 optind@GLIBC_2.17 + 0
00001002ffa8  002e00000026 R_PPC64_ADDR64    0000000000000000 stdin@GLIBC_2.17 + 0
00001002ffc8  002e00000026 R_PPC64_ADDR64    0000000000000000 stdin@GLIBC_2.17 + 0
00001002ffe0  002e00000026 R_PPC64_ADDR64    0000000000000000 stdin@GLIBC_2.17 + 0

Relocation section '.rela.plt' at offset 0x1460 contains 99 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000010030010  000100000015 R_PPC64_JMP_SLOT  0000000000000000 mbrtowc@GLIBC_2.17 + 0
000010030018  000200000015 R_PPC64_JMP_SLOT  0000000000000000 memcpy@GLIBC_2.17 + 0
000010030020  000300000015 R_PPC64_JMP_SLOT  0000000000000000 memmove@GLIBC_2.17 + 0
000010030028  000400000015 R_PPC64_JMP_SLOT  0000000000000000 strlen@GLIBC_2.17 + 0
000010030030  000500000015 R_PPC64_JMP_SLOT  0000000000000000 __sprintf_chk@GLIBC_2.17 + 0
000010030038  000600000015 R_PPC64_JMP_SLOT  0000000000000000 exit@GLIBC_2.17 + 0
000010030040  000700000015 R_PPC64_JMP_SLOT  0000000000000000 is_selinux_enabled + 0
000010030048  000800000015 R_PPC64_JMP_SLOT  0000000000000000 error@GLIBC_2.17 + 0
000010030050  000a00000015 R_PPC64_JMP_SLOT  0000000000000000 readlink@GLIBC_2.17 + 0
000010030058  000b00000015 R_PPC64_JMP_SLOT  0000000000000000 ftell@GLIBC_2.17 + 0
000010030060  000d00000015 R_PPC64_JMP_SLOT  0000000000000000 setvbuf@GLIBC_2.17 + 0
000010030068  000e00000015 R_PPC64_JMP_SLOT  0000000000000000 __fwriting@GLIBC_2.17 + 0
000010030070  001000000015 R_PPC64_JMP_SLOT  0000000000000000 re_set_syntax@GLIBC_2.17 + 0
000010030078  001100000015 R_PPC64_JMP_SLOT  0000000000000000 fileno@GLIBC_2.17 + 0
000010030080  001200000015 R_PPC64_JMP_SLOT  0000000000000000 fclose@GLIBC_2.17 + 0
000010030088  001300000015 R_PPC64_JMP_SLOT  0000000000000000 wctob@GLIBC_2.17 + 0
000010030090  001400000015 R_PPC64_JMP_SLOT  0000000000000000 nl_langinfo@GLIBC_2.17 + 0
000010030098  001500000015 R_PPC64_JMP_SLOT  0000000000000000 fopen@GLIBC_2.17 + 0
0000100300a0  001600000015 R_PPC64_JMP_SLOT  0000000000000000 malloc@GLIBC_2.17 + 0
0000100300a8  001800000015 R_PPC64_JMP_SLOT  0000000000000000 chmod@GLIBC_2.17 + 0
0000100300b0  001900000015 R_PPC64_JMP_SLOT  0000000000000000 getdelim@GLIBC_2.17 + 0
0000100300b8  001a00000015 R_PPC64_JMP_SLOT  0000000000000000 open@GLIBC_2.17 + 0
0000100300c0  001b00000015 R_PPC64_JMP_SLOT  0000000000000000 fgetfilecon + 0
0000100300c8  001c00000015 R_PPC64_JMP_SLOT  0000000000000000 _obstack_begin@GLIBC_2.17 + 0
0000100300d0  001d00000015 R_PPC64_JMP_SLOT  0000000000000000 popen@GLIBC_2.17 + 0
0000100300d8  001e00000015 R_PPC64_JMP_SLOT  0000000000000000 strncmp@GLIBC_2.17 + 0
0000100300e0  001f00000015 R_PPC64_JMP_SLOT  0000000000000000 bindtextdomain@GLIBC_2.17 + 0
0000100300e8  002000000015 R_PPC64_JMP_SLOT  0000000000000000 __libc_start_main@GLIBC_2.17 + 0
0000100300f0  002200000015 R_PPC64_JMP_SLOT  0000000000000000 strverscmp@GLIBC_2.17 + 0
0000100300f8  002300000015 R_PPC64_JMP_SLOT  0000000000000000 __printf_chk@GLIBC_2.17 + 0
000010030100  002400000015 R_PPC64_JMP_SLOT  0000000000000000 memset@GLIBC_2.17 + 0
000010030108  002500000015 R_PPC64_JMP_SLOT  0000000000000000 fdopen@GLIBC_2.17 + 0
000010030110  002600000015 R_PPC64_JMP_SLOT  0000000000000000 fchmod@GLIBC_2.17 + 0
000010030118  002700000015 R_PPC64_JMP_SLOT  0000000000000000 __vfprintf_chk@GLIBC_2.17 + 0
000010030120  002800000015 R_PPC64_JMP_SLOT  0000000000000000 calloc@GLIBC_2.17 + 0
000010030128  002900000015 R_PPC64_JMP_SLOT  0000000000000000 realloc@GLIBC_2.17 + 0
000010030130  002a00000015 R_PPC64_JMP_SLOT  0000000000000000 lgetfilecon + 0
000010030138  002b00000015 R_PPC64_JMP_SLOT  0000000000000000 re_search@GLIBC_2.17 + 0
000010030140  002c00000015 R_PPC64_JMP_SLOT  0000000000000000 __ctype_toupper_loc@GLIBC_2.17 + 0
000010030148  002d00000015 R_PPC64_JMP_SLOT  0000000000000000 rewind@GLIBC_2.17 + 0
000010030150  002f00000015 R_PPC64_JMP_SLOT  0000000000000000 fscanf@GLIBC_2.17 + 0
000010030158  003000000015 R_PPC64_JMP_SLOT  0000000000000000 strerror@GLIBC_2.17 + 0
000010030160  003100000015 R_PPC64_JMP_SLOT  0000000000000000 __stack_chk_fail@GLIBC_2.17 + 0
000010030168  003200000015 R_PPC64_JMP_SLOT  0000000000000000 close@GLIBC_2.17 + 0
000010030170  003300000015 R_PPC64_JMP_SLOT  0000000000000000 strrchr@GLIBC_2.17 + 0
000010030178  003400000015 R_PPC64_JMP_SLOT  0000000000000000 __gmon_start__ + 0
000010030180  003500000015 R_PPC64_JMP_SLOT  0000000000000000 btowc@GLIBC_2.17 + 0
000010030188  003600000015 R_PPC64_JMP_SLOT  0000000000000000 abort@GLIBC_2.17 + 0
000010030190  003700000015 R_PPC64_JMP_SLOT  0000000000000000 mkostemp@GLIBC_2.17 + 0
000010030198  003800000015 R_PPC64_JMP_SLOT  0000000000000000 re_compile_pattern@GLIBC_2.17 + 0
0000100301a0  003900000015 R_PPC64_JMP_SLOT  0000000000000000 getfilecon + 0
0000100301a8  003a00000015 R_PPC64_JMP_SLOT  0000000000000000 mbsinit@GLIBC_2.17 + 0
0000100301b0  003b00000015 R_PPC64_JMP_SLOT  0000000000000000 __overflow@GLIBC_2.17 + 0
0000100301b8  003c00000015 R_PPC64_JMP_SLOT  0000000000000000 fread_unlocked@GLIBC_2.17 + 0
0000100301c0  003d00000015 R_PPC64_JMP_SLOT  0000000000000000 memcmp@GLIBC_2.17 + 0
0000100301c8  003e00000015 R_PPC64_JMP_SLOT  0000000000000000 textdomain@GLIBC_2.17 + 0
0000100301d0  003f00000015 R_PPC64_JMP_SLOT  0000000000000000 setfscreatecon + 0
0000100301d8  004000000015 R_PPC64_JMP_SLOT  0000000000000000 _IO_putc@GLIBC_2.17 + 0
0000100301e0  004100000015 R_PPC64_JMP_SLOT  0000000000000000 getopt_long@GLIBC_2.17 + 0
0000100301e8  004200000015 R_PPC64_JMP_SLOT  0000000000000000 __fprintf_chk@GLIBC_2.17 + 0
0000100301f0  004300000015 R_PPC64_JMP_SLOT  0000000000000000 strcmp@GLIBC_2.17 + 0
0000100301f8  004400000015 R_PPC64_JMP_SLOT  0000000000000000 __ctype_b_loc@GLIBC_2.17 + 0
000010030200  004500000015 R_PPC64_JMP_SLOT  0000000000000000 strtol@GLIBC_2.17 + 0
000010030208  004600000015 R_PPC64_JMP_SLOT  0000000000000000 fread@GLIBC_2.17 + 0
000010030210  006d00000015 R_PPC64_JMP_SLOT  0000000010010360 free@GLIBC_2.17 + 0
000010030218  004700000015 R_PPC64_JMP_SLOT  0000000000000000 ungetc@GLIBC_2.17 + 0
000010030220  004800000015 R_PPC64_JMP_SLOT  0000000000000000 __ctype_get_mb_cur_max@GLIBC_2.17 + 0
000010030228  004900000015 R_PPC64_JMP_SLOT  0000000000000000 strchr@GLIBC_2.17 + 0
000010030230  004a00000015 R_PPC64_JMP_SLOT  0000000000000000 rename@GLIBC_2.17 + 0
000010030238  004b00000015 R_PPC64_JMP_SLOT  0000000000000000 fwrite@GLIBC_2.17 + 0
000010030240  004c00000015 R_PPC64_JMP_SLOT  0000000000000000 clearerr@GLIBC_2.17 + 0
000010030248  004d00000015 R_PPC64_JMP_SLOT  0000000000000000 dcngettext@GLIBC_2.17 + 0
000010030250  004e00000015 R_PPC64_JMP_SLOT  0000000000000000 fflush@GLIBC_2.17 + 0
000010030258  004f00000015 R_PPC64_JMP_SLOT  0000000000000000 strcpy@GLIBC_2.17 + 0
000010030260  005000000015 R_PPC64_JMP_SLOT  0000000000000000 clearerr_unlocked@GLIBC_2.17 + 0
000010030268  005100000015 R_PPC64_JMP_SLOT  0000000000000000 __lxstat@GLIBC_2.17 + 0
000010030270  005200000015 R_PPC64_JMP_SLOT  0000000000000000 memchr@GLIBC_2.17 + 0
000010030278  005300000015 R_PPC64_JMP_SLOT  0000000000000000 isatty@GLIBC_2.17 + 0
000010030280  005500000015 R_PPC64_JMP_SLOT  0000000000000000 _obstack_newchunk@GLIBC_2.17 + 0
000010030288  005600000015 R_PPC64_JMP_SLOT  0000000000000000 __fxstat@GLIBC_2.17 + 0
000010030290  005700000015 R_PPC64_JMP_SLOT  0000000000000000 dcgettext@GLIBC_2.17 + 0
000010030298  005800000015 R_PPC64_JMP_SLOT  0000000000000000 freecon + 0
0000100302a0  005900000015 R_PPC64_JMP_SLOT  0000000000000000 fputs_unlocked@GLIBC_2.17 + 0
0000100302a8  005a00000015 R_PPC64_JMP_SLOT  0000000000000000 strncpy@GLIBC_2.17 + 0
0000100302b0  005b00000015 R_PPC64_JMP_SLOT  0000000000000000 pclose@GLIBC_2.17 + 0
0000100302b8  005d00000015 R_PPC64_JMP_SLOT  0000000000000000 towupper@GLIBC_2.17 + 0
0000100302c0  005e00000015 R_PPC64_JMP_SLOT  0000000000000000 iswprint@GLIBC_2.17 + 0
0000100302c8  005f00000015 R_PPC64_JMP_SLOT  0000000000000000 umask@GLIBC_2.17 + 0
0000100302d0  006000000015 R_PPC64_JMP_SLOT  0000000000000000 getfscreatecon + 0
0000100302d8  006100000015 R_PPC64_JMP_SLOT  0000000000000000 __errno_location@GLIBC_2.17 + 0
0000100302e0  006200000015 R_PPC64_JMP_SLOT  0000000000000000 getenv@GLIBC_2.17 + 0
0000100302e8  006300000015 R_PPC64_JMP_SLOT  0000000000000000 __memmove_chk@GLIBC_2.17 + 0
0000100302f0  006400000015 R_PPC64_JMP_SLOT  0000000000000000 unlink@GLIBC_2.17 + 0
0000100302f8  006500000015 R_PPC64_JMP_SLOT  0000000000000000 fchown@GLIBC_2.17 + 0
000010030300  006600000015 R_PPC64_JMP_SLOT  0000000000000000 towlower@GLIBC_2.17 + 0
000010030308  006700000015 R_PPC64_JMP_SLOT  0000000000000000 __uflow@GLIBC_2.17 + 0
000010030310  006800000015 R_PPC64_JMP_SLOT  0000000000000000 setlocale@GLIBC_2.17 + 0
000010030318  006900000015 R_PPC64_JMP_SLOT  0000000000000000 ferror@GLIBC_2.17 + 0
000010030320  006a00000015 R_PPC64_JMP_SLOT  0000000000000000 wcrtomb@GLIBC_2.17 + 0

The decoding of unwind sections for machine type PowerPC64 is not currently supported.

Symbol table '.dynsym' contains 113 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND mbrtowc@GLIBC_2.17 (2)
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memcpy@GLIBC_2.17 (2)
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memmove@GLIBC_2.17 (2)
     4: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strlen@GLIBC_2.17 (2)
     5: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __sprintf_chk@GLIBC_2.17 (2)
     6: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND exit@GLIBC_2.17 (2)
     7: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND is_selinux_enabled
     8: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND error@GLIBC_2.17 (2)
     9: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterTMCloneTab
    10: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND readlink@GLIBC_2.17 (2)
    11: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND ftell@GLIBC_2.17 (2)
    12: 0000000000000000     0 OBJECT  GLOBAL DEFAULT  UND stderr@GLIBC_2.17 (2)
    13: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND setvbuf@GLIBC_2.17 (2)
    14: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __fwriting@GLIBC_2.17 (2)
    15: 0000000000000000     0 OBJECT  GLOBAL DEFAULT  UND optarg@GLIBC_2.17 (2)
    16: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND re_set_syntax@GLIBC_2.17 (2)
    17: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fileno@GLIBC_2.17 (2)
    18: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fclose@GLIBC_2.17 (2)
    19: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND wctob@GLIBC_2.17 (2)
    20: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND nl_langinfo@GLIBC_2.17 (2)
    21: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fopen@GLIBC_2.17 (2)
    22: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND malloc@GLIBC_2.17 (2)
    23: 0000000000000000     0 OBJECT  GLOBAL DEFAULT  UND optind@GLIBC_2.17 (2)
    24: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND chmod@GLIBC_2.17 (2)
    25: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getdelim@GLIBC_2.17 (2)
    26: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND open@GLIBC_2.17 (2)
    27: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fgetfilecon
    28: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _obstack_begin@GLIBC_2.17 (2)
    29: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND popen@GLIBC_2.17 (2)
    30: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strncmp@GLIBC_2.17 (2)
    31: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND bindtextdomain@GLIBC_2.17 (2)
    32: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@GLIBC_2.17 (2)
    33: 0000000000000000     0 OBJECT  GLOBAL DEFAULT  UND stdout@GLIBC_2.17 (2)
    34: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strverscmp@GLIBC_2.17 (2)
    35: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __printf_chk@GLIBC_2.17 (2)
    36: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memset@GLIBC_2.17 (2)
    37: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fdopen@GLIBC_2.17 (2)
    38: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fchmod@GLIBC_2.17 (2)
    39: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __vfprintf_chk@GLIBC_2.17 (2)
    40: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND calloc@GLIBC_2.17 (2)
    41: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND realloc@GLIBC_2.17 (2)
    42: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND lgetfilecon
    43: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND re_search@GLIBC_2.17 (2)
    44: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __ctype_toupper_loc@GLIBC_2.17 (2)
    45: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND rewind@GLIBC_2.17 (2)
    46: 0000000000000000     0 OBJECT  GLOBAL DEFAULT  UND stdin@GLIBC_2.17 (2)
    47: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fscanf@GLIBC_2.17 (2)
    48: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strerror@GLIBC_2.17 (2)
    49: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __stack_chk_fail@GLIBC_2.17 (2)
    50: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND close@GLIBC_2.17 (2)
    51: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strrchr@GLIBC_2.17 (2)
    52: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
    53: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND btowc@GLIBC_2.17 (2)
    54: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND abort@GLIBC_2.17 (2)
    55: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND mkostemp@GLIBC_2.17 (2)
    56: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND re_compile_pattern@GLIBC_2.17 (2)
    57: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getfilecon
    58: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND mbsinit@GLIBC_2.17 (2)
    59: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __overflow@GLIBC_2.17 (2)
    60: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fread_unlocked@GLIBC_2.17 (2)
    61: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memcmp@GLIBC_2.17 (2)
    62: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND textdomain@GLIBC_2.17 (2)
    63: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND setfscreatecon
    64: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _IO_putc@GLIBC_2.17 (2)
    65: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getopt_long@GLIBC_2.17 (2)
    66: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __fprintf_chk@GLIBC_2.17 (2)
    67: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strcmp@GLIBC_2.17 (2)
    68: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __ctype_b_loc@GLIBC_2.17 (2)
    69: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strtol@GLIBC_2.17 (2)
    70: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fread@GLIBC_2.17 (2)
    71: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND ungetc@GLIBC_2.17 (2)
    72: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __ctype_get_mb_cur_max@GLIBC_2.17 (2)
    73: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strchr@GLIBC_2.17 (2)
    74: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND rename@GLIBC_2.17 (2)
    75: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fwrite@GLIBC_2.17 (2)
    76: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND clearerr@GLIBC_2.17 (2)
    77: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND dcngettext@GLIBC_2.17 (2)
    78: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fflush@GLIBC_2.17 (2)
    79: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strcpy@GLIBC_2.17 (2)
    80: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND clearerr_unlocked@GLIBC_2.17 (2)
    81: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __lxstat@GLIBC_2.17 (2)
    82: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memchr@GLIBC_2.17 (2)
    83: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND isatty@GLIBC_2.17 (2)
    84: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _Jv_RegisterClasses
    85: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _obstack_newchunk@GLIBC_2.17 (2)
    86: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __fxstat@GLIBC_2.17 (2)
    87: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND dcgettext@GLIBC_2.17 (2)
    88: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND freecon
    89: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fputs_unlocked@GLIBC_2.17 (2)
    90: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strncpy@GLIBC_2.17 (2)
    91: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND pclose@GLIBC_2.17 (2)
    92: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMCloneTable
    93: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND towupper@GLIBC_2.17 (2)
    94: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND iswprint@GLIBC_2.17 (2)
    95: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND umask@GLIBC_2.17 (2)
    96: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getfscreatecon
    97: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __errno_location@GLIBC_2.17 (2)
    98: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getenv@GLIBC_2.17 (2)
    99: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __memmove_chk@GLIBC_2.17 (2)
   100: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND unlink@GLIBC_2.17 (2)
   101: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fchown@GLIBC_2.17 (2)
   102: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND towlower@GLIBC_2.17 (2)
   103: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __uflow@GLIBC_2.17 (2)
   104: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND setlocale@GLIBC_2.17 (2)
   105: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND ferror@GLIBC_2.17 (2)
   106: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND wcrtomb@GLIBC_2.17 (2)
   107: 00000000100306ac     0 NOTYPE  GLOBAL DEFAULT   23 _edata
   108: 00000000100397c8     0 NOTYPE  GLOBAL DEFAULT   24 _end
   109: 0000000010010360     0 FUNC    GLOBAL DEFAULT  UND free@GLIBC_2.17 (2)
   110: 00000000100306ac     0 NOTYPE  GLOBAL DEFAULT   24 __bss_start
   111: 0000000010001dd0     0 FUNC    GLOBAL DEFAULT [<localentry>: 8]    11 _init
   112: 0000000010010370     0 FUNC    GLOBAL DEFAULT [<localentry>: 8]    13 _fini

Histogram for `.gnu.hash' bucket list length (total of 3 buckets):
 Length  Number     % of total  Coverage
      0  0          (  0.0%)
      1  1          ( 33.3%)     16.7%
      2  1          ( 33.3%)     50.0%
      3  1          ( 33.3%)    100.0%

Version symbols section '.gnu.version' contains 113 entries:
 Addr: 00000000100011f6  Offset: 0x0011f6  Link: 5 (.dynsym)
  000:   0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  004:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    0 (*local*)    
  008:   2 (GLIBC_2.17)    0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  00c:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  010:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  014:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  018:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    0 (*local*)    
  01c:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  020:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  024:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  028:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    0 (*local*)       2 (GLIBC_2.17) 
  02c:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  030:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  034:   0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  038:   2 (GLIBC_2.17)    0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  03c:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    0 (*local*)    
  040:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  044:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  048:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  04c:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  050:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  054:   0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  058:   0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  05c:   0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  060:   0 (*local*)       2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  064:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17) 
  068:   2 (GLIBC_2.17)    2 (GLIBC_2.17)    2 (GLIBC_2.17)    1 (*global*)   
  06c:   1 (*global*)      2 (GLIBC_2.17)    1 (*global*)      1 (*global*)   
  070:   1 (*global*)   

Version needs section '.gnu.version_r' contains 1 entries:
 Addr: 0x00000000100012d8  Offset: 0x0012d8  Link: 6 (.dynstr)
  000000: Version: 1  File: libc.so.6  Cnt: 1
  0x0010:   Name: GLIBC_2.17  Flags: none  Version: 2

Displaying notes found at file offset 0x00000284 with length 0x00000020:
  Owner                 Data size	Description
  GNU                  0x00000010	NT_GNU_ABI_TAG (ABI version tag)
    OS: Linux, ABI: 2.6.32

Displaying notes found at file offset 0x000002a4 with length 0x00000024:
  Owner                 Data size	Description
  GNU                  0x00000014	NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: a6c7b5f6f5cf4174f94bc7568ca07cfd81ee4443
=================================================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
