Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 803226B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:31:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so27266089pga.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:31:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j63si40077767pfg.51.2016.11.30.06.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 06:31:11 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUEUAiA141114
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:31:11 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271wugkd83-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:31:10 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 07:31:10 -0700
Date: Wed, 30 Nov 2016 06:31:06 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <68025f6c-6801-ab46-b0fc-a9407353d8ce@molgen.mpg.de>
 <20161124101525.GB20668@dhcp22.suse.cz>
 <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130115442.GA19271@linux.vnet.ibm.com>
 <f254c97c-94d9-6c1e-ca03-f702a3ccc7a9@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f254c97c-94d9-6c1e-ca03-f702a3ccc7a9@molgen.mpg.de>
Message-Id: <20161130143106.GT3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Wed, Nov 30, 2016 at 01:31:37PM +0100, Paul Menzel wrote:
> On 11/30/16 12:54, Paul E. McKenney wrote:
> > On Wed, Nov 30, 2016 at 03:53:20AM -0800, Paul E. McKenney wrote:
> >> On Wed, Nov 30, 2016 at 12:09:44PM +0100, Michal Hocko wrote:
> >>> [CCing Paul]
> >>>
> >>> On Wed 30-11-16 11:28:34, Donald Buczek wrote:
> >>> [...]
> >>>> shrink_active_list gets and releases the spinlock and calls cond_resched().
> >>>> This should give other tasks a chance to run. Just as an experiment, I'm
> >>>> trying
> >>>>
> >>>> --- a/mm/vmscan.c
> >>>> +++ b/mm/vmscan.c
> >>>> @@ -1921,7 +1921,7 @@ static void shrink_active_list(unsigned long
> >>>> nr_to_scan,
> >>>>         spin_unlock_irq(&pgdat->lru_lock);
> >>>>
> >>>>         while (!list_empty(&l_hold)) {
> >>>> -               cond_resched();
> >>>> +               cond_resched_rcu_qs();
> >>>>                 page = lru_to_page(&l_hold);
> >>>>                 list_del(&page->lru);
> >>>>
> >>>> and didn't hit a rcu_sched warning for >21 hours uptime now. We'll see.
> >>>
> >>> This is really interesting! Is it possible that the RCU stall detector
> >>> is somehow confused?
> >>
> >> No, it is not confused.  Again, cond_resched() is not a quiescent
> >> state unless it does a context switch.  Therefore, if the task running
> >> in that loop was the only runnable task on its CPU, cond_resched()
> >> would -never- provide RCU with a quiescent state.
> >>
> >> In contrast, cond_resched_rcu_qs() unconditionally provides RCU
> >> with a quiescent state (hence the _rcu_qs in its name), regardless
> >> of whether or not a context switch happens.
> >>
> >> It is therefore expected behavior that this change might prevent
> >> RCU CPU stall warnings.
> > 
> > I should add...  This assumes that CONFIG_PREEMPT=n.  So what is
> > CONFIG_PREEMPT?
> 
> Ita??s not selected.
> 
> ```
> # CONFIG_PREEMPT is not set
> ```

Thank you for the info!

As noted elsewhere in this thread, there are other ways to get stalls,
including the long irq-disabled execution that Michal suspects.

							Thanx, Paul

> >>>> Is preemption disabled for another reason?
> >>>
> >>> I do not think so. I will have to double check the code but this is a
> >>> standard sleepable context. Just wondering what is the PREEMPT
> >>> configuration here?
> 
> 
> Kind regards,
> 
> Paul
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
