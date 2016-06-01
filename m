Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E90136B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 06:41:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so11440834pfb.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 03:41:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id wl5si19303128pab.81.2016.06.01.03.41.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 03:41:18 -0700 (PDT)
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-2-git-send-email-mhocko@kernel.org>
	<20160530174324.GA25382@redhat.com>
	<20160531073227.GA26128@dhcp22.suse.cz>
	<20160531225303.GE26582@redhat.com>
	<20160601065339.GA26601@dhcp22.suse.cz>
In-Reply-To: <20160601065339.GA26601@dhcp22.suse.cz>
Message-Id: <201606011941.DJJ09369.FSFtQVMLFOJOOH@I-love.SAKURA.ne.jp>
Date: Wed, 1 Jun 2016 19:41:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, oleg@redhat.com
Cc: linux-mm@kvack.org, rientjes@google.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 01-06-16 00:53:03, Oleg Nesterov wrote:
> > On 05/31, Michal Hocko wrote:
> > >
> > > Oleg has pointed out that can simplify both oom_adj_write and
> > > oom_score_adj_write even further and drop the sighand lock. The only
> > > purpose of the lock was to protect p->signal from going away but this
> > > will not happen since ea6d290ca34c ("signals: make task_struct->signal
> > > immutable/refcountable").
> > 
> > Sorry for confusion, I meant oom_adj_read() and oom_score_adj_read().
> > 
> > As for oom_adj_write/oom_score_adj_write we can remove it too, but then
> > we need to ensure (say, using cmpxchg) that unpriviliged user can not
> > not decrease signal->oom_score_adj_min if its oom_score_adj_write()
> > races with someone else (say, admin) which tries to increase the same
> > oom_score_adj_min.
> 
> I am introducing oom_adj_mutex in a later patch so I will move it here.

Can't we reuse oom_lock like

	if (mutex_lock_killable(&oom_lock))
		return -EINTR;

? I think that updating oom_score_adj unlikely races with OOM killer
invocation, and updating oom_score_adj should be a killable operation.

> 
> > If you think this is not a problem - I am fine with this change. But
> > please also update oom_adj_read/oom_score_adj_read ;)
> 
> will do. It stayed in the blind spot... Thanks for pointing that out
> 
> Thanks!
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
