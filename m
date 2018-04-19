Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE426B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:36:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 47-v6so4055849wru.19
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 23:36:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si2709194edl.279.2018.04.18.23.36.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 23:36:16 -0700 (PDT)
Date: Thu, 19 Apr 2018 08:35:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180419063556.GK17484@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
 <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 18-04-18 12:14:29, David Rientjes wrote:
> On Wed, 18 Apr 2018, Michal Hocko wrote:
> 
> > > Since exit_mmap() is done without the protection of mm->mmap_sem, it is
> > > possible for the oom reaper to concurrently operate on an mm until
> > > MMF_OOM_SKIP is set.
> > > 
> > > This allows munlock_vma_pages_all() to concurrently run while the oom
> > > reaper is operating on a vma.  Since munlock_vma_pages_range() depends on
> > > clearing VM_LOCKED from vm_flags before actually doing the munlock to
> > > determine if any other vmas are locking the same memory, the check for
> > > VM_LOCKED in the oom reaper is racy.
> > > 
> > > This is especially noticeable on architectures such as powerpc where
> > > clearing a huge pmd requires serialize_against_pte_lookup().  If the pmd
> > > is zapped by the oom reaper during follow_page_mask() after the check for
> > > pmd_none() is bypassed, this ends up deferencing a NULL ptl.
> > > 
> > > Fix this by reusing MMF_UNSTABLE to specify that an mm should not be
> > > reaped.  This prevents the concurrent munlock_vma_pages_range() and
> > > unmap_page_range().  The oom reaper will simply not operate on an mm that
> > > has the bit set and leave the unmapping to exit_mmap().
> > 
> > This will further complicate the protocol and actually theoretically
> > restores the oom lockup issues because the oom reaper doesn't set
> > MMF_OOM_SKIP when racing with exit_mmap so we fully rely that nothing
> > blocks there... So the resulting code is more fragile and tricky.
> > 
> 
> exit_mmap() does not block before set_bit(MMF_OOM_SKIP) once it is 
> entered.

Not true. munlock_vma_pages_all might take page_lock which can have
unpredictable dependences. This is the reason why we are ruling out
mlocked VMAs in the first place when reaping the address space.

> > Can we try a simpler way and get back to what I was suggesting before
> > [1] and simply not play tricks with
> > 		down_write(&mm->mmap_sem);
> > 		up_write(&mm->mmap_sem);
> > 
> > and use the write lock in exit_mmap for oom_victims?
> > 
> > Andrea wanted to make this more clever but this is the second fallout
> > which could have been prevented. The patch would be smaller and the
> > locking protocol easier
> > 
> > [1] http://lkml.kernel.org/r/20170727065023.GB20970@dhcp22.suse.cz
> > 
> 
> exit_mmap() doesn't need to protect munlock, unmap, or freeing pgtables 
> with mm->mmap_sem; the issue is that you need to start holding it in this 
> case before munlock and then until at least the end of free_pgtables().  
> Anything in between also needlessly holds it so could introduce weird 
> lockdep issues that only trigger for oom victims, i.e. they could be very 
> rare on some configs.  I don't necessarily like holding a mutex over 
> functions where it's actually not needed, not only as a general principle 
> but also because the oom reaper can now infer that reaping isn't possible 
> just because it can't do down_read() and isn't aware the thread is 
> actually in exit_mmap() needlessly holding it.

While you are correct, strictly speaking, because unmap_vmas can race
with the oom reaper. With the lock held during the whole operation we
can indeed trigger back off in the oom_repaer. It will keep retrying but
the tear down can take quite some time. This is a fair argument. On the
other hand your lock protocol introduces the MMF_OOM_SKIP problem I've
mentioned above and that really worries me. The primary objective of the
reaper is to guarantee a forward progress without relying on any
externalities. We might kill another OOM victim but that is safer than
lock up.

[...]

> The patch is simply using MMF_UNSTABLE rather than MMF_OOM_SKIP to 
> serialize exit_mmap() with the oom reaper and doing it before anything 
> interesting in exit_mmap() because without it the munlock can trivially 
> race with unmap_page_range() and cause a NULL pointer or #GP on a pmd or 
> pte.  The way Andrea implemented it is fine, we simply have revealed a 
> race between munlock_vma_pages_all() and unmap_page_range() that needs it 
> to do set_bit(); down_write(); up_write(); earlier.

The current protocol has proven to be error prone so I really believe we
should back off and turn it into something much simpler and build on top
of that if needed.

So do you see any _technical_ reasons why not do [1] and have a simpler
protocol easily backportable to stable trees?
-- 
Michal Hocko
SUSE Labs
