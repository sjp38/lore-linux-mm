Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 6386A6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:06:02 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 23 Feb 2012 15:06:00 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3BF086E806F
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:05:02 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1NK4QS4459206
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:04:36 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1NK4QbY011834
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:04:26 -0500
Message-ID: <4F469BC7.50705@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2012 12:04:23 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home>
In-Reply-To: <alpine.DEB.2.00.1202231334290.10914@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>

On 02/23/2012 11:40 AM, Christoph Lameter wrote:
> On Thu, 23 Feb 2012, Dave Hansen wrote:
>>> Hmmm isnt the race still there between the determination of the task and
>>> the get_task_struct()? You would have to verify after the get_task_struct
>>> that this is really the task we wanted to avoid the race.
>>
>> It's true that selecting a task by pid is inherently racy.  What that
>> code does is ensure that the task you've got current has 'pid', but not
>> ensure that 'pid' has never represented another task.  But, that's what
>> we do everywhere else in the kernel; there's not much better that we can do.
> 
> We may at this point be getting a reference to a task struct from another
> process not only from the current process (where the above procedure is
> valid). You rightly pointed out that the slab rcu free mechanism allows a
> free and a reallocation within the RCU period.

I didn't _mean_ to point that out, but I think I realize what you're
talking about.  What we have before this patch is this:

        rcu_read_lock();
        task = pid ? find_task_by_vpid(pid) : current;
        rcu_read_unlock();

	task->foo;

So, the task at task->foo time is neither RCU-protected nor protected by
having a reference.  I changed it to:

        rcu_read_lock();
        task = pid ? find_task_by_vpid(pid) : current;
	get_task_struct(task);
        rcu_read_unlock();

	task->foo;

That keeps task from being freed.  But, as you point out

> The effect is that the task
> struct could be pointing to a task with another pid that what we were
> looking for and therefore migrate_pages could subsequently be operating on
> a totally different process.
> 
> The patch does not fix that race so far.

Agreed, this patch would not fix such an issue.

I think this also implies that stuff like get_task_pid() is broken,
along with virtually all of the users of find_task_by_vpid().  Eric, any
thoughts on this?

> I think you have to verify that the pid of the task matches after you took
> the refcount in order to be safe. If it does not match then abort.
> 
>> Maybe "race" is the wrong word for what we've got here.  It's a lack of
>> a refcount being taken.
> 
> Is that a real difference or are you just playing with words?

I think we're talking about two different things:
1. does RCU protect the pid->task lookup sufficiently?
2. Can the task simply go away in the move/migrate_pages() calls?

I think we're on the same page now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
