Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AABC6B028A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 14:34:40 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so82002047pac.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 11:34:40 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id jg9si10636242pac.170.2015.10.01.11.34.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 11:34:39 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so81904474pad.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 11:34:39 -0700 (PDT)
Date: Thu, 1 Oct 2015 11:34:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm: fix the racy mm->locked_vm change in
In-Reply-To: <20151001144951.GA6781@redhat.com>
Message-ID: <alpine.LSU.2.11.1510011109390.6920@eggly.anvils>
References: <20150929182756.GA21740@redhat.com> <alpine.LSU.2.11.1509301911320.4528@eggly.anvils> <20151001144951.GA6781@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 Oct 2015, Oleg Nesterov wrote:
> On 09/30, Hugh Dickins wrote:
> >
> > On Tue, 29 Sep 2015, Oleg Nesterov wrote:
> >
> > > "mm->locked_vm += grow" and vm_stat_account() in acct_stack_growth()
> > > are not safe; multiple threads using the same ->mm can do this at the
> > > same time trying to expans different vma's under down_read(mmap_sem).
> >                       expand
> > > This means that one of the "locked_vm += grow" changes can be lost
> > > and we can miss munlock_vma_pages_all() later.
> >
> > From the Cc list, I guess you are thinking this might be the fix to
> > the "Bad state page (mlocked)" issues Andrey and Sasha have reported.
> 
> Yes, I found this when I tried to explain this problem, but I doubt
> this change can fix it... Firstly I think it is very unlikely that
> trinity hits this race. And even if mm->locked_vm is wrongly equal
> to zero in exit_mmap(), it seems that page_remove_rmap() should do
> clear_page_mlock().

Oh yes, good point, a subsequent clear_page_mlock(), in unmapping
this address space, or later unmapping from another, ought to clear
it before the page ever gets freed.

> But I do not understand this code enough. So if
> this patch can actually help I would really like to know why ;)

I doubt any of us understand it very well, mlock+munlock have
over the years become so much more grotesque than the uninitiated
would expect.

> 
> And of course this can not explain other traces which look like
> mm->mmap corruption.
> 
> > Acked-by: Hugh Dickins <hughd@google.com>
> 
> Thanks!
> 
> > with some hesitation.  I don't like very much that the preliminary
> > mm->locked_vm + grow check is still done without complete locking,
> > so racing threads could get more locked_vm than they're permitted;
> > but I'm not sure that we care enough to put page_table_lock back
> > over all of that (and security_vm_enough_memory wants to have final
> > say on whether to go ahead); even if it was that way years ago.
> 
> Yes. Plus all these RLIMIT_MEMLOCK/etc and security_* checks assume
> that we are going to expand current->mm, but this is not necessarily
> true. Debugger or sys_process_vm_* can expand a foreign vma.

Right, I'd forgotten all about that aspect: yes, none of us ever took
expand_stack()'s "current" assumptions seriously enough to rework its
interface with all the architectures, so that's another argument for
sticking for now with the patch you already have here - thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
