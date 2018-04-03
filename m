Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA066B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:32:45 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g204-v6so584755oic.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:32:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v10-v6si753487oif.337.2018.04.03.04.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 04:32:44 -0700 (PDT)
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
	<20180403111640.GN5501@dhcp22.suse.cz>
In-Reply-To: <20180403111640.GN5501@dhcp22.suse.cz>
Message-Id: <201804032032.GHF09826.MLOQFtSOFHJOFV@I-love.SAKURA.ne.jp>
Date: Tue, 3 Apr 2018 20:32:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, riel@redhat.com

Michal Hocko wrote:
> On Thu 29-03-18 14:30:03, Andrew Morton wrote:
> [...]
> > Dumb question: if a thread has been oom-killed and then tries to
> > allocate memory, should the page allocator just fail the allocation
> > attempt?  I suppose there are all sorts of reasons why not :(
> 
> We give those tasks access to memory reserves to move on (see
> oom_reserves_allowed) and fail allocation if reserves do not help
> 
> 	if (tsk_is_oom_victim(current) &&
> 	    (alloc_flags == ALLOC_OOM ||
> 	     (gfp_mask & __GFP_NOMEMALLOC)))
> 		goto nopage;
> So we...
> 
> > In which case, yes, setting a new
> > PF_MEMALLOC_MAY_FAIL_IF_I_WAS_OOMKILLED around such code might be a
> > tidy enough solution.  It would be a bit sad to add another test in the
> > hot path (should_fail_alloc_page()?), but geeze we do a lot of junk
> > already.
> 
> ... do not need this.

Excuse me? But that check is after

	/* Reclaim has failed us, start killing things */
	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
	if (page)
		goto got_pg;

which means that tsk_is_oom_victim(current) && alloc_flags == ALLOC_OOM threads
can still trigger the OOM killer as soon as the OOM reaper sets MMF_OOM_SKIP.
