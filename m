Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1346B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 09:37:24 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so34028195wiv.2
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 06:37:23 -0800 (PST)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id yn4si29362440wjc.16.2015.02.17.06.37.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 06:37:22 -0800 (PST)
Received: by mail-wi0-f172.google.com with SMTP id l15so33685887wiw.5
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 06:37:22 -0800 (PST)
Date: Tue, 17 Feb 2015 15:37:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217143720.GB32017@dhcp22.suse.cz>
References: <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

On Mon 09-02-15 20:44:16, Tetsuo Handa wrote:
> Hello.
> 
> Today I tested Linux 3.19 and noticed unexpected behavior (A) (B)
> shown below.
> 
> (A) The order-0 __GFP_WAIT allocation fails immediately upon OOM condition
>     despite we didn't remove the
> 
>         /*
>          * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
>          * means __GFP_NOFAIL, but that may not be true in other
>          * implementations.
>          */
>         if (order <= PAGE_ALLOC_COSTLY_ORDER)
>                 return 1;
>
>     check in should_alloc_retry(). Is this what you expected?

The code before 9879de7373fc (mm: page_alloc: embed OOM killing
naturally into allocation slowpath) was looping on this kind of
allocation even though GFP_NOFS didn't trigger OOM killer. This change
was not intentional I guess but it makes sense on its own. We shouldn't
simply loop in a hope that something happens and we finally make a
progress.

Failing __GFP_WAIT allocation is perfectly fine IMO. Why do you think
this is a problem?

Btw. this has nothing to do with TIF_MEMDIE and it would be much better
to discuss it in a separate thread...

> (B) When coredump to pipe is configured, the system stalls under OOM
>     condition due to memory allocation by coredump's reader side.
>     How should we handle this "expected to terminate shortly but unable
>     to terminate due to invisible dependency" case? What approaches
>     other than applying timeout on coredump's writer side are possible?
>     (Running inside memory cgroup is not an answer which I want.)

This is really nasty and we have discussed that with Oleg some time
ago.  We have SIGNAL_GROUP_COREDUMP which prevents the OOM killer
from selecting the task. The issue seems to be that OOM killer might
inherently race with setting the flag.  I have no idea what to do about
this, unfortunately.
Oleg?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
