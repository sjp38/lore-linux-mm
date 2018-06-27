Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECD356B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:26:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so2606164wmc.7
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:26:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b4-v6si2050615wru.376.2018.06.27.07.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 07:26:21 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5REJw2Y115920
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:26:20 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jv9h1g77a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:26:19 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 10:26:19 -0400
Date: Wed, 27 Jun 2018 07:28:22 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Reply-To: paulmck@linux.vnet.ibm.com
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <f40d85e0-1d90-2261-99a4-4db315df4860@i-love.sakura.ne.jp>
 <20180626235014.GS3593@linux.vnet.ibm.com>
 <c0aeb719-ccb7-46c7-2ad9-b0630bf4d542@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0aeb719-ccb7-46c7-2ad9-b0630bf4d542@i-love.sakura.ne.jp>
Message-Id: <20180627142822.GV3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, Jun 27, 2018 at 07:52:23PM +0900, Tetsuo Handa wrote:
> On 2018/06/27 8:50, Paul E. McKenney wrote:
> > On Wed, Jun 27, 2018 at 05:10:48AM +0900, Tetsuo Handa wrote:
> >> As far as I can see,
> >>
> >> -	atomic_set(&oom_callback_count, 1);
> >> +	atomic_inc(&oom_callback_count);
> >>
> >> should be sufficient.
> > 
> > I don't see how that helps.  For example, suppose that two tasks
> > invoked rcu_oom_notify() at about the same time.  Then they could
> > both see oom_callback_count equal to zero, both atomically increment
> > oom_callback_count, then both do the IPI invoking rcu_oom_notify_cpu()
> > on each online CPU.
> > 
> > So far, so good.  But rcu_oom_notify_cpu() enqueues a per-CPU RCU
> > callback, and enqueuing the same callback twice in quick succession
> > would fatally tangle RCU's callback lists.
> > 
> > What am I missing here?
> 
> You are pointing out that "number of rsp->call() is called" > "number of
> rcu_oom_callback() is called" can happen if concurrently called, aren't you?

Yes.  Reusing an rcu_head before invocation of the earlier use is
very bad indeed.  ;-)

> Then, you are not missing anything. You will need to use something equivalent
> to oom_lock even if you can convert rcu_oom_notify() to use shrinkers.

What should I look at to work out whether it makes sense to convert
rcu_oom_notify() to shrinkers, and if so, how to go about it?

Or are you simply asking me to serialize rcu_oom_notify()?  (Which is
of course not difficult, so please just let me know.)

							Thanx, Paul
