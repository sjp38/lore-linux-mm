Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B46D06B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:20:27 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 61-v6so396542plz.20
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 22:20:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2-v6sor160684plo.22.2018.04.17.22.20.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 22:20:26 -0700 (PDT)
Date: Tue, 17 Apr 2018 22:20:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper
 unmap
In-Reply-To: <201804180447.w3I4lq60017956@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1804172204420.123546@chino.kir.corp.google.com>
References: <201804180355.w3I3tM6T001187@www262.sakura.ne.jp> <alpine.DEB.2.21.1804172103050.113086@chino.kir.corp.google.com> <201804180447.w3I4lq60017956@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 Apr 2018, Tetsuo Handa wrote:

> > Commit 97b1255cb27c is referencing MMF_OOM_SKIP already being set by 
> > exit_mmap().  The only thing this patch changes is where that is done: 
> > before or after free_pgtables().  We can certainly move it to before 
> > free_pgtables() at the risk of subsequent (and eventually unnecessary) oom 
> > kills.  It's not exactly the point of this patch.
> > 
> > I have thousands of real-world examples where additional processes were 
> > oom killed while the original victim was in free_pgtables().  That's why 
> > we've moved the MMF_OOM_SKIP to after free_pgtables().
> 
> "we have moved"? No, not yet. Your patch is about to move it.
> 

I'm referring to our own kernel, we have thousands of real-world examples 
where additional processes have been oom killed where the original victim 
is in free_pgtables().  It actually happens about 10-15% of the time in 
automated testing where you create a 128MB memcg, fork a canary, and then 
fork a >128MB memory hog.  10-15% of the time both processes get oom 
killed: the memory hog first (higher rss), the canary second.  The pgtable 
stat is unchanged between oom kills.

> My question is: is it guaranteed that munlock_vma_pages_all()/unmap_vmas()/free_pgtables()
> by exit_mmap() are never blocked for memory allocation. Note that exit_mmap() tries to unmap
> all pages while the OOM reaper tries to unmap only safe pages. If there is possibility that
> munlock_vma_pages_all()/unmap_vmas()/free_pgtables() by exit_mmap() are blocked for memory
> allocation, your patch will introduce an OOM livelock.
> 

If munlock_vma_pages_all(), unmap_vmas(), or free_pgtables() require 
memory to make forward progress, then we have bigger problems :)

I just ran a query of real-world oom kill logs that I have.  In 33,773,705 
oom kills, I have no evidence of a thread failing to exit after reaching 
exit_mmap().

You may recall from my support of your patch to emit the stack trace when 
the oom reaper fails, in https://marc.info/?l=linux-mm&m=152157881518627, 
that I have logs of 28,222,058 occurrences of the oom reaper where it 
successfully frees memory and the victim exits.

If you'd like to pursue the possibility that exit_mmap() blocks before 
freeing memory that we have somehow been lucky to miss in 33 million 
occurrences, I'd appreciate the test case.
