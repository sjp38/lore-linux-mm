Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 421486B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:44:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d9-v6so1717210plj.4
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:44:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y6si1776001pgo.9.2018.04.18.14.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 14:44:03 -0700 (PDT)
Date: Wed, 18 Apr 2018 14:44:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-Id: <20180418144401.7c9311079914803c9076d209@linux-foundation.org>
In-Reply-To: <201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
	<201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, mhocko@suse.com, riel@redhat.com

On Sat, 7 Apr 2018 19:38:28 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> >From 31c863e57a4ab7dfb491b2860fe3653e1e8f593b Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 7 Apr 2018 19:29:30 +0900
> Subject: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
> 
> As a theoretical problem, an mm_struct with 60000+ vmas can loop with
> potentially allocating memory, with mm->mmap_sem held for write by current
> thread. This is bad if current thread was selected as an OOM victim, for
> current thread will continue allocations using memory reserves while OOM
> reaper is unable to reclaim memory.
> 
> As an actually observable problem, it is not difficult to make OOM reaper
> unable to reclaim memory if the OOM victim is blocked at
> i_mmap_lock_write() in this loop. Unfortunately, since nobody can explain
> whether it is safe to use killable wait there, let's check for SIGKILL
> before trying to allocate memory. Even without an OOM event, there is no
> point with continuing the loop from the beginning if current thread is
> killed.
> 
> ...
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -441,6 +441,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  			continue;
>  		}
>  		charge = 0;
> +		if (fatal_signal_pending(current)) {
> +			retval = -EINTR;
> +			goto out;
> +		}
>  		if (mpnt->vm_flags & VM_ACCOUNT) {
>  			unsigned long len = vma_pages(mpnt);

Seems sane.  Has this been runtime tested?

I would like to see a comment here explaining why we're testing for
this at this particualr place.
