Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB696B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 06:23:21 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so56495488pdb.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 03:23:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id yr1si2883204pbc.78.2015.04.30.03.23.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 03:23:20 -0700 (PDT)
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
	<20150429125506.GB7148@cmpxchg.org>
	<20150429144031.GB31341@dhcp22.suse.cz>
	<201504300227.JCJ81217.FHOLSQVOFFJtMO@I-love.SAKURA.ne.jp>
	<20150429183135.GH31341@dhcp22.suse.cz>
In-Reply-To: <20150429183135.GH31341@dhcp22.suse.cz>
Message-Id: <201504301844.CFE13027.FOMtJHQOFSOFVL@I-love.SAKURA.ne.jp>
Date: Thu, 30 Apr 2015 18:44:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, david@fromorbit.com
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, aarcange@redhat.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I mean we should eventually fail all the allocation types but GFP_NOFS
> is coming from _carefully_ handled code paths which is an easier starting
> point than a random code path in the kernel/drivers. So can we finally
> move at least in this direction?

I agree that all the allocation types can fail unless GFP_NOFAIL is given.
But I also expect that all the allocation types should not fail unless
order > PAGE_ALLOC_COSTLY_ORDER or GFP_NORETRY is given or chosen as an OOM
victim.

We already experienced at Linux 3.19 what happens if !__GFP_FS allocations
fails. out_of_memory() is called by pagefault_out_of_memory() when 0x2015a
(!__GFP_FS) allocation failed. This looks to me that !__GFP_FS allocations
are effectively OOM killer context. It is not fair to kill the thread which
triggered a page fault, for that thread may not be using so much memory
(unfair from memory usage point of view) or that thread may be global init
(unfair because killing the entire system than survive by killing somebody).
Also, failing the GFP_NOFS/GFP_NOIO allocations which are not triggered by
a page fault generally causes more damage (e.g. taking filesystem error
action) than survive by killing somebody. Therefore, I think we should not
hesitate invoking the OOM killer for !__GFP_FS allocation.

> > Likewise, there is possibility that such memory reserve is used by threads
> > which the OOM victim is not waiting for, for malloc() + memset() causes
> > __GFP_FS allocations.
> 
> We cannot be certain without complete dependency tracking. This is
> just a heuristic.

Yes, we cannot be certain without complete dependency tracking. And doing
complete dependency tracking is too expensive to implement. Dave is
recommending that we should focus on not to trigger the OOM killer than
how to handle corner cases in OOM conditions, isn't he? I still believe that
choosing more OOM victims upon timeout (which is a heuristic after all) and
invoking the OOM killer for !__GFP_FS allocations are the cheapest and least
surprising. This is something like automatically and periodically pressing
SysRq-f on behalf of the system administrator when memory allocator cannot
recover from low memory situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
