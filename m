Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 467106B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:43:50 -0500 (EST)
Date: Mon, 27 Feb 2012 10:43:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <87zkc7eshq.fsf@xmission.com>
Message-ID: <alpine.DEB.2.00.1202271039320.29787@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home>
 <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home> <4F47BF56.6010602@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241053220.3726@router.home> <alpine.DEB.2.00.1202241105280.3726@router.home> <4F47C800.4090903@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202241131400.3726@router.home> <87zkc7eshq.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 24 Feb 2012, Eric W. Biederman wrote:

> Taking a quick look it does appear that in cpuset_mems_allowed and it's
> cousins we never sleep under "callback_mutex" so that lock looks like it
> could become a spinlock.
>
> But I have to say something just bothers me about the permissions for
> modifying an mm living in the task.  We can have different rules
> for modifying an mm depending on the path to tme mm?

Yes. Permissions are associated with pids which refer to tasks. Tasks have
address spaces and tasks may share address spaces.

> Especially in things like which numa nodes we can put pages in?

Things = address spaces? The page migration functionality is about moving
the location of physical memory from one numa node to the other. It does
not affect the execution just the latencies experienced by the processes.

> So by specifying a different pid to access them mm through the call can
> either work or succeed?  Are these checks really sane?

Yes if you can create two pids with the same address space and give
those those pids to different owners then the permission checks on one
may fail and succeed on the other. We have no way to refer to address
spaces from user space outside of a pid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
