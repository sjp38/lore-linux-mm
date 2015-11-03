Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id A44BB82F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 14:43:30 -0500 (EST)
Received: by ykft191 with SMTP id t191so34363296ykf.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 11:43:30 -0800 (PST)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id v5si12251940ywb.119.2015.11.03.11.43.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 11:43:29 -0800 (PST)
Received: by ykft191 with SMTP id t191so34362540ykf.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 11:43:29 -0800 (PST)
Date: Tue, 3 Nov 2015 14:43:25 -0500
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151103194325.GB5749@mtj.duckdns.org>
References: <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
 <20151023042649.GB18907@mtj.duckdns.org>
 <20151102150137.GB3442@dhcp22.suse.cz>
 <20151102192053.GC9553@mtj.duckdns.org>
 <201511031132.GBB09374.JQFOVSFLOtHFMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511031132.GBB09374.JQFOVSFLOtHFMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello, Tetsuo.

On Tue, Nov 03, 2015 at 11:32:06AM +0900, Tetsuo Handa wrote:
> Tejun Heo wrote:
> >                                                                  If
> > the possibility of sysrq getting stuck behind concurrency management
> > is an issue, queueing them on an unbound or highpri workqueue should
> > be good enough.
> 
> Regarding SysRq-f, we could do like below. Though I think that converting
> the OOM killer into a dedicated kernel thread would allow more things to do
> (e.g. Oleg's memory zapping code, my timeout based next victim selection).

I'm not sure doing anything to sysrq-f is warranted.  If workqueue
can't make forward progress due to memory exhaustion, OOM will be
triggered anyway.  Getting stuck behind concurrency management isn't
that different a failure mode from getting stuck behind busy loop with
preemption off.  We should just plug them at the source.  If
necessary, what we can do is adding stall watchdog (can prolly
combined with the usual watchdog) so that it can better point out the
culprit.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
