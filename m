Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6176B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 06:45:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p194so67731352iod.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 03:45:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j75si5947427otj.115.2016.06.02.03.45.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 03:45:10 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
	<1464613556-16708-5-git-send-email-mhocko@kernel.org>
	<201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
	<20160601142502.GY26601@dhcp22.suse.cz>
In-Reply-To: <20160601142502.GY26601@dhcp22.suse.cz>
Message-Id: <201606021945.AFH26572.OJMVLFOHFFtOSQ@I-love.SAKURA.ne.jp>
Date: Thu, 2 Jun 2016 19:45:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Wed 01-06-16 23:12:20, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > vforked tasks are not really sitting on any memory. They are sharing
> > > the mm with parent until they exec into a new code. Until then it is
> > > just pinning the address space. OOM killer will kill the vforked task
> > > along with its parent but we still can end up selecting vforked task
> > > when the parent wouldn't be selected. E.g. init doing vfork to launch
> > > a task or vforked being a child of oom unkillable task with an updated
> > > oom_score_adj to be killable.
> > > 
> > > Make sure to not select vforked task as an oom victim by checking
> > > vfork_done in oom_badness.
> > 
> > While vfork()ed task cannot modify userspace memory, can't such task
> > allocate significant amount of kernel memory inside execve() operation
> > (as demonstrated by CVE-2010-4243 64bit_dos.c )?
> > 
> > It is possible that killing vfork()ed task releases a lot of memory,
> > isn't it?
> 
> I am not familiar with the above CVE but doesn't that allocated memory
> come after flush_old_exec (and so mm_release)?

That memory is allocated as of copy_strings() in do_execveat_common().

An example shown below (based on https://grsecurity.net/~spender/exploits/64bit_dos.c )
can consume nearly 50% of 2GB RAM while execve() from vfork(). That is, selecting
vfork()ed task as an OOM victim might release nearly 50% of 2GB RAM.

----------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define NUM_ARGS 8000 /* Nearly 50% of 2GB RAM */

int main(void)
{
        /* Be sure to do "ulimit -s unlimited" before run. */
        char **args;
        char *str;
        int i;
        str = malloc(128 * 1024);
        memset(str, ' ', 128 * 1024 - 1);
        str[128 * 1024 - 1] = '\0';
        args = malloc(NUM_ARGS * sizeof(char *));
        for (i = 0; i < (NUM_ARGS - 1); i++)
                args[i] = str;
        args[i] = NULL;
        if (vfork() == 0) {
                execve("/bin/true", args, NULL);
                _exit(1);
        }
        return 0;
}
----------

# strace -f ./a.out
execve("./a.out", ["./a.out"], [/* 22 vars */]) = 0
brk(0)                                  = 0x2283000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2bdbc81000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=44165, ...}) = 0
mmap(NULL, 44165, PROT_READ, MAP_PRIVATE, 3, 0) = 0x2b2bdbc82000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \34\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=2112384, ...}) = 0
mmap(NULL, 3936832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x2b2bdbe84000
mprotect(0x2b2bdc03b000, 2097152, PROT_NONE) = 0
mmap(0x2b2bdc23b000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b7000) = 0x2b2bdc23b000
mmap(0x2b2bdc241000, 16960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2b2bdc241000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2bdbc8d000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2bdbc8e000
arch_prctl(ARCH_SET_FS, 0x2b2bdbc8db80) = 0
mprotect(0x2b2bdc23b000, 16384, PROT_READ) = 0
mprotect(0x600000, 4096, PROT_READ)     = 0
mprotect(0x2b2bdbe81000, 4096, PROT_READ) = 0
munmap(0x2b2bdbc82000, 44165)           = 0
mmap(NULL, 135168, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2bdbc90000
brk(0)                                  = 0x2283000
brk(0x22b3000)                          = 0x22b3000
brk(0)                                  = 0x22b3000
vfork(Process 9787 attached
 <unfinished ...>
[pid  9787] execve("/bin/true", ["                                "..., (...snipped...), ...], [/* 0 vars */] <unfinished ...>
[pid  9786] <... vfork resumed> )       = 9787
[pid  9786] exit_group(0)               = ?
[pid  9786] +++ exited with 0 +++
<... execve resumed> )                  = 0
brk(0)                                  = 0x13e2000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2e71a6f000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=44165, ...}) = 0
mmap(NULL, 44165, PROT_READ, MAP_PRIVATE, 3, 0) = 0x2b2e71a70000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \34\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=2112384, ...}) = 0
mmap(NULL, 3936832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x2b2e71c6e000
mprotect(0x2b2e71e25000, 2097152, PROT_NONE) = 0
mmap(0x2b2e72025000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b7000) = 0x2b2e72025000
mmap(0x2b2e7202b000, 16960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2b2e7202b000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2e71a7b000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b2e71a7c000
arch_prctl(ARCH_SET_FS, 0x2b2e71a7bb80) = 0
mprotect(0x2b2e72025000, 16384, PROT_READ) = 0
mprotect(0x605000, 4096, PROT_READ)     = 0
mprotect(0x2b2e71c6b000, 4096, PROT_READ) = 0
munmap(0x2b2e71a70000, 44165)           = 0
exit_group(0)                           = ?
+++ exited with 0 +++

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
