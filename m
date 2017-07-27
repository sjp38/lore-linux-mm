Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 455636B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:53:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so10646700wmg.3
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:53:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si18232033wro.343.2017.07.26.23.53.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 23:53:18 -0700 (PDT)
Date: Thu, 27 Jul 2017 08:53:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: memcg: fix css double put in mem_cgroup_iter
Message-ID: <20170727065314.GC20970@dhcp22.suse.cz>
References: <20170726130742.5976-1-wenwei.tww@gmail.com>
 <20170726134451.GR2981@dhcp22.suse.cz>
 <CAEYKbkR6WRtD3G83RUqe12TQqEO618B2Ybhr4XbhsuPqCEYySQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEYKbkR6WRtD3G83RUqe12TQqEO618B2Ybhr4XbhsuPqCEYySQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wenwei Tao <wenwei.tww@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, yuwang.yuwang@alibaba-inc.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wenwei Tao <wenwei.tww@alibaba-inc.com>

On Thu 27-07-17 11:30:50, Wenwei Tao wrote:
> 2017-07-26 21:44 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 26-07-17 21:07:42, Wenwei Tao wrote:
[...]
> >> I think there is a css double put in mem_cgroup_iter. Under reclaim,
> >> we call mem_cgroup_iter the first time with prev == NULL, and we get
> >> last_visited memcg from per zone's reclaim_iter then call __mem_cgroup_iter_next
> >> try to get next alive memcg, __mem_cgroup_iter_next could return NULL
> >> if last_visited is already the last one so we put the last_visited's
> >> memcg css and continue to the next while loop, this time we might not
> >> do css_tryget(&last_visited->css) if the dead_count is changed, but
> >> we still do css_put(&last_visited->css), we put it twice, this could
> >> trigger the BUG_ON at kernel/cgroup.c:893.
> >
> > Yes, I guess your are right and I suspect that this has been silently
> > fixed by 519ebea3bf6d ("mm: memcontrol: factor out reclaim iterator
> > loading and updating"). I think a more appropriate fix is would be.
> > Are you able to reproduce and re-test it?
> > ---
> 
> Yes, I think this commit can fix this issue, and I backport this
> commit to 3.10.107 kernel and cannot reproduce this issue. I guess
> this commit might need to be backported to 3.10.y stable kernel.

Please send it to the kernel-stable mailing list. 3.10 seems to be still
maintained.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
