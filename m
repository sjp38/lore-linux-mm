Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 63D786B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 14:40:16 -0500 (EST)
Date: Thu, 23 Feb 2012 13:40:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <4F468F09.5050200@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1202231334290.10914@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 23 Feb 2012, Dave Hansen wrote:

> > Hmmm isnt the race still there between the determination of the task and
> > the get_task_struct()? You would have to verify after the get_task_struct
> > that this is really the task we wanted to avoid the race.
>
> It's true that selecting a task by pid is inherently racy.  What that
> code does is ensure that the task you've got current has 'pid', but not
> ensure that 'pid' has never represented another task.  But, that's what
> we do everywhere else in the kernel; there's not much better that we can do.

We may at this point be getting a reference to a task struct from another
process not only from the current process (where the above procedure is
valid). You rightly pointed out that the slab rcu free mechanism allows a
free and a reallocation within the RCU period. The effect is that the task
struct could be pointing to a task with another pid that what we were
looking for and therefore migrate_pages could subsequently be operating on
a totally different process.

The patch does not fix that race so far.

I think you have to verify that the pid of the task matches after you took
the refcount in order to be safe. If it does not match then abort.

> Maybe "race" is the wrong word for what we've got here.  It's a lack of
> a refcount being taken.

Is that a real difference or are you just playing with words?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
