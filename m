Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D96396B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 07:26:57 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so1780461wme.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 04:26:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si1379936wrn.36.2017.01.10.04.26.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 04:26:56 -0800 (PST)
Date: Tue, 10 Jan 2017 13:26:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Respect FOLL_FORCE/FOLL_COW for thp
Message-ID: <20170110122654.GE28025@dhcp22.suse.cz>
References: <20170106015025.GA38411@juliacomputing.com>
 <20170106081844.GA4454@node.shutemov.name>
 <20170110092909.GA28025@dhcp22.suse.cz>
 <20170110122045.GA2058@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110122045.GA2058@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Keno Fischer <keno@juliacomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, gthelen@google.com, npiggin@gmail.com, w@1wt.eu, oleg@redhat.com, keescook@chromium.org, luto@kernel.org, hughd@google.com

On Tue 10-01-17 15:20:45, Kirill A. Shutemov wrote:
> On Tue, Jan 10, 2017 at 10:29:10AM +0100, Michal Hocko wrote:
> > On Fri 06-01-17 11:18:44, Kirill A. Shutemov wrote:
> > > On Thu, Jan 05, 2017 at 08:50:25PM -0500, Keno Fischer wrote:
> > > > In 19be0eaff ("mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"),
> > > > the mm code was changed from unsetting FOLL_WRITE after a COW was resolved to
> > > > setting the (newly introduced) FOLL_COW instead. Simultaneously, the check in
> > > > gup.c was updated to still allow writes with FOLL_FORCE set if FOLL_COW had
> > > > also been set. However, a similar check in huge_memory.c was forgotten. As a
> > > > result, remote memory writes to ro regions of memory backed by transparent huge
> > > > pages cause an infinite loop in the kernel (handle_mm_fault sets FOLL_COW and
> > > > returns 0 causing a retry, but follow_trans_huge_pmd bails out immidiately
> > > > because `(flags & FOLL_WRITE) && !pmd_write(*pmd)` is true. While in this
> > > > state the process is stil SIGKILLable, but little else works (e.g. no ptrace
> > > > attach, no other signals). This is easily reproduced with the following
> > > > code (assuming thp are set to always):
> > > > 
> > > >     #include <assert.h>
> > > >     #include <fcntl.h>
> > > >     #include <stdint.h>
> > > >     #include <stdio.h>
> > > >     #include <string.h>
> > > >     #include <sys/mman.h>
> > > >     #include <sys/stat.h>
> > > >     #include <sys/types.h>
> > > >     #include <sys/wait.h>
> > > >     #include <unistd.h>
> > > > 
> > > >     #define TEST_SIZE 5 * 1024 * 1024
> > > > 
> > > >     int main(void) {
> > > >       int status;
> > > >       pid_t child;
> > > >       int fd = open("/proc/self/mem", O_RDWR);
> > > >       void *addr = mmap(NULL, TEST_SIZE, PROT_READ,
> > > >                         MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
> > > >       assert(addr != MAP_FAILED);
> > > >       pid_t parent_pid = getpid();
> > > >       if ((child = fork()) == 0) {
> > > >         void *addr2 = mmap(NULL, TEST_SIZE, PROT_READ | PROT_WRITE,
> > > >                            MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
> > > >         assert(addr2 != MAP_FAILED);
> > > >         memset(addr2, 'a', TEST_SIZE);
> > > >         pwrite(fd, addr2, TEST_SIZE, (uintptr_t)addr);
> > > >         return 0;
> > > >       }
> > > >       assert(child == waitpid(child, &status, 0));
> > > >       assert(WIFEXITED(status) && WEXITSTATUS(status) == 0);
> > > >       return 0;
> > > >     }
> > > > 
> > > > Fix this by updating follow_trans_huge_pmd in huge_memory.c analogously to
> > > > the update in gup.c in the original commit. The same pattern exists in
> > > > follow_devmap_pmd. However, we should not be able to reach that check
> > > > with FOLL_COW set, so add WARN_ONCE to make sure we notice if we ever
> > > > do.
> > > > 
> > > > Signed-off-by: Keno Fischer <keno@juliacomputing.com>
> > > 
> > > Cc: stable@ ?
> > 
> > Yes, please! I am just wondering how far do we have to go. I was under
> > impression that we split THP in the past in the gup path but I cannot
> > find the respective code now. Many things have changed after your
> > refcount rework. Could you clarify this part Kirill, please?
> 
> No, we didn't split THP before, unless it's asked specifically with
> FOLL_SPLIT. Otherwise we just pin whole huge page.

Yeah, I've tried to find the FOLL_SPLIT but couldn't...
 
> I think we need to port it all active stable trees as we do with
> 19be0eaff. The race was there since beginning of THP, I believe.

thanks for double checking!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
