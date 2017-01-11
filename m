Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C75B66B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 20:11:20 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b22so739792518pfd.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 17:11:20 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id x8si3905607plm.134.2017.01.10.17.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 17:11:19 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id y143so34952161pfb.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 17:11:19 -0800 (PST)
Date: Tue, 10 Jan 2017 17:11:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: Respect FOLL_FORCE/FOLL_COW for thp
In-Reply-To: <20170106015025.GA38411@juliacomputing.com>
Message-ID: <alpine.DEB.2.10.1701101711010.129912@chino.kir.corp.google.com>
References: <20170106015025.GA38411@juliacomputing.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keno Fischer <keno@juliacomputing.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, gthelen@google.com, npiggin@gmail.com, w@1wt.eu, oleg@redhat.com, keescook@chromium.org, luto@kernel.org, mhocko@suse.com, hughd@google.com, kirill@shutemov.name

On Thu, 5 Jan 2017, Keno Fischer wrote:

> In 19be0eaff ("mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"),
> the mm code was changed from unsetting FOLL_WRITE after a COW was resolved to
> setting the (newly introduced) FOLL_COW instead. Simultaneously, the check in
> gup.c was updated to still allow writes with FOLL_FORCE set if FOLL_COW had
> also been set. However, a similar check in huge_memory.c was forgotten. As a
> result, remote memory writes to ro regions of memory backed by transparent huge
> pages cause an infinite loop in the kernel (handle_mm_fault sets FOLL_COW and
> returns 0 causing a retry, but follow_trans_huge_pmd bails out immidiately
> because `(flags & FOLL_WRITE) && !pmd_write(*pmd)` is true. While in this
> state the process is stil SIGKILLable, but little else works (e.g. no ptrace
> attach, no other signals). This is easily reproduced with the following
> code (assuming thp are set to always):
> 
>     #include <assert.h>
>     #include <fcntl.h>
>     #include <stdint.h>
>     #include <stdio.h>
>     #include <string.h>
>     #include <sys/mman.h>
>     #include <sys/stat.h>
>     #include <sys/types.h>
>     #include <sys/wait.h>
>     #include <unistd.h>
> 
>     #define TEST_SIZE 5 * 1024 * 1024
> 
>     int main(void) {
>       int status;
>       pid_t child;
>       int fd = open("/proc/self/mem", O_RDWR);
>       void *addr = mmap(NULL, TEST_SIZE, PROT_READ,
>                         MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
>       assert(addr != MAP_FAILED);
>       pid_t parent_pid = getpid();
>       if ((child = fork()) == 0) {
>         void *addr2 = mmap(NULL, TEST_SIZE, PROT_READ | PROT_WRITE,
>                            MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
>         assert(addr2 != MAP_FAILED);
>         memset(addr2, 'a', TEST_SIZE);
>         pwrite(fd, addr2, TEST_SIZE, (uintptr_t)addr);
>         return 0;
>       }
>       assert(child == waitpid(child, &status, 0));
>       assert(WIFEXITED(status) && WEXITSTATUS(status) == 0);
>       return 0;
>     }
> 
> Fix this by updating follow_trans_huge_pmd in huge_memory.c analogously to
> the update in gup.c in the original commit. The same pattern exists in
> follow_devmap_pmd. However, we should not be able to reach that check
> with FOLL_COW set, so add WARN_ONCE to make sure we notice if we ever
> do.
> 
> Signed-off-by: Keno Fischer <keno@juliacomputing.com>

Tested-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
