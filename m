Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43A1683292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 07:01:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n18so2740666wra.11
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:01:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o19si2879780wro.99.2017.06.15.04.01.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 04:01:21 -0700 (PDT)
Date: Thu, 15 Jun 2017 13:01:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170615110119.GI1486@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
 <20170615103909.GG1486@dhcp22.suse.cz>
 <201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-06-17 19:53:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 14-06-17 16:43:03, David Rientjes wrote:
> > > If mm->mm_users is not incremented because it is already zero by the oom
> > > reaper, meaning the final refcount has been dropped, do not set
> > > MMF_OOM_SKIP prematurely.
> > > 
> > > __mmput() may not have had a chance to do exit_mmap() yet, so memory from
> > > a previous oom victim is still mapped.
> > 
> > true and do we have a _guarantee_ it will do it? E.g. can somebody block
> > exit_aio from completing? Or can somebody hold mmap_sem and thus block
> > ksm_exit resp. khugepaged_exit from completing? The reason why I was
> > conservative and set such a mm as MMF_OOM_SKIP was because I couldn't
> > give a definitive answer to those questions. And we really _want_ to
> > have a guarantee of a forward progress here. Killing an additional
> > proecess is a price to pay and if that doesn't trigger normall it sounds
> > like a reasonable compromise to me.
> 
> Right. If you want this patch, __oom_reap_task_mm() must not return true without
> setting MMF_OOM_SKIP (in other words, return false if __oom_reap_task_mm()
> does not set MMF_OOM_SKIP). The most important role of the OOM reaper is to
> guarantee that the OOM killer is re-enabled within finite time, for __mmput()
> cannot guarantee that MMF_OOM_SKIP is set within finite time.

An alternative would be to allow reaping and exit_mmap race. The unmap
part should just work I guess. We just have to be careful to not race
with free_pgtables and that shouldn't be too hard to implement (e.g.
(ab)use mmap_sem for write there). I haven't thought that through
completely though so I might miss something of course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
