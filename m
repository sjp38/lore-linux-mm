Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6F1C8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 04:17:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g15-v6so534318edm.11
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 01:17:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15-v6si583174edc.338.2018.09.12.01.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 01:17:34 -0700 (PDT)
Date: Wed, 12 Sep 2018 10:17:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180912081733.GA10951@dhcp22.suse.cz>
References: <201809120306.w8C36JbS080965@www262.sakura.ne.jp>
 <20180912071842.GY10951@dhcp22.suse.cz>
 <201809120758.w8C7wrCN068547@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201809120758.w8C7wrCN068547@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 12-09-18 16:58:53, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > OK, I will fold the following to the patch
> 
> OK. But at that point, my patch which tries to wait for reclaimed memory
> to be re-allocatable addresses a different problem which you are refusing.

I am trying to address a real world example of when the excessive amount
of memory is in page tables. As David pointed, this can happen with some
userspace allocators.

> By the way, is it guaranteed that vma->vm_ops->close(vma) in remove_vma() never
> sleeps? Since remove_vma() has might_sleep() since 2005, and that might_sleep()
> predates the git history, I don't know what that ->close() would do.

Hmm, I am afraid we cannot assume anything so we have to consider it
unsafe. A cursory look at some callers shows that they are taking locks.
E.g. drm_gem_object_put_unlocked might take a mutex. So MMF_OOM_SKIP
would have to set right after releasing page tables.

> Anyway, please fix free_pgd_range() crash in this patchset.

I will try to get to this later today.
-- 
Michal Hocko
SUSE Labs
