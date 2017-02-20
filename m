Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8076B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 10:53:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so10742895wmt.7
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 07:53:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si12803165wma.41.2017.02.20.07.53.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 07:53:54 -0800 (PST)
Date: Mon, 20 Feb 2017 16:53:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: switch to struct list_head for reap queue
Message-ID: <20170220155350.GL2431@dhcp22.suse.cz>
References: <20170214150714.6195-1-asarai@suse.de>
 <20170214163005.GA2450@cmpxchg.org>
 <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
 <20170214173717.GA8913@redhat.com>
 <a35d6271-f9b3-834c-79da-30d522ec4813@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a35d6271-f9b3-834c-79da-30d522ec4813@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aleksa Sarai <asarai@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com

On Wed 15-02-17 20:01:33, Aleksa Sarai wrote:
> > > > This is an extra pointer to task_struct and more lines of code to
> > > > accomplish the same thing. Why would we want to do that?
> > > 
> > > I don't think it's more "actual" lines of code (I think the wrapping is
> > > inflating the line number count),
> > 
> > I too think it doesn't make sense to blow task_struct and the generated code.
> > And to me this patch doesn't make the source code more clean.
> > 
> > > but switching it means that it's more in
> > > line with other queues in the kernel (it took me a bit to figure out what
> > > was going on with oom_reaper_list beforehand).
> > 
> > perhaps you can turn oom_reaper_list into llist_head then. This will also
> > allow to remove oom_reaper_lock. Not sure this makes sense too.
> 
> Actually, I just noticed that the original implementation is a stack not a
> queue. So the reaper will always reap the *most recent* task to get OOMed as
> opposed to the least recent. Since select_bad_process() will always pick
> worse processes first, this means that the reaper will reap "less bad"
> processes (lower oom score) before it reaps worse ones (higher oom score).
> 
> While it's not a /huge/ deal (N is going to be small in most OOM cases), is
> this something that we should consider?

Not really. Because the oom killer will back off if there is an oom
victim in the same oom domain currently selected (see
oom_evaluate_task). So more oom tasks queued for the oom reaper will
usually happen when we have parallel OOM in different oom domains
(cpusets/node_masks, memcgs) and then it really doesn't matter which one
we choose first.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
