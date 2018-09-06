Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9426B770A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:57:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g29-v6so3276672edb.1
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:57:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o35-v6si144340edo.114.2018.09.05.22.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:57:54 -0700 (PDT)
Date: Thu, 6 Sep 2018 07:57:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180906055742.GL14951@dhcp22.suse.cz>
References: <81cc1f29-e42e-7813-dc70-5d6d9e999dd1@i-love.sakura.ne.jp>
 <20180905140451.GG14951@dhcp22.suse.cz>
 <201809060100.w86100i6060716@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201809060100.w86100i6060716@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 06-09-18 10:00:00, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 05-09-18 22:53:33, Tetsuo Handa wrote:
> > > On 2018/09/05 22:40, Michal Hocko wrote:
> > > > Changelog said 
> > > > 
> > > > "Although this is possible in principle let's wait for it to actually
> > > > happen in real life before we make the locking more complex again."
> > > > 
> > > > So what is the real life workload that hits it? The log you have pasted
> > > > below doesn't tell much.
> > > 
> > > Nothing special. I just ran a multi-threaded memory eater on a CONFIG_PREEMPT=y kernel.
> > 
> > I strongly suspec that your test doesn't really represent or simulate
> > any real and useful workload. Sure it triggers a rare race and we kill
> > another oom victim. Does this warrant to make the code more complex?
> > Well, I am not convinced, as I've said countless times.
> 
> Yes. Below is an example from a machine running Apache Web server/Tomcat AP server/PostgreSQL DB server.
> An memory eater needlessly killed Tomcat due to this race.

What prevents you from modifying you mem eater in a way that Tomcat
resp. others from being the primary oom victim choice? In other words,
yeah it is not optimal to lose the race but if it is rare enough then
this is something to live with because it can be hardly considered a
new DoS vector AFAICS. Remember that this is always going to be racy
land and we are not going to plumb all possible races because this is
simply not viable. But I am pretty sure we have been through all this
many times already. Oh well...

> I assert that we should fix af5679fbc669f31f.

If you can come up with reasonable patch which doesn't complicate the
code and it is a clear win for both this particular workload as well as
others then why not.
-- 
Michal Hocko
SUSE Labs
