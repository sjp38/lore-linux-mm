Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6BD86B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 21:55:25 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id d5-v6so2211427oth.2
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 18:55:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 48-v6si840116ote.351.2018.04.18.18.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 18:55:23 -0700 (PDT)
Message-Id: <201804190154.w3J1sieH011800@www262.sakura.ne.jp>
Subject: Re: [PATCH] mm: Check for SIGKILL inside =?ISO-2022-JP?B?ZHVwX21tYXAoKSBs?=
 =?ISO-2022-JP?B?b29wLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 19 Apr 2018 10:54:44 +0900
References: <201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp> <20180418144401.7c9311079914803c9076d209@linux-foundation.org>
In-Reply-To: <20180418144401.7c9311079914803c9076d209@linux-foundation.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, mhocko@suse.com, riel@redhat.com

Andrew Morton wrote:
> On Sat, 7 Apr 2018 19:38:28 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > >From 31c863e57a4ab7dfb491b2860fe3653e1e8f593b Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Sat, 7 Apr 2018 19:29:30 +0900
> > Subject: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
> > 
> > As a theoretical problem, an mm_struct with 60000+ vmas can loop with
> > potentially allocating memory, with mm->mmap_sem held for write by current
> > thread. This is bad if current thread was selected as an OOM victim, for
> > current thread will continue allocations using memory reserves while OOM
> > reaper is unable to reclaim memory.
> > 
> > As an actually observable problem, it is not difficult to make OOM reaper
> > unable to reclaim memory if the OOM victim is blocked at
> > i_mmap_lock_write() in this loop. Unfortunately, since nobody can explain
> > whether it is safe to use killable wait there, let's check for SIGKILL
> > before trying to allocate memory. Even without an OOM event, there is no
> > point with continuing the loop from the beginning if current thread is
> > killed.
> > 
> > ...
> >
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -441,6 +441,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
> >  			continue;
> >  		}
> >  		charge = 0;
> > +		if (fatal_signal_pending(current)) {
> > +			retval = -EINTR;
> > +			goto out;
> > +		}
> >  		if (mpnt->vm_flags & VM_ACCOUNT) {
> >  			unsigned long len = vma_pages(mpnt);
> 
> Seems sane.  Has this been runtime tested?
> 

Yes, I tested with debug printk(). This patch should be safe
because we already fail if security_vm_enough_memory_mm() or
kmem_cache_alloc(GFP_KERNEL) fails and exit_mmap() handles it.

[  417.030691] ***** Aborting dup_mmap() due to SIGKILL *****
[  417.036129] ***** Aborting dup_mmap() due to SIGKILL *****
[  417.044544] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.116445] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.118401] ***** Aborting exit_mmap() due to NULL mmap *****
[  419.168917] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.169064] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.170913] ***** Aborting exit_mmap() due to NULL mmap *****
[  419.171411] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.171417] ***** Aborting exit_mmap() due to NULL mmap *****
[  419.172804] ***** Aborting exit_mmap() due to NULL mmap *****
[  419.176253] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.182676] ***** Aborting exit_mmap() due to NULL mmap *****

> I would like to see a comment here explaining why we're testing for
> this at this particualr place.
> 
Such comment goes to patch description.
