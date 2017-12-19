Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A77FA6B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 20:57:29 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id j6so6445724pll.4
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 17:57:29 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f4si7909700plr.189.2017.12.18.17.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 17:57:28 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V3 -mm] mm, swap: Fix race between swapoff and some swap operations
References: <20171218073424.29647-1-ying.huang@intel.com>
	<877etkwki2.fsf@yhuang-dev.intel.com>
	<20171218230945.GX7829@linux.vnet.ibm.com>
Date: Tue, 19 Dec 2017 09:57:21 +0800
In-Reply-To: <20171218230945.GX7829@linux.vnet.ibm.com> (Paul E. McKenney's
	message of "Mon, 18 Dec 2017 15:09:45 -0800")
Message-ID: <877etjv5ry.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:

> On Mon, Dec 18, 2017 at 03:41:41PM +0800, Huang, Ying wrote:
>> "Huang, Ying" <ying.huang@intel.com> writes:
>> And, it appears that if we replace smp_wmb() in _enable_swap_info() with
>> stop_machine() in some way, we can avoid smp_rmb() in get_swap_device().
>> This can reduce overhead in normal path further.  Can we get same effect
>> with RCU?  For example, use synchronize_rcu() instead of stop_machine()?
>> 
>> Hi, Paul, can you help me on this?
>
> If the key loads before and after the smp_rmb() are within the same
> RCU read-side critical section, -and- if one of the critical writes is
> before the synchronize_rcu() and the other critical write is after the
> synchronize_rcu(), then you normally don't need the smp_rmb().
>
> Otherwise, you likely do still need the smp_rmb().

My question may be too general, let make it more specific.  For the
following program,

"
int a;
int b;

void intialize(void)
{
        a = 1;
        synchronize_rcu();
        b = 2;
}

void test(void)
{
        int c;

        rcu_read_lock();
        c = b;
        /* ignored smp_rmb() */
        if (c)
                pr_info("a=%d\n", a);
        rcu_read_unlock();
}
"

Is it possible for it to show

"
a=0
"

in kernel log?


If it couldn't, this could be a useful usage model of RCU to accelerate
hot path.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
