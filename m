Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5B682F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 06:18:23 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so7335304wic.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 03:18:22 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id p3si8026185wjb.37.2015.10.30.03.18.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 03:18:22 -0700 (PDT)
Received: by wmeg8 with SMTP id g8so8093263wme.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 03:18:21 -0700 (PDT)
Date: Fri, 30 Oct 2015 11:18:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151030101819.GI18429@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
 <5632FEEF.2050709@jp.fujitsu.com>
 <20151030082323.GB18429@dhcp22.suse.cz>
 <56333B4A.4030602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56333B4A.4030602@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-10-15 18:41:30, KAMEZAWA Hiroyuki wrote:
[...]
> >>So, now, 0-order page allocation may fail in a OOM situation ?
> >
> >No they don't normally and this patch doesn't change the logic here.
> >
> 
> I understand your patch doesn't change the behavior.
> Looking into __alloc_pages_may_oom(), *did_some_progress is finally set by
> 
>      if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
>                 *did_some_progress = 1;
> 
> ...depends on out_of_memory() return value.
> Now, allocation may fail if oom-killer is disabled.... Isn't it complicated ?

Yes and there shouldn't be any allocations after OOM killer has been
disabled. The userspace is already frozen and there shouldn't be any
other memory activity.
 
> Shouldn't we have
> 
>  if (order < PAGE_ALLOC_COSTLY_ORDER)
>     goto retry;
> 
> here ?

How could we move on during the suspend if the reclaim doesn't proceed
and we cannot really kill anything to free up memory resources. We are
simply past the moment any userspace can be woken up. Anyway this is
tangent to this particular patch series.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
