Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 95F186B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 17:30:39 -0500 (EST)
Date: Wed, 14 Jan 2009 15:30:32 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH RFC] Lost wakeups from lock_page_killable()
Message-ID: <20090114223031.GU29283@parisc-linux.org>
References: <1231964632.8269.47.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1231964632.8269.47.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, "chuck.lever" <chuck.lever@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 14, 2009 at 03:23:52PM -0500, Chris Mason wrote:
> Chuck has been debugging a problem with NFS mounts where procs are
> getting stuck waiting on the page lock.  He did a bunch of work around
> tracking the last person to lock the page and then printing out the page
> state when it found stuck procs.

Yes, I can testify to Chuck's hard work on this.  I hadn't managed to
figure out this problem ... I was blaming lock_page_killable() but
couldn't see the bug.

> lock_page and lock_page_killable both call __wait_on_bit_lock, and so
> both end up using prepare_to_wait_exclusive().  This means that when
> someone does finally unlock the page, only one process is going to get
> woken up.

Yeah.  This is a Bad API, IMO.  It doesn't contain the word 'exclusive'
in it, so I had no idea that __wait_on_bit_lock was an exclusive wait.
Sure, if I'd drilled down further, I'd've noticed that, and maybe having
the word 'exlcusive' in the name of the function wouldn't've made me
spot the bug, but I think it's worth changing.

> So, procA holding the page lock, procB and procC are waiting on the
> lock.
> 
> procA: lock_page() // success
> procB: lock_page_killable(), sync_page_killable(), io_schedule()
> procC: lock_page_killable(), sync_page_killable(), io_schedule()
> 
> procA: unlock, wake_up_page(page, PG_locked)
> procA: wake up procB
> 
> happy admin: kill procB
> 
> procB: wakes into sync_page_killable(), notices the signal and returns
> -EINTR
> 
> procB: __wait_on_bit_lock sees the action() func returns < 0 and does
> not take the page lock
> 
> procB: lock_page_killable() returns < 0 and exits happily.
> 
> procC: sleeping in io_schedule() forever unless someone else locks the
> page.

Yeah.  That works.  Of course, if you're multithreaded and you have
threads B1 B2 B3 B4 B5 B6 ... waiting on the same page, killing procB is
going to give you a fairly high likelihood of procC getting stuck.

Since procC is also sleeping in a killable state, you can kill procC too.
Chuck asked "Why isn't anyone else seeing this?" and I think the answer
is that they are, but who's reporting it?  It just gets written off
as "^C didn't work.  Try harder." and eventually everything dies, so
nobody's going to file a bug against the kernel ... it's clearly an
application bug.

> The patch below is entirely untested but may do a better job of
> explaining what I think the bug is.  I'm hoping I can trigger it locally
> with a few dd commands mixed with a lot of kill commands.

The patch looks sane to me.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
