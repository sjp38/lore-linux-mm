Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA69B6B000D
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 08:40:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h5so13509338pgv.21
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 05:40:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id az8-v6si2069415plb.723.2018.02.01.05.40.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 05:40:29 -0800 (PST)
Date: Thu, 1 Feb 2018 14:40:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180201134026.GK21609@dhcp22.suse.cz>
References: <20180126140415.GD5027@dhcp22.suse.cz>
 <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
 <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com>
 <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au>
 <20180130094205.GS21609@dhcp22.suse.cz>
 <5eccdc1b-6a10-b48a-c63f-295f69473d97@linux.vnet.ibm.com>
 <20180131131937.GA6740@dhcp22.suse.cz>
 <bfecda5e-ae8b-df91-0add-df6322b42a70@linux.vnet.ibm.com>
 <20180201131007.GJ21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201131007.GJ21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu 01-02-18 14:10:07, Michal Hocko wrote:
> [CC Kees and Linus - for your background, we are talking about failures
>  http://lkml.kernel.org/r/20180107090229.GB24862@dhcp22.suse.cz
>  introduced by http://lkml.kernel.org/r/20171213092550.2774-3-mhocko@kernel.org
>  Debugging has shown that load_elf_binary tries to map elf segment over
>  an existing brk - see below.]
> 
> On Thu 01-02-18 08:43:34, Anshuman Khandual wrote:
> [...]
> > [    9.295990] vma c000001fc8137c80 start 0000000010030000 end 0000000010040000
> > next c000001fc81378c0 prev c000001fc8137680 mm c000001fc8108200
> > prot 8000000000000104 anon_vma           (null) vm_ops           (null)
> > pgoff 1003 file           (null) private_data           (null)
> > flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> > [    9.296351] CPU: 47 PID: 7537 Comm: sed Not tainted 4.14.0-00006-g4bd92fe-dirty #162
> > [    9.296450] Call Trace:
> > [    9.296482] [c000001fc70db9b0] [c000000000b180e0] dump_stack+0xb0/0xf0 (unreliable)
> > [    9.296588] [c000001fc70db9f0] [c0000000002db0b8] do_brk_flags+0x2d8/0x440
> > [    9.296674] [c000001fc70dbac0] [c0000000002db4d0] vm_brk_flags+0x80/0x130
> > [    9.296751] [c000001fc70dbb20] [c0000000003d2998] set_brk+0x80/0xe8
> > [    9.296824] [c000001fc70dbb60] [c0000000003d2518] load_elf_binary+0x12f8/0x1580
> > [    9.296910] [c000001fc70dbc80] [c00000000035d9e0] search_binary_handler+0xd0/0x270
> > [    9.296999] [c000001fc70dbd10] [c00000000035f938] do_execveat_common.isra.31+0x658/0x890
> > [    9.297089] [c000001fc70dbdf0] [c00000000035ff80] SyS_execve+0x40/0x50
> > [    9.297162] [c000001fc70dbe30] [c00000000000b220] system_call+0x58/0x6c
> > 
> > But coming back to when it failed with MAP_FIXED_NOREPLACE, looking into ELF
> > section details (readelf -aW /usr/bin/sed), there was a PT_LOAD segment with
> > p_memsz > p_filesz which might be causing set_brk() to be called.
> > 
> > 
> >   Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
> >   ...
> >   LOAD           0x020328 0x0000000010030328 0x0000000010030328 0x000384 0x0094a0 RW  0x10000
> > 
> > which can be confirmed by just dumping elf_brk/elf_bss for this particular
> > instance. (elf_brk > elf_bss)
> 
> Hmm, interesting. So the above is not a regular brk. The check has been
> added in 2001 by "v2.4.10.1 -> v2.4.10.2" but the changelog is not
> revealing at all.
> 
> Btw. my /bin/ls also has MemSiz>FileSiz
>   LOAD           0x01ade0 0x000000000061ade0 0x000000000061ade0 0x00079c 0x001520 RW  0x200000
>    113: 000000000061b57c     0 NOTYPE  GLOBAL DEFAULT  ABS __bss_start
> 
> and do not see any problem. So this is more likely a problem of elf_brk
> being placed at a wrong address. But I am desperately lost in this code
> so I might be completely off.

Thanks a lot to Michael Matz for his background. He has pointed me to
the following two segments from your binary[1]
  LOAD           0x0000000000000000 0x0000000010000000 0x0000000010000000
                 0x0000000000013a8c 0x0000000000013a8c  R E    10000
  LOAD           0x000000000001fd40 0x000000001002fd40 0x000000001002fd40
                 0x00000000000002c0 0x00000000000005e8  RW     10000
  LOAD           0x0000000000020328 0x0000000010030328 0x0000000010030328
                 0x0000000000000384 0x00000000000094a0  RW     10000

That binary has two RW LOAD segments, the first crosses a page border
into the second
0x1002fd40 (LOAD2-vaddr) + 0x5e8 (LOAD2-memlen) == 0x10030328 (LOAD3-vaddr)

He says
: This is actually an artifact of RELRO machinism.  The first RW mapping
: will be remapped as RO after relocations are applied (to increase
: security).
: Well, to be honest, normal relro binaries also don't have more than
: two LOAD segments, so whatever RHEL did to their compilation options,
: it's something in addition to just relro (which can be detected by
: having a GNU_RELRO program header)
: But it definitely has something to do with relro, it's just not the
: whole story yet.

I am still trying to wrap my head around all this, but it smells rather
dubious to map different segments over the same page. Is this something
that might happen widely and therefore MAP_FIXED_NOREPLACE is a no-go
when loading ELF segments? Or is this a special case we can detect?

Or am I completely off?

[1] http://lkml.kernel.org/r/96458c0a-e273-3fb9-a33b-f6f2d536f90b%40linux.vnet.ibm.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
