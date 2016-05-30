Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 568EB6B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:52:15 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id j12so52889394lbo.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:52:15 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id e10si29879917wmc.2.2016.05.30.02.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:52:14 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id n129so78423914wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:52:14 -0700 (PDT)
Date: Mon, 30 May 2016 11:52:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip over vforked tasks
Message-ID: <20160530095212.GO22928@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-5-git-send-email-mhocko@kernel.org>
 <20160527164830.GF26059@esperanza>
 <20160530071357.GE22928@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160530071357.GE22928@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-05-16 09:13:57, Michal Hocko wrote:
> On Fri 27-05-16 19:48:30, Vladimir Davydov wrote:
> > On Thu, May 26, 2016 at 02:40:13PM +0200, Michal Hocko wrote:
> [...]
> > > @@ -839,6 +841,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > >  	for_each_process(p) {
> > >  		if (!process_shares_mm(p, mm))
> > >  			continue;
> > > +		/*
> > > +		 * vforked tasks are ignored because they will drop the mm soon
> > > +		 * hopefully and even if not they will not mind being oom
> > > +		 * reaped because they cannot touch any memory.
> > 
> > They shouldn't modify memory, but they still can touch it AFAIK.
> 
> You are right. This means that the vforked child might see zero pages.
> Let me think whether this is acceptable or not.

OK, I was thinking about it some more and I think you have a good point
here. I can see two options here:
- keep vforked task alive and skip the oom reaper. If the victim exits
  normally and the oom wouldn't get resolved the vforked task will be
  selected in the next round because the victim would clean up
  vfork_done state in  wait_for_vfork_done. We are still risking that
  the victim gets stuck though
- kill vforked task and so it would be reapable.

The later sounds more robust to me because we invoke the oom_reaper and
the side effect shouldn't be really a problem because the vforked task
couldn't have done a lot of useful work anyway. So I will drop this
patch and update "mm, oom: fortify task_will_free_mem" to skip the
the vfork check as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
