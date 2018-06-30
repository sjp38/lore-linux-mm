Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13A916B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 13:17:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y13-v6so3907163edq.2
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:17:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y12-v6si48511edj.364.2018.06.30.10.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 10:17:05 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UHGFKo034368
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 13:17:03 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jx6dfmqcu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 13:17:03 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 13:17:01 -0400
Date: Sat, 30 Jun 2018 10:19:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Reply-To: paulmck@linux.vnet.ibm.com
References: <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <20180627072207.GB32348@dhcp22.suse.cz>
 <20180627143125.GW3593@linux.vnet.ibm.com>
 <20180628113942.GD32348@dhcp22.suse.cz>
 <20180628213105.GP3593@linux.vnet.ibm.com>
 <20180629090419.GD13860@dhcp22.suse.cz>
 <20180629125218.GX3593@linux.vnet.ibm.com>
 <bf76c93d-37d6-5f1e-4e5a-122089997fd9@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf76c93d-37d6-5f1e-4e5a-122089997fd9@i-love.sakura.ne.jp>
Message-Id: <20180630171907.GA3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Jun 29, 2018 at 11:35:48PM +0900, Tetsuo Handa wrote:
> On 2018/06/29 21:52, Paul E. McKenney wrote:
> > The effect of RCU's current OOM code is to speed up callback invocation
> > by at most a few seconds (assuming no stalled CPUs, in which case
> > it is not possible to speed up callback invocation).
> > 
> > Given that, I should just remove RCU's OOM code entirely?
> 
> out_of_memory() will start selecting an OOM victim without calling
> get_page_from_freelist() since rcu_oom_notify() does not set non-zero
> value to "freed" field.
> 
> I think that rcu_oom_notify() needs to wait for completion of callback
> invocations (possibly with timeout in case there are stalling CPUs) and
> set non-zero value to "freed" field if pending callbacks did release memory.

Waiting for the callbacks is easy.  Timeouts would be a bit harder, but
still doable.  I have no idea how to tell which callbacks freed memory
and how much -- all RCU does is invoke a function, and that function
can do whatever its developer wants.

> However, what will be difficult to tell is whether invocation of pending callbacks
> did release memory. Lack of last second get_page_from_freelist() call after
> blocking_notifier_call_chain(&oom_notify_list, 0, &freed) forces rcu_oom_notify()
> to set appropriate value (i.e. zero or non-zero) to "freed" field.
> 
> We have tried to move really last second get_page_from_freelist() call to inside
> out_of_memory() after blocking_notifier_call_chain(&oom_notify_list, 0, &freed).
> But that proposal was not accepted...
> 
> We could move blocking_notifier_call_chain(&oom_notify_list, 0, &freed) to
> before last second get_page_from_freelist() call (and this is what this patch
> is trying to do) which would allow rcu_oom_notify() to always return 0...
> or update rcu_oom_notify() to use shrinker API...

Would it be possible to tell RCU that memory was starting to get tight
with one call, and then tell it that things are OK with another call?
That would make much more sense from an RCU perspective.

							Thanx, Paul
