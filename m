Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 01F0582F7A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 10:53:05 -0400 (EDT)
Received: by qgt47 with SMTP id 47so68833317qgt.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 07:53:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g192si5900697qhc.93.2015.10.01.07.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 07:53:04 -0700 (PDT)
Date: Thu, 1 Oct 2015 16:49:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/2] mm: fix the racy mm->locked_vm change in
Message-ID: <20151001144951.GA6781@redhat.com>
References: <20150929182756.GA21740@redhat.com> <alpine.LSU.2.11.1509301911320.4528@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1509301911320.4528@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/30, Hugh Dickins wrote:
>
> On Tue, 29 Sep 2015, Oleg Nesterov wrote:
>
> > "mm->locked_vm += grow" and vm_stat_account() in acct_stack_growth()
> > are not safe; multiple threads using the same ->mm can do this at the
> > same time trying to expans different vma's under down_read(mmap_sem).
>                       expand
> > This means that one of the "locked_vm += grow" changes can be lost
> > and we can miss munlock_vma_pages_all() later.
>
> From the Cc list, I guess you are thinking this might be the fix to
> the "Bad state page (mlocked)" issues Andrey and Sasha have reported.

Yes, I found this when I tried to explain this problem, but I doubt
this change can fix it... Firstly I think it is very unlikely that
trinity hits this race. And even if mm->locked_vm is wrongly equal
to zero in exit_mmap(), it seems that page_remove_rmap() should do
clear_page_mlock(). But I do not understand this code enough. So if
this patch can actually help I would really like to know why ;)

And of course this can not explain other traces which look like
mm->mmap corruption.

> Acked-by: Hugh Dickins <hughd@google.com>

Thanks!

> with some hesitation.  I don't like very much that the preliminary
> mm->locked_vm + grow check is still done without complete locking,
> so racing threads could get more locked_vm than they're permitted;
> but I'm not sure that we care enough to put page_table_lock back
> over all of that (and security_vm_enough_memory wants to have final
> say on whether to go ahead); even if it was that way years ago.

Yes. Plus all these RLIMIT_MEMLOCK/etc and security_* checks assume
that we are going to expand current->mm, but this is not necessarily
true. Debugger or sys_process_vm_* can expand a foreign vma.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
