Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 158586B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 21:32:55 -0400 (EDT)
Received: by pdea3 with SMTP id a3so86532580pde.3
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 18:32:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ze3si13987171pbc.209.2015.04.03.18.32.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 18:32:53 -0700 (PDT)
Date: Fri, 3 Apr 2015 18:35:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory: print also a_ops->readpage in print_bad_pte
Message-Id: <20150403183540.0ed5def0.akpm@linux-foundation.org>
In-Reply-To: <CALYGNiNNz7HJHY4EU0+5V2+L0+Mz02SqRx7pyX0g_1rSk8L3Uw@mail.gmail.com>
References: <20150403171818.22742.92919.stgit@buzz>
	<20150403151000.b51caa3f692358610fc1ca5d@linux-foundation.org>
	<CALYGNiNNz7HJHY4EU0+5V2+L0+Mz02SqRx7pyX0g_1rSk8L3Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, 4 Apr 2015 03:47:12 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> On Sat, Apr 4, 2015 at 1:10 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Fri, 03 Apr 2015 20:18:18 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> >
> >> A lot of filesystems use generic_file_mmap() and filemap_fault(),
> >> f_op->mmap and vm_ops->fault aren't enough to identify filesystem.
> >>
> >> This prints file name, vm_ops->fault, f_op->mmap and a_ops->readpage
> >> (which is almost always implemented and filesystem-specific).
> >>
> >> Example:
> >>
> >> [   23.676410] BUG: Bad page map in process sh  pte:1b7e6025 pmd:19bbd067
> >> [   23.676887] page:ffffea00006df980 count:4 mapcount:1 mapping:ffff8800196426c0 index:0x97
> >> [   23.677481] flags: 0x10000000000000c(referenced|uptodate)
> >> [   23.677896] page dumped because: bad pte
> >> [   23.678205] addr:00007f52fcb17000 vm_flags:00000075 anon_vma:          (null) mapping:ffff8800196426c0 index:97
> >> [   23.678922] file:libc-2.19.so fault:filemap_fault mmap:generic_file_readonly_mmap readpage:v9fs_vfs_readpage
> >
> > Is that why we print these out?  Just to identify the fs type?
> >
> > There's always vma->vm_file->f_inode->i_sb->s_magic ;)
> 
> Yes, but that also might be anon inode/file mapped by some driver, so
> s_magic isn't enough.

Well, we could ensure that every file_system_type has a valid ->name.
Do an audit, put a debug check in register_filesystem()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
