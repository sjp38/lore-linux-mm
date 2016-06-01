Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFC276B025E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 06:48:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o70so7651192lfg.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 03:48:22 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ri9si56256974wjb.209.2016.06.01.03.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 03:48:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e3so5537022wme.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 03:48:21 -0700 (PDT)
Date: Wed, 1 Jun 2016 12:48:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
Message-ID: <20160601104819.GL26601@dhcp22.suse.cz>
References: <1464613556-16708-2-git-send-email-mhocko@kernel.org>
 <20160530174324.GA25382@redhat.com>
 <20160531073227.GA26128@dhcp22.suse.cz>
 <20160531225303.GE26582@redhat.com>
 <20160601065339.GA26601@dhcp22.suse.cz>
 <201606011941.DJJ09369.FSFtQVMLFOJOOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606011941.DJJ09369.FSFtQVMLFOJOOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: oleg@redhat.com, linux-mm@kvack.org, rientjes@google.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 01-06-16 19:41:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 01-06-16 00:53:03, Oleg Nesterov wrote:
> > > On 05/31, Michal Hocko wrote:
> > > >
> > > > Oleg has pointed out that can simplify both oom_adj_write and
> > > > oom_score_adj_write even further and drop the sighand lock. The only
> > > > purpose of the lock was to protect p->signal from going away but this
> > > > will not happen since ea6d290ca34c ("signals: make task_struct->signal
> > > > immutable/refcountable").
> > > 
> > > Sorry for confusion, I meant oom_adj_read() and oom_score_adj_read().
> > > 
> > > As for oom_adj_write/oom_score_adj_write we can remove it too, but then
> > > we need to ensure (say, using cmpxchg) that unpriviliged user can not
> > > not decrease signal->oom_score_adj_min if its oom_score_adj_write()
> > > races with someone else (say, admin) which tries to increase the same
> > > oom_score_adj_min.
> > 
> > I am introducing oom_adj_mutex in a later patch so I will move it here.
> 
> Can't we reuse oom_lock like
> 
> 	if (mutex_lock_killable(&oom_lock))
> 		return -EINTR;
> 
> ? I think that updating oom_score_adj unlikely races with OOM killer
> invocation, and updating oom_score_adj should be a killable operation.

We could but what would be an advantage? Do we really need a full oom
exclusion?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
