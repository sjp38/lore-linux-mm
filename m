Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7024A6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 16:41:52 -0500 (EST)
Date: Thu, 23 Feb 2012 15:41:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <4F469BC7.50705@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1202231536240.13554@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 23 Feb 2012, Dave Hansen wrote:

> > We may at this point be getting a reference to a task struct from another
> > process not only from the current process (where the above procedure is
> > valid). You rightly pointed out that the slab rcu free mechanism allows a
> > free and a reallocation within the RCU period.
>
> I didn't _mean_ to point that out, but I think I realize what you're
> talking about.  What we have before this patch is this:
>
>         rcu_read_lock();
>         task = pid ? find_task_by_vpid(pid) : current;

We take a refcount here on the mm ... See the code. We could simply take a
refcount on the task as well if this is considered safe enough. If we have
a refcount on the task then we do not need the refcount on the mm. Thats
was your approach...

>         rcu_read_unlock();

> > Is that a real difference or are you just playing with words?
>
> I think we're talking about two different things:
> 1. does RCU protect the pid->task lookup sufficiently?

I dont know

> 2. Can the task simply go away in the move/migrate_pages() calls?

The task may go away but we need the mm to stay for migration.
That is why a refcount is taken on the mm.

The bug in migrate_pages() is that we do a rcu_unlock and a rcu_lock. If
we drop those then we should be safe if the use of a task pointer within a
rcu section is safe without taking a refcount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
