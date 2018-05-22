Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD9D6B0277
	for <linux-mm@kvack.org>; Tue, 22 May 2018 18:54:05 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f10-v6so12915533pln.21
        for <linux-mm@kvack.org>; Tue, 22 May 2018 15:54:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9-v6sor7668146pli.21.2018.05.22.15.54.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 15:54:03 -0700 (PDT)
Date: Tue, 22 May 2018 15:54:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add the memcg print oom info for system oom
In-Reply-To: <20180522063742.GE20020@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1805221542540.83718@chino.kir.corp.google.com>
References: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com> <20180517071140.GQ12670@dhcp22.suse.cz> <CAHCio2gOLnj4NpkFrxpYVygg6ZeSeuwgp2Lwr6oTHRxHpbmcWw@mail.gmail.com> <20180517102330.GS12670@dhcp22.suse.cz> <alpine.DEB.2.21.1805211405300.41872@chino.kir.corp.google.com>
 <20180522063742.GE20020@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Tue, 22 May 2018, Michal Hocko wrote:

> > I've had success with defining a single line output the includes the 
> > CONSTRAINT_* of the oom kill, the origin and kill memcgs, the thread name, 
> > pid, and uid.  On system oom kills, origin and kill memcgs are left empty.
> > 
> > oom-kill constraint=CONSTRAINT_* origin_memcg=<memcg> kill_memcg=<memcg> task=<comm> pid=<pid> uid=<uid>
> > 
> > Perhaps we should introduce a single line output that will be backwards 
> > compatible that includes this information?
> 
> I do not have a strong preference here. We already print cpuset on its
> own line and we can do the same for the memcg.
> 

Yes, for both the memcg that has reached its limit (origin_memcg) and the 
memcg the killed process is attached to (kill_memcg).

It's beneficial to have a single-line output to avoid any printk 
interleaving or ratelimiting that includes the constraint, comm, and at 
least pid.  (We include uid simply to find oom kills of root processes.)

We already have all this information, including cpuset, cpuset nodemask, 
and allocation nodemask for mempolicy ooms.  The only exception appears to 
be the kill_memcg for CONSTRAINT_NONE and for it to be emitted in a way 
that can't be interleaved or suppressed.

Perhaps we can have this?

oom-kill constraint=CONSTRAINT_* nodemask=<cpuset/mempolicy nodemask> origin_memcg=<memcg> kill_memcg=<memcg> task=<comm> pid=<pid> uid=<uid>

For CONSTRAINT_NONE, nodemask and origin_memcg are empty.  For 
CONSTRAINT_CPUSET and CONSTRAINT_MEMORY_POLICY, origin_memcg is empty.
