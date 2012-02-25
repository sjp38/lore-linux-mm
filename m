Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 23BA36B004A
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 07:13:54 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20120223180740.C4EC4156@kernel>
	<alpine.DEB.2.00.1202231240590.9878@router.home>
	<4F468F09.5050200@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202231334290.10914@router.home>
	<4F469BC7.50705@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202231536240.13554@router.home>
	<m1ehtkapn9.fsf@fess.ebiederm.org>
	<alpine.DEB.2.00.1202240859340.2621@router.home>
	<4F47BF56.6010602@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202241053220.3726@router.home>
	<alpine.DEB.2.00.1202241105280.3726@router.home>
	<4F47C800.4090903@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202241131400.3726@router.home>
Date: Sat, 25 Feb 2012 04:13:44 -0800
In-Reply-To: <alpine.DEB.2.00.1202241131400.3726@router.home> (Christoph
	Lameter's message of "Fri, 24 Feb 2012 11:32:59 -0600 (CST)")
Message-ID: <87sjhzun47.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Christoph Lameter <cl@linux.com> writes:

> On Fri, 24 Feb 2012, Dave Hansen wrote:
>
>> > Is that all safe? If not then we need to take a refcount on the task
>> > struct after all.
>>
>> Urg, no we can't sleep under an rcu_read_lock().
>
> Ok so take a count and drop it before entering the main migration
> function?

For correct operation of kernel code a count sounds fine.

If you are going to allow sleeping how do you ensure that an exec that
happens between the taking of the reference count and checking the
permissions does not mess things up.

At the very least the patch description needs an explanation of what
the thinking will be in that case.

At the moment I suspect the permissions checks are not safe unless
performed under both rcu_read_lock and task_lock to ensure that
the task<->mm association does not change on us while we are
working.  Even with that the cred can change under us but at least
we know the cred will be valid until rcu_read_unlock happens.

This entire thinhg of modifying another process is a pain.

Perhaps you can play with task->self_exec_id to detect an exec and fail
the system call if there was an exec in between when we find the task
and when we drop the task reference.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
