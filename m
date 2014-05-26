Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9C61C6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 16:26:19 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so8117586pbc.15
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:26:19 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id gh1si16145235pac.147.2014.05.26.13.26.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 13:26:18 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so7987146pab.14
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:26:18 -0700 (PDT)
Date: Mon, 26 May 2014 13:25:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/process_vm_access: move into ipc/
In-Reply-To: <CALYGNiNE2cdPaxw3f2y0-g2aRZZD1HbrBHpu-zf9Pdjb69kh3w@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1405261314510.3748@eggly.anvils>
References: <20140524135925.32597.45754.stgit@zurg> <alpine.LSU.2.11.1405261210140.3411@eggly.anvils> <CALYGNiNE2cdPaxw3f2y0-g2aRZZD1HbrBHpu-zf9Pdjb69kh3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>

On Mon, 26 May 2014, Konstantin Khlebnikov wrote:
> On Mon, May 26, 2014 at 11:16 PM, Hugh Dickins <hughd@google.com> wrote:
> > On Sat, 24 May 2014, Konstantin Khlebnikov wrote:
> >
> >> "CROSS_MEMORY_ATTACH" and mm/process_vm_access.c seems misnamed and misplaced.
> >> Actually it's a kind of IPC and it has no more relation to MM than sys_read().
> >> This patch moves code into ipc/ and config option into init/Kconfig.
> >>
> >> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> >
> > I disagree, and SysV's ipc/ isn't where I would expect to find it.
> > How about we just leave it where it is in mm?
> 
> Ok, how about moving only config option? It adds couple syscalls and
> nothing more.
> I don't think it should be in "Processor type and features".
> All other options related to non-standard syscalls are in "General
> setup' init/Kconfig.

That sounds reasonable to me.  I see you also snuck in a change
to the prompt string: which indeed seems an improvement, but you
ought to mention it in the comment, rather than hiding it in the move.

(I sometimes wonder if its help text ought to say "This CMA has
absolutely nothing to do with the Contiguous Memory Allocator";
but adding that might increase the confusion rather than reduce it,)

Hugh

> 
> >> diff --git a/init/Kconfig b/init/Kconfig
> >> index 9d3585b..d6ddb7a 100644
> >> --- a/init/Kconfig
> >> +++ b/init/Kconfig
> >> @@ -261,6 +261,16 @@ config POSIX_MQUEUE_SYSCTL
> >>       depends on SYSCTL
> >>       default y
> >>
> >> +config CROSS_MEMORY_ATTACH
> >> +     bool "Enable process_vm_readv/writev syscalls"
> >> +     depends on MMU
> >> +     default y
> >> +     help
> >> +       Enabling this option adds the system calls process_vm_readv and
> >> +       process_vm_writev which allow a process with the correct privileges
> >> +       to directly read from or write to to another process's address space.
> >> +       See the man page for more details.
> >> +
> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> index 1b5a95f..2ec35d7 100644
> >> --- a/mm/Kconfig
> >> +++ b/mm/Kconfig
> >> @@ -430,16 +430,6 @@ choice
> >>         benefit.
> >>  endchoice
> >>
> >> -config CROSS_MEMORY_ATTACH
> >> -     bool "Cross Memory Support"
> >> -     depends on MMU
> >> -     default y
> >> -     help
> >> -       Enabling this option adds the system calls process_vm_readv and
> >> -       process_vm_writev which allow a process with the correct privileges
> >> -       to directly read from or write to to another process's address space.
> >> -       See the man page for more details.
> >> -
> >>  #
> >>  # UP and nommu archs use km based percpu allocator
> >>  #

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
