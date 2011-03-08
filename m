Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 465708D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:12:58 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p280Csi9029836
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 16:12:54 -0800
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by hpaq11.eem.corp.google.com with ESMTP id p280CkAH015821
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 16:12:53 -0800
Received: by pvh11 with SMTP id 11so1381985pvh.22
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 16:12:46 -0800 (PST)
Date: Mon, 7 Mar 2011 16:12:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110303135223.0a415e69.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
 <20110303135223.0a415e69.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Thu, 3 Mar 2011, Andrew Morton wrote:

> If userspace has chosen to repalce the oom-killer then userspace should
> be able to appropriately perform the role.  But for some
> as-yet-undescribed reason, userspace is *not* able to perform that
> role.
> 
> And I'm suspecting that the as-yet-undescribed reason is a kernel
> deficiency.  Spit it out.
> 

The purpose of memory.oom_control is to disable to kernel oom killer from 
killing a task as soon as a memcg reaches its hard limit and reclaim has 
failed.  We want that behavior, but only temporarily for two reasons:

 - the condition may be temporary and we'd rather busy loop for the 
   duration of the spike in memory usage than kill something off because 
   it will be coming under the hard limit soon or userspace will be 
   increasing that limit (or killing a lower priority job in favor of 
   this one), and

 - it's possible that the userspace daemon is oom itself (being in a 
   separate cgroup doesn't prevent that) and is therefore subject to 
   being killed itself (or panicking the machine if its OOM_DISABLE and 
   nothing else is eligible) and cannot rectify the situation in other 
   memcgs that are also oom.

So this patch is not a bug fix, it's an enhancement to an already existing 
feature (memory.oom_control) that probably should have been coded to be a 
timeout in the first place and up to userspace whether that's infinite or 
not.

Not merging this patch forces us into the very limiting position where we 
either completely disable the oom killer or we don't and that's not 
helpful in either of the above two cases without relying on userspace to 
fix it (and it may be oom itself and locked out of freeing any memory via 
the oom killer for the very same reason).

So the question I'd ask is: why should the kernel only offer a complete 
and infinite disabling of the oom killer (something we'd never want to do 
in production) to allow userspace a grace period to respond to reaching 
the hard limit as opposed to allowing users the option to allow the 
killing iff userspace can't expand the cgroup or kill something itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
