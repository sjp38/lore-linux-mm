Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6218D6B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:16:13 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so125917367wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 03:16:12 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id w17si16134536wij.99.2015.09.14.03.16.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 03:16:12 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so134694864wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 03:16:11 -0700 (PDT)
Date: Mon, 14 Sep 2015 13:16:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150914101609.GA8293@node.dhcp.inet.fi>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
 <55EC9221.4040603@oracle.com>
 <20150907114048.GA5016@node.dhcp.inet.fi>
 <55F0D5B2.2090205@oracle.com>
 <20150910083605.GB9526@node.dhcp.inet.fi>
 <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
 <20150911103959.GA7976@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Fri, Sep 11, 2015 at 06:27:14PM -0700, Hugh Dickins wrote:
> On Fri, 11 Sep 2015, Kirill A. Shutemov wrote:
> > On Thu, Sep 10, 2015 at 03:27:59PM +0200, Andrey Konovalov wrote:
> > > Can a vma be shared among a few mm's?
> > 
> > Define "shared".
> > 
> > vma can belong only to one process (mm_struct), but it can be accessed
> > from other process like in rmap case below.
> > 
> > rmap uses anon_vma_lock for anon vma and i_mmap_rwsem for file vma to make
> > sure that the vma will not disappear under it.
> > 
> > > If yes, then taking current->mm->mmap_sem to protect vma is not enough.
> > 
> > Depends on what protection you are talking about.
> >  
> > > In the first report below both T378 and T398 take
> > > current->mm->mmap_sem at mm/mlock.c:650, but they turn out to be
> > > different locks (the addresses are different).
> > 
> > See i_mmap_lock_read() in T398. It will guarantee that vma is there.
> > 
> > > In the second report T309 doesn't take any locks at all, since it
> > > assumes that after checking atomic_dec_and_test(&mm->mm_users) the mm
> > > has no other users, but then it does a write to vma.
> > 
> > This one is tricky. I *assume* the mm cannot be generally accessible after
> > mm_users drops to zero, but I'm not entirely sure about it.
> > procfs? ptrace?
> 
> Most of the things (including procfs and ptrace) that need to work on
> a foreign mm do take a hold on mm_users with get_task_mm().  swapoff
> uses atomic_inc_not_zero(&mm->mm_users).  In KSM I managed to get away
> with just a hold on the structure itself, atomic_inc(&mm->mm_count),
> and a check for mm_users 0 wherever it down_reads mmap_sem (but Andrey
> might like to turn KSM on: it wouldn't be entirely shocking if he were
> to discover an anomaly from that).
> 
> > 
> > The VMA is still accessible via rmap at this point. And I think it can be
> > a problem:
> > 
> > 		CPU0					CPU1
> > exit_mmap()
> >   // mmap_sem is *not* taken
> >   munlock_vma_pages_all()
> >     munlock_vma_pages_range()
> >     						try_to_unmap_one()
> > 						  down_read_trylock(&vma->vm_mm->mmap_sem))
> > 						  !!(vma->vm_flags & VM_LOCKED) == true
> >       vma->vm_flags &= ~VM_LOCKED;
> >       <munlock the page>
> >       						  mlock_vma_page(page);
> > 						  // mlocked pages is leaked.
> > 
> > The obvious solution is to take mmap_sem in exit path, but it would cause
> > performance regression.
> > 
> > Any comments?
> 
> I'm inclined to echo Vlastimil's comment from earlier in the thread:
> sounds like an overkill, unless we find something more serious than this.
> 
> I'm not sure whether we'd actually see a regression from taking mmap_sem
> in exit path; but given that it's mmap_sem, yes, history tells us please
> not to take it any more than we have to.
> 
> I do remember wishing, when working out KSM's mm handling, that exit took
> mmap_sem: it would have made it simpler, but that wasn't a change I dared
> to make.
> 
> Maybe an mm_users 0 check after down_read_trylock in try_to_unmap_one() 
> could fix it?

I don't see how. It would shift a picture, but doesn't fix it: exit_mmap()
can happen after down_read_trylock() and mm_users check.
We would only hide the problem.

> But if we were to make a bigger change for this VM_LOCKED issue, and
> something more serious makes it worth all the effort, I'd say that
> what needs to be done is to give mlock/munlock proper locking (haha).
> 
> I have not yet looked at your mlocked THP patch (sorry), but when I
> was doing the same thing for huge tmpfs, what made it so surprisingly
> difficult was all the spongy trylocking, which concealed the rules.
> 
> Maybe I'm completely wrong, but I thought a lot of awkwardness might
> disappear if they were relying on anon_vma->rwsem and i_mmap_rwsem
> throughout instead of mmap_sem.

This can be helpful. But the risk is getting scalability regression on
other front: long anon_vma chain or highly shared files.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
