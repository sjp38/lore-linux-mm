Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 547C06B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 17:11:24 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q16-v6so10753981pls.15
        for <linux-mm@kvack.org>; Mon, 21 May 2018 14:11:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor6650088pfh.53.2018.05.21.14.11.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 14:11:22 -0700 (PDT)
Date: Mon, 21 May 2018 14:11:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add the memcg print oom info for system oom
In-Reply-To: <20180517102330.GS12670@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1805211405300.41872@chino.kir.corp.google.com>
References: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com> <20180517071140.GQ12670@dhcp22.suse.cz> <CAHCio2gOLnj4NpkFrxpYVygg6ZeSeuwgp2Lwr6oTHRxHpbmcWw@mail.gmail.com> <20180517102330.GS12670@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Thu, 17 May 2018, Michal Hocko wrote:

> this is not 5 lines at all. We dump memcg stats for the whole oom memcg
> subtree. For your patch it would be the whole subtree of the memcg of
> the oom victim. With cgroup v1 this can be quite deep as tasks can
> belong to inter-nodes as well. Would be
> 
> 		pr_info("Task in ");
> 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> 		pr_cont(" killed as a result of limit of ");
> 
> part of that output sufficient for your usecase?

There's no memcg to print as the limit in the above, but it does seem like 
the single line output is all that is needed in this case.

It might be useful to discuss a single line output that specifies relevant 
information about the context of the oom kill, the killed thread, and the 
memcg of that thread, in a way that will be backwards compatible.  The 
messages in the oom killer have been restructured over time, I don't 
believe there is a backwards compatible way to search for an oom event in 
the kernel log.

I've had success with defining a single line output the includes the 
CONSTRAINT_* of the oom kill, the origin and kill memcgs, the thread name, 
pid, and uid.  On system oom kills, origin and kill memcgs are left empty.

oom-kill constraint=CONSTRAINT_* origin_memcg=<memcg> kill_memcg=<memcg> task=<comm> pid=<pid> uid=<uid>

Perhaps we should introduce a single line output that will be backwards 
compatible that includes this information?
