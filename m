Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE0B86B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:38:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p18so3524458wmh.2
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:38:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si1889795wrh.152.2018.04.03.04.38.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 04:38:39 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:38:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180403113837.GR5501@dhcp22.suse.cz>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
 <20180403111640.GN5501@dhcp22.suse.cz>
 <201804032032.GHF09826.MLOQFtSOFHJOFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804032032.GHF09826.MLOQFtSOFHJOFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, riel@redhat.com

On Tue 03-04-18 20:32:39, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 29-03-18 14:30:03, Andrew Morton wrote:
> > [...]
> > > Dumb question: if a thread has been oom-killed and then tries to
> > > allocate memory, should the page allocator just fail the allocation
> > > attempt?  I suppose there are all sorts of reasons why not :(
> > 
> > We give those tasks access to memory reserves to move on (see
> > oom_reserves_allowed) and fail allocation if reserves do not help
> > 
> > 	if (tsk_is_oom_victim(current) &&
> > 	    (alloc_flags == ALLOC_OOM ||
> > 	     (gfp_mask & __GFP_NOMEMALLOC)))
> > 		goto nopage;
> > So we...
> > 
> > > In which case, yes, setting a new
> > > PF_MEMALLOC_MAY_FAIL_IF_I_WAS_OOMKILLED around such code might be a
> > > tidy enough solution.  It would be a bit sad to add another test in the
> > > hot path (should_fail_alloc_page()?), but geeze we do a lot of junk
> > > already.
> > 
> > ... do not need this.
> 
> Excuse me? But that check is after
> 
> 	/* Reclaim has failed us, start killing things */
> 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
> 	if (page)
> 		goto got_pg;
> 
> which means that tsk_is_oom_victim(current) && alloc_flags == ALLOC_OOM threads
> can still trigger the OOM killer as soon as the OOM reaper sets MMF_OOM_SKIP.

Races are possible and I do not see them as critical _right now_. If
that turnes out to be not the case we can think of a more robust way.
The thing is that we have "bail out for OOM victims already".

-- 
Michal Hocko
SUSE Labs
