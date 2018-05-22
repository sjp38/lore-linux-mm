Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E658C6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:37:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v12-v6so8821042wmc.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:37:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10-v6si1368698edc.243.2018.05.21.23.37.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 May 2018 23:37:44 -0700 (PDT)
Date: Tue, 22 May 2018 08:37:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Add the memcg print oom info for system oom
Message-ID: <20180522063742.GE20020@dhcp22.suse.cz>
References: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com>
 <20180517071140.GQ12670@dhcp22.suse.cz>
 <CAHCio2gOLnj4NpkFrxpYVygg6ZeSeuwgp2Lwr6oTHRxHpbmcWw@mail.gmail.com>
 <20180517102330.GS12670@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805211405300.41872@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805211405300.41872@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Mon 21-05-18 14:11:21, David Rientjes wrote:
> On Thu, 17 May 2018, Michal Hocko wrote:
> 
> > this is not 5 lines at all. We dump memcg stats for the whole oom memcg
> > subtree. For your patch it would be the whole subtree of the memcg of
> > the oom victim. With cgroup v1 this can be quite deep as tasks can
> > belong to inter-nodes as well. Would be
> > 
> > 		pr_info("Task in ");
> > 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> > 		pr_cont(" killed as a result of limit of ");
> > 
> > part of that output sufficient for your usecase?
> 
> There's no memcg to print as the limit in the above, but it does seem like 
> the single line output is all that is needed in this case.

Yeah, that is exactly what I was proposing. I just copy&pasted the whole
part to make it clear which part of mem_cgroup_print_oom_info I meant.
Referring to "killed as a reslt of limit of" was misleading. Sorry about
that.

> It might be useful to discuss a single line output that specifies relevant 
> information about the context of the oom kill, the killed thread, and the 
> memcg of that thread, in a way that will be backwards compatible.  The 
> messages in the oom killer have been restructured over time, I don't 
> believe there is a backwards compatible way to search for an oom event in 
> the kernel log.

Agreed
 
> I've had success with defining a single line output the includes the 
> CONSTRAINT_* of the oom kill, the origin and kill memcgs, the thread name, 
> pid, and uid.  On system oom kills, origin and kill memcgs are left empty.
> 
> oom-kill constraint=CONSTRAINT_* origin_memcg=<memcg> kill_memcg=<memcg> task=<comm> pid=<pid> uid=<uid>
> 
> Perhaps we should introduce a single line output that will be backwards 
> compatible that includes this information?

I do not have a strong preference here. We already print cpuset on its
own line and we can do the same for the memcg.

-- 
Michal Hocko
SUSE Labs
