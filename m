Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05FE06B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 00:11:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id ay8-v6so317892plb.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 21:11:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a64-v6sor132220pla.2.2018.04.17.21.11.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 21:11:37 -0700 (PDT)
Date: Tue, 17 Apr 2018 21:11:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper
 unmap
In-Reply-To: <201804180355.w3I3tM6T001187@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1804172103050.113086@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com> <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com> <201804180355.w3I3tM6T001187@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 Apr 2018, Tetsuo Handa wrote:

> > Fix this by reusing MMF_UNSTABLE to specify that an mm should not be
> > reaped.  This prevents the concurrent munlock_vma_pages_range() and
> > unmap_page_range().  The oom reaper will simply not operate on an mm that
> > has the bit set and leave the unmapping to exit_mmap().
> 
> This change assumes that munlock_vma_pages_all()/unmap_vmas()/free_pgtables()
> are never blocked for memory allocation. Is that guaranteed? For example,
> i_mmap_lock_write() from unmap_single_vma() from unmap_vmas() is never blocked
> for memory allocation? Commit 97b1255cb27c551d ("mm,oom_reaper: check for
> MMF_OOM_SKIP before complaining") was waiting for i_mmap_lock_write() from
> unlink_file_vma() from free_pgtables(). Is it really guaranteed that somebody
> else who is holding that lock is never waiting for memory allocation?
> 

Commit 97b1255cb27c is referencing MMF_OOM_SKIP already being set by 
exit_mmap().  The only thing this patch changes is where that is done: 
before or after free_pgtables().  We can certainly move it to before 
free_pgtables() at the risk of subsequent (and eventually unnecessary) oom 
kills.  It's not exactly the point of this patch.

I have thousands of real-world examples where additional processes were 
oom killed while the original victim was in free_pgtables().  That's why 
we've moved the MMF_OOM_SKIP to after free_pgtables().  I'm not sure how 
likely your scenario is in the real world, but if it poses a problem then 
I believe it should be fixed by eventually deferring previous victims as a 
change to oom_evaluate_task(), not exit_mmap().  If you'd like me to fix 
that, please send along your test case that triggers it and I will send a 
patch.
