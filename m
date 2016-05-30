Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5C616B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 03:21:18 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so51077430lbo.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 00:21:18 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id y184si29264702wmb.6.2016.05.30.00.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 00:21:17 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so19754118wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 00:21:17 -0700 (PDT)
Date: Mon, 30 May 2016 09:21:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] Handle oom bypass more gracefully
Message-ID: <20160530072116.GF22928@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <20160527160026.GA29337@dhcp22.suse.cz>
 <201605282304.DJC04167.SHLtVQMOOFFOFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605282304.DJC04167.SHLtVQMOOFFOFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Sat 28-05-16 23:04:08, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > JFYI, I plan to repost the series early next week after I review all the
> > pieces again properly with a clean head. If some parts are not sound or
> > completely unacceptable in principle then let me know of course.
> 
> I don't think we can apply this series.
> 
>   [PATCH 1/6] is unreliable and will be dropped.
> 
>   [PATCH 2/6] would be OK as a clean up.
> 
>   [PATCH 3/6] will change user visible part. We deprecated /proc/pid/oom_adj
>   in Aug 2010 (nearly 6 years ago) by commit 51b1bd2ace1595b7 ("oom: deprecate
>   oom_adj tunable") but we still preserve that behavior, don't we? I think
>   [PATCH 3/6] will need 5 to 10 years of get-acquainted period in order to
>   make sure that no end users will depend on current behavior. This is not
>   something we can change now.

I would really like to hear a case where this would break anything.

> 
>   [PATCH 4/6] is unsafe as Vladimir commented.
> 
>   [PATCH 5/6] will also change user visible part. We need get-acquainted period.
>   This is not something we can change now.

Do you care to describe how and who would be affected?

>   [PATCH 6/6] seems to be unsafe as I commented on a different thread
>   ( http://lkml.kernel.org/r/201605282122.HAD09894.SFOFHtOVJLOQMF@I-love.SAKURA.ne.jp ).

I already have fixes for those.

> You are trying to make the OOM killer as per mm_struct operation. But
> I think we need to tolerate the OOM killer as per signal_struct operation.

Signal struct based approach is full of weird behavior which just leads
to corner cases. I think going mm struct way is the only sensible
approach. So far, the only road block seems to be a question whether
changing oom_score_adj for processes out of thread group is acceptable.
I argue that it should be because this is what we effectively do we just
to not express that to the userspace. Well. except for OOM_SCORE_ADJ_MIN
which we might handle specially in some way. So let's argue about
potential drawback of the user visible behavior change has, who might be
affected and how rather than blocking a sensible approach.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
