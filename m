Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA4E46B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:36:48 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id f188so12657124qke.21
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 21:36:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v33si14924838qtk.21.2017.12.18.21.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 21:36:47 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBJ5XiuD074555
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:36:47 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2exr22sbcc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:36:46 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Dec 2017 00:36:46 -0500
Date: Mon, 18 Dec 2017 21:36:50 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 -mm] mm, swap: Fix race between swapoff and some swap
 operations
Reply-To: paulmck@linux.vnet.ibm.com
References: <20171218073424.29647-1-ying.huang@intel.com>
 <877etkwki2.fsf@yhuang-dev.intel.com>
 <20171218230945.GX7829@linux.vnet.ibm.com>
 <877etjv5ry.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877etjv5ry.fsf@yhuang-dev.intel.com>
Message-Id: <20171219053650.GB7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, JXrXme Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Tue, Dec 19, 2017 at 09:57:21AM +0800, Huang, Ying wrote:
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:
> 
> > On Mon, Dec 18, 2017 at 03:41:41PM +0800, Huang, Ying wrote:
> >> "Huang, Ying" <ying.huang@intel.com> writes:
> >> And, it appears that if we replace smp_wmb() in _enable_swap_info() with
> >> stop_machine() in some way, we can avoid smp_rmb() in get_swap_device().
> >> This can reduce overhead in normal path further.  Can we get same effect
> >> with RCU?  For example, use synchronize_rcu() instead of stop_machine()?
> >> 
> >> Hi, Paul, can you help me on this?
> >
> > If the key loads before and after the smp_rmb() are within the same
> > RCU read-side critical section, -and- if one of the critical writes is
> > before the synchronize_rcu() and the other critical write is after the
> > synchronize_rcu(), then you normally don't need the smp_rmb().
> >
> > Otherwise, you likely do still need the smp_rmb().
> 
> My question may be too general, let make it more specific.  For the
> following program,
> 
> "
> int a;
> int b;
> 
> void intialize(void)
> {
>         a = 1;
>         synchronize_rcu();
>         b = 2;
> }
> 
> void test(void)
> {
>         int c;
> 
>         rcu_read_lock();
>         c = b;
>         /* ignored smp_rmb() */
>         if (c)
>                 pr_info("a=%d\n", a);
>         rcu_read_unlock();
> }
> "
> 
> Is it possible for it to show
> 
> "
> a=0
> "
> 
> in kernel log?
> 
> 
> If it couldn't, this could be a useful usage model of RCU to accelerate
> hot path.

This is not possible, and it can be verified using the Linux kernel
memory model.  An introduction to an older version of this model may
be found here (including an introduction to litmus tests and their
output):

	https://lwn.net/Articles/718628/
	https://lwn.net/Articles/720550/

The litmus test and its output are shown below.

The reason it is not possible is that the entirety of test()'s RCU
read-side critical section must do one of two things:

1.	Come before the return from initialize()'s synchronize_rcu().
2.	Come after the call to initialize()'s synchronize_rcu().

Suppose test()'s load from "b" sees initialize()'s assignment.  Then
some part of test()'s RCU read-side critical section came after
initialize()'s call to synchronize_rcu(), which means that the entirety
of test()'s RCU read-side critical section must come after initialize()'s
call to synchronize_rcu().  Therefore, whenever "c" is non-zero, the
pr_info() must see "a" non-zero.

							Thanx, Paul

------------------------------------------------------------------------

C MP-o-sync-o+rl-o-ctl-o-rul

{}

P0(int *a, int *b)
{
	WRITE_ONCE(*a, 1);
	synchronize_rcu();
	WRITE_ONCE(*b, 2);
}

P1(int *a, int *b)
{
	int r0;
	int r1;

	rcu_read_lock();
	r0 = READ_ONCE(*b);
	if (r0)
		r1 = READ_ONCE(*a);
	rcu_read_unlock();
}

exists (1:r0=1 /\ 1:r1=0)

------------------------------------------------------------------------

States 2
1:r0=0; 1:r1=0;
1:r0=2; 1:r1=1;
No
Witnesses
Positive: 0 Negative: 2
Condition exists (1:r0=1 /\ 1:r1=0)
Observation MP-o-sync-o+rl-o-ctl-o-rul Never 0 2
Time MP-o-sync-o+rl-o-ctl-o-rul 0.01
Hash=b20eca2da50fa84b15e489502420ff56

------------------------------------------------------------------------

The "Never 0 2" means that the condition cannot happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
