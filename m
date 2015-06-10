Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D12E6B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 11:56:50 -0400 (EDT)
Received: by wigg3 with SMTP id g3so53296032wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 08:56:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dw6si10570698wib.88.2015.06.10.08.56.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 08:56:49 -0700 (PDT)
Date: Wed, 10 Jun 2015 17:56:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] panic_on_oom_timeout
Message-ID: <20150610155646.GE4501@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
 <20150610142801.GD4501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610142801.GD4501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 10-06-15 16:28:01, Michal Hocko wrote:
> On Wed 10-06-15 21:20:58, Tetsuo Handa wrote:
[...]
> > Since my version uses per a "struct task_struct" variable (memdie_start),
> > 5 seconds of timeout is checked for individual memory cgroup. It can avoid
> > unnecessary panic() calls if nobody needs to call out_of_memory() again
> > (probably because somebody volunteered memory) when the OOM victim cannot
> > be terminated for some reason. If we want distinction between "the entire
> > system is under OOM" and "some memory cgroup is under OOM" because the
> > former is urgent but the latter is less urgent, it can be modified to
> > allow different timeout period for system-wide OOM and cgroup OOM.
> > Finally, it can give a hint for "in what sequence threads got stuck" and
> > "which thread did take 5 seconds" when analyzing vmcore.
> 
> I will have a look how you have implemented that but separate timeouts
> sound like a major over engineering. Also note that global vs. memcg OOM
> is not sufficient because there are other oom domains as mentioned above.

Your patch is doing way too many things at once :/ So let me just focus
on the "panic if a task is stuck with TIF_MEMDIE for too long". It looks
like an alternative to the approach I've chosen. It doesn't consider
the allocation restriction so a locked up cpuset/numa node(s) might
panic the system which doesn't sound like a good idea but that is easily
fixable. Could you tear just this part out and repost it so that we can
compare the two approaches?

The panic_on_oom=2 would be still weird because some nodes might stay in
OOM condition without triggering the panic but maybe this is acceptable.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
