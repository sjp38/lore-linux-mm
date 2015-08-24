Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 190146B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:52:27 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so53397748pdb.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:52:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id br3si27221416pbd.231.2015.08.24.05.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:52:26 -0700 (PDT)
Subject: Re: [REPOST] [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and __alloc_pages_high_priority().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508231621.EGJ17658.FFQJtFSLVOOHMO@I-love.SAKURA.ne.jp>
	<20150824100319.GG17078@dhcp22.suse.cz>
In-Reply-To: <20150824100319.GG17078@dhcp22.suse.cz>
Message-Id: <201508242152.HHB69241.OFJLFVtFHQOMSO@I-love.SAKURA.ne.jp>
Date: Mon, 24 Aug 2015 21:52:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> The comment above the check is misleading but now you are allowing to
> fail all ALLOC_NO_WATERMARKS (without __GFP_NOFAIL) allocations before
> entering the direct reclaim and compaction. This seems incorrect. What
> about __GFP_MEMALLOC requests?

So, you want __GPP_MEMALLOC to retry forever unless TIF_MEMDIE is set, don't
you?

> I think the check for TIF_MEMDIE makes more sense here.

Since we already failed to allocate from memory reserves, I don't know if
direct reclaim and compaction can work as expected under such situation.
Maybe the OOM killer is invoked, but I worry that the OOM victim gets stuck
because we already failed to allocate from memory reserves. Unless next OOM
victims are chosen via timeout, I think that this can be one of triggers
that lead to silent hangup... (Just my suspect. I can't prove it because I
can't go to in front of customers' servers and check SysRq.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
