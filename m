Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA3246B0253
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:32:31 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so94547747lbn.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:32:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id kb6si24818178wjb.71.2016.05.31.00.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 00:32:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so29819455wme.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:32:30 -0700 (PDT)
Date: Tue, 31 May 2016 09:32:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
Message-ID: <20160531073227.GA26128@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-2-git-send-email-mhocko@kernel.org>
 <20160530174324.GA25382@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160530174324.GA25382@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-05-16 19:43:24, Oleg Nesterov wrote:
> On 05/30, Michal Hocko wrote:
> >
> > both oom_adj_write and oom_score_adj_write are using task_lock,
> > check for task->mm and fail if it is NULL. This is not needed because
> > the oom_score_adj is per signal struct so we do not need mm at all.
> > The code has been introduced by 3d5992d2ac7d ("oom: add per-mm oom
> > disable count") but we do not do per-mm oom disable since c9f01245b6a7
> > ("oom: remove oom_disable_count").
> >
> > The task->mm check is even not correct because the current thread might
> > have exited but the thread group might be still alive - e.g. thread
> > group leader would lead that echo $VAL > /proc/pid/oom_score_adj would
> > always fail with EINVAL while /proc/pid/task/$other_tid/oom_score_adj
> > would succeed. This is unexpected at best.
> >
> > Remove the lock along with the check to fix the unexpected behavior
> > and also because there is not real need for the lock in the first place.
> 
> ACK

thanks!

> and we should also remove lock_task_sighand(). as for oom_adj_read() and
> oom_score_adj_read() we can just remove it right now; it was previously
> needed to ensure the task->signal != NULL, today this is always true.

OK, I will add the following patch to the series.
---
