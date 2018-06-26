Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A30766B0003
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 19:48:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t83-v6so1590854wmt.3
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 16:48:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d65-v6si1528002wmh.159.2018.06.26.16.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 16:48:16 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5QNi7tK071896
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 19:48:14 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2juy3f0kbr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 19:48:14 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 26 Jun 2018 19:48:13 -0400
Date: Tue, 26 Jun 2018 16:50:14 -0700
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f40d85e0-1d90-2261-99a4-4db315df4860@i-love.sakura.ne.jp>
Message-Id: <20180626235014.GS3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, Jun 27, 2018 at 05:10:48AM +0900, Tetsuo Handa wrote:
> On 2018/06/27 2:03, Paul E. McKenney wrote:
> > There are a lot of ways it could be made concurrency safe.  If you need
> > me to do this, please do let me know.
> > 
> > That said, the way it is now written, if you invoke rcu_oom_notify()
> > twice in a row, the second invocation will wait until the memory from
> > the first invocation is freed.  What do you want me to do if you invoke
> > me concurrently?
> > 
> > 1.	One invocation "wins", waits for the earlier callbacks to
> > 	complete, then encourages any subsequent callbacks to be
> > 	processed more quickly.  The other invocations return
> > 	immediately without doing anything.
> > 
> > 2.	The invocations serialize, with each invocation waiting for
> > 	the callbacks from previous invocation (in mutex_lock() order
> > 	or some such), and then starting a new round.
> > 
> > 3.	Something else?
> > 
> > 							Thanx, Paul
> 
> As far as I can see,
> 
> -	atomic_set(&oom_callback_count, 1);
> +	atomic_inc(&oom_callback_count);
> 
> should be sufficient.

I don't see how that helps.  For example, suppose that two tasks
invoked rcu_oom_notify() at about the same time.  Then they could
both see oom_callback_count equal to zero, both atomically increment
oom_callback_count, then both do the IPI invoking rcu_oom_notify_cpu()
on each online CPU.

So far, so good.  But rcu_oom_notify_cpu() enqueues a per-CPU RCU
callback, and enqueuing the same callback twice in quick succession
would fatally tangle RCU's callback lists.

What am I missing here?

							Thanx, Paul
