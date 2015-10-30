Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 877D182F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 09:32:48 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so43818748obc.3
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 06:32:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x14si4367932oia.57.2015.10.30.06.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Oct 2015 06:32:47 -0700 (PDT)
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
	<1446131835-3263-2-git-send-email-mhocko@kernel.org>
	<00f201d112c8$e2377720$a6a66560$@alibaba-inc.com>
	<20151030083626.GC18429@dhcp22.suse.cz>
	<20151030101436.GH18429@dhcp22.suse.cz>
In-Reply-To: <20151030101436.GH18429@dhcp22.suse.cz>
Message-Id: <201510302232.FCH52626.OQJOFHSVFFOtLM@I-love.SAKURA.ne.jp>
Date: Fri, 30 Oct 2015 22:32:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hillf.zj@alibaba-inc.com, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> +		target -= (stall_backoff * target + MAX_STALL_BACKOFF - 1) / MAX_STALL_BACKOFF;
target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);



Michal Hocko wrote:
> This alone wouldn't be sufficient, though, because the writeback might
> get stuck and reclaimable pages might be pinned for a really long time
> or even depend on the current allocation context.

Is this a dependency which I worried at
http://lkml.kernel.org/r/201510262044.BAI43236.FOMSFFOtOVLJQH@I-love.SAKURA.ne.jp ?

>                                                   Therefore there is a
> feedback mechanism implemented which reduces the reclaim target after
> each reclaim round without any progress.

If yes, this feedback mechanism will help avoiding infinite wait loop.

>                                          This means that we should
> eventually converge to only NR_FREE_PAGES as the target and fail on the
> wmark check and proceed to OOM.

What if all in-flight allocation requests are !__GFP_NOFAIL && !__GFP_FS ?
(In other words, either "no __GFP_FS allocations are in-flight" or "all
__GFP_FS allocations are in-flight but are either waiting for completion
of operations which depend on !__GFP_FS allocations with a lock held or
waiting for that lock to be released".)

Don't we need to call out_of_memory() even though !__GFP_FS allocations?

>                                 The backoff is simple and linear with
> 1/16 of the reclaimable pages for each round without any progress. We
> are optimistic and reset counter for successful reclaim rounds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
