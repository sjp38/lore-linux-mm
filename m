Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7BE66B000A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:16:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k44so9411077wrc.3
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:16:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21si1965154wma.256.2018.04.03.04.16.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 04:16:41 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:16:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180403111640.GN5501@dhcp22.suse.cz>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>

On Thu 29-03-18 14:30:03, Andrew Morton wrote:
[...]
> Dumb question: if a thread has been oom-killed and then tries to
> allocate memory, should the page allocator just fail the allocation
> attempt?  I suppose there are all sorts of reasons why not :(

We give those tasks access to memory reserves to move on (see
oom_reserves_allowed) and fail allocation if reserves do not help

	if (tsk_is_oom_victim(current) &&
	    (alloc_flags == ALLOC_OOM ||
	     (gfp_mask & __GFP_NOMEMALLOC)))
		goto nopage;
So we...

> In which case, yes, setting a new
> PF_MEMALLOC_MAY_FAIL_IF_I_WAS_OOMKILLED around such code might be a
> tidy enough solution.  It would be a bit sad to add another test in the
> hot path (should_fail_alloc_page()?), but geeze we do a lot of junk
> already.

... do not need this.
-- 
Michal Hocko
SUSE Labs
