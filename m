Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1692D6B01F4
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 00:58:04 -0400 (EDT)
Date: Mon, 12 Apr 2010 12:58:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
Message-ID: <20100412045800.GB18099@localhost>
References: <4BBA6776.5060804@mozilla.com> <20100406095135.GB5183@cmpxchg.org> <20100407022456.GA9468@localhost> <4BBBF402.70403@mozilla.com> <20100407073847.GB17892@localhost> <4BBE1609.6080308@mozilla.com> <20100412022704.GB5151@localhost> <l2z28c262361004112025ydabc82ceyfa21cff9debc85b3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <l2z28c262361004112025ydabc82ceyfa21cff9debc85b3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Taras Glek <tglek@mozilla.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Minchan,

> > Yes, every binary/library starts with this 512b read. A It is requested
> > by ld.so/ld-linux.so, and will trigger a 4-page readahead. This is not
> > good readahead. I wonder if ld.so can switch to mmap read for the
> > first read, in order to trigger a larger 128kb readahead. However this
> > will introduce a little overhead on VMA operations.

Correction with data: in my system, ld is doing one 832b initial read for every library:

        $ strace true
        execve("/bin/true", ["true"], [/* 44 vars */]) = 0
        brk(0)                                  = 0x608000
        mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb3b3ea0000
        access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
        mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb3b3e9e000
        access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
        open("/etc/ld.so.cache", O_RDONLY)      = 3
        fstat(3, {st_mode=S_IFREG|0644, st_size=140899, ...}) = 0
        mmap(NULL, 140899, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fb3b3e7b000
        close(3)                                = 0
        access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
        open("/lib/libc.so.6", O_RDONLY)        = 3
==>     read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\353\1\0\0\0\0\0@"..., 832) = 832
        fstat(3, {st_mode=S_IFREG|0755, st_size=1379752, ...}) = 0
        mmap(NULL, 3487784, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fb3b3931000
        mprotect(0x7fb3b3a7b000, 2097152, PROT_NONE) = 0
        mmap(0x7fb3b3c7b000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14a000) = 0x7fb3b3c7b000
        mmap(0x7fb3b3c80000, 18472, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb3b3c80000
        close(3)                                = 0
        mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb3b3e7a000
        mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb3b3e79000
        arch_prctl(ARCH_SET_FS, 0x7fb3b3e796f0) = 0
        mprotect(0x7fb3b3c7b000, 16384, PROT_READ) = 0
        mprotect(0x7fb3b3ea1000, 4096, PROT_READ) = 0
        munmap(0x7fb3b3e7b000, 140899)          = 0
        brk(0)                                  = 0x608000
        brk(0x629000)                           = 0x629000
        open("/usr/lib/locale/locale-archive", O_RDONLY) = 3
        fstat(3, {st_mode=S_IFREG|0644, st_size=4332320, ...}) = 0
        mmap(NULL, 4332320, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fb3b350f000
        close(3)                                = 0
        close(1)                                = 0
        close(2)                                = 0
        exit_group(0)                           = ?

> AFAIK, kernel reads first sector(ELF header and so one)  of binary in
> case of binary.
> in fs/exec.c,
> prepare_binprm()
> {
> ...
> return kernel_read(bprm->file, 0, bprm->buf, BINPRM_BUF_SIZE);
> }

Thanks for pointing this out. Yes we may optimize the binary part by
adding a readahead call before the kernel_read().
 
> But dynamic loader uses libc_read for reading of shared library's one.
> 
> So you may have a chance to increase readahead size on binary but hard on shared
> library. Many of app have lots of shared library so the solution of
> only binary isn't big about
> performance. :(

Yeah, it won't be a big optimization..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
