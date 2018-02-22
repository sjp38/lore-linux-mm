Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 109916B02DA
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:53:51 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a5so2333062plp.0
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:53:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i9si73167pgn.33.2018.02.22.05.53.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 05:53:49 -0800 (PST)
Date: Thu, 22 Feb 2018 14:53:45 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 0/3] Directed kmem charging
Message-ID: <20180222135345.epm6e34cvxzaxn74@quack2.suse.cz>
References: <20180221030101.221206-1-shakeelb@google.com>
 <alpine.DEB.2.20.1802211002200.12567@nuc-kabylake>
 <CALvZod68LD-wnbm2+MQks=bd_D2zY64uScUBp28hyug_vaGyDA@mail.gmail.com>
 <alpine.DEB.2.20.1802211155500.13845@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802211155500.13845@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Shakeel Butt <shakeelb@google.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 21-02-18 11:57:47, Christopher Lameter wrote:
> On Wed, 21 Feb 2018, Shakeel Butt wrote:
> 
> > On Wed, Feb 21, 2018 at 8:09 AM, Christopher Lameter <cl@linux.com> wrote:
> > > Another way to solve this is to switch the user context right?
> > >
> > > Isnt it possible to avoid these patches if do the allocation in another
> > > task context instead?
> > >
> >
> > Sorry, can you please explain what you mean by 'switch the user
> > context'. Is there any example in kernel which does something similar?
> 
> See include/linux/task_work.h. One use case is in mntput_no_expire() in
> linux/fs/namespace.c
> 
> > > Are there really any other use cases beyond fsnotify?
> > >
> >
> > Another use case I have in mind and plan to upstream is to bind a
> > filesystem mount with a memcg. So, all the file pages (or anon pages
> > for shmem) and kmem (like inodes and dentry) will be charged to that
> > memcg.
> 
> The mount logic already uses task_work.h. That may be the approach to
> expand there.

I don't see how task work can be used here. Firstly I don't know of a case
where task work would be used for something else than the current task -
and that is substantial because otherwise you have to deal with lots of
problems like races with task exit, when work gets executed (normally it
gets executed once task exits to userspace) etc. Or do you mean that you'd
queue task work for current task and then somehow magically switch memcg
there? In that case this magic switching isn't clear to me...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
