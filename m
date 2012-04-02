Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 509A66B007E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 12:03:03 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3130814bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 09:03:01 -0700 (PDT)
Date: Mon, 2 Apr 2012 20:02:53 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120402160253.GB15260@moon>
References: <20120331091049.19373.28994.stgit@zurg>
 <20120331092929.19920.54540.stgit@zurg>
 <20120331201324.GA17565@redhat.com>
 <20120331203912.GB687@moon>
 <4F79755B.3030703@openvz.org>
 <20120402144821.GA3334@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120402144821.GA3334@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

On Mon, Apr 02, 2012 at 04:48:21PM +0200, Oleg Nesterov wrote:
> On 04/02, Konstantin Khlebnikov wrote:
> >
> > In this patch I leave mm->exe_file lockless.
> > After exec/fork we can change it only for current task and only if mm->mm_users == 1.
> >
> > something like this:
> >
> > task_lock(current);
> 
> OK, this protects against the race with get_task_mm()
> 
> > if (atomic_read(&current->mm->mm_users) == 1)
> 
> this means PR_SET_MM_EXE_FILE can fail simply because someone did
> get_task_mm(). Or the caller is multithreaded.

So it leads to the same question -- do we *really* need the PR_SET_MM_EXE_FILE
to be one-shot action? Yeah, I know, we agreed that one-shot is better than
anything else from sysadmin perspective and such, but maybe I could introduce
a special capability bit for c/r and allow a program which has such cap to modify
exe-file without checkin mm_users?

/me hides

> 
> > 	set_mm_exe_file(current->mm, new_file);
> 
> No, fput() can sleep.

Sure, it was just "something like" as Konstantin stated, thanks anyway ;)

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
