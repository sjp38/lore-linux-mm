Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4M4g79X015794
	for <linux-mm@kvack.org>; Thu, 22 May 2008 14:42:07 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4M4kvAq274562
	for <linux-mm@kvack.org>; Thu, 22 May 2008 14:46:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4M4gnUB002540
	for <linux-mm@kvack.org>; Thu, 22 May 2008 14:42:49 +1000
Message-ID: <4834F992.2040706@linux.vnet.ibm.com>
Date: Thu, 22 May 2008 10:11:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control
 (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521153012.15001.96490.sendpatchset@localhost.localdomain> <20080521172032.GD16367@redhat.com>
In-Reply-To: <20080521172032.GD16367@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Vivek Goyal wrote:
> On Wed, May 21, 2008 at 09:00:12PM +0530, Balbir Singh wrote:
> 
> [..]
>> +static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
>> +					struct cgroup *cgrp,
>> +					struct cgroup *old_cgrp,
>> +					struct task_struct *p)
>> +{
>> +	struct mm_struct *mm;
>> +	struct memrlimit_cgroup *memrcg, *old_memrcg;
>> +
>> +	mm = get_task_mm(p);
>> +	if (mm == NULL)
>> +		return;
>> +
>> +	/*
>> +	 * Hold mmap_sem, so that total_vm does not change underneath us
>> +	 */
>> +	down_read(&mm->mmap_sem);
>> +
>> +	rcu_read_lock();
>> +	if (p != rcu_dereference(mm->owner))
>> +		goto out;
>> +
> 
> Hi Balbir,
> 
> How does rcu help here? We are not dereferencing mm->owner. So even if
> task_struct it was pointing to goes away, should not be a problem.
> 

Yes, you are right, since we already have information about the cgroup and new
cgroup, mm->owner's exit should not really cause a problem

> OTOH, while updating the mm->owner in mmm_update_next_owner(), we
> are not using rcu_assing_pointer() and synchronize_rcu()/call_rcu(). Is
> this the right usage if mm->owner is rcu protected?
> 

Yes, you are correct - I'll send out updates on top of this one.

> Thanks
> Vivek
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
