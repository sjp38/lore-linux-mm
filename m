Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6596B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 10:09:09 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v18so363121953qtv.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 07:09:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s186si1817026qkh.49.2016.07.03.07.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 07:09:08 -0700 (PDT)
Date: Sun, 3 Jul 2016 17:09:04 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160703140904.GA26908@redhat.com>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160703134719.GA28492@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

On Sun, Jul 03, 2016 at 03:47:19PM +0200, Oleg Nesterov wrote:
> On 07/01, Michal Hocko wrote:
> >
> > From: Michal Hocko <mhocko@suse.com>
> >
> > vhost driver relies on copy_from_user/get_user from a kernel thread.
> > This makes it impossible to reap the memory of an oom victim which
> > shares mm with the vhost kernel thread because it could see a zero
> > page unexpectedly and theoretically make an incorrect decision visible
> > outside of the killed task context.
> 
> And I still can't understand how, but let me repeat that I don't understand
> this code at all.
> 
> > To quote Michael S. Tsirkin:
> > : Getting an error from __get_user and friends is handled gracefully.
> > : Getting zero instead of a real value will cause userspace
> > : memory corruption.
> 
> Which userspace memory corruption? We are going to kill the dev->mm owner,
> the task which did ioctl(VHOST_SET_OWNER) and (at first glance) the task
> who communicates with the callbacks fired by vhost_worker().
> 
> Michael, could you please spell why should we care?

I am concerned that
- oom victim is sharing memory with another task
- getting incorrect value from ring read makes vhost
  change that shared memory


Also, I don't see where do we kill the task that communicates with the
callbacks.


Having said all that, how about we just add some kind of per-mm
notifier list, and let vhost know that owner is going away so
it should stop looking at memory?

Seems cleaner than looking at flags at each memory access,
since vhost has its own locking.


> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -492,6 +492,14 @@ static bool __oom_reap_task(struct task_struct *tsk)
> >  		goto unlock_oom;
> >  	}
> >
> > +	/*
> > +	 * Tell all users of get_user_mm/copy_from_user_mm that the content
> > +	 * is no longer stable. No barriers really needed because unmapping
> > +	 * should imply barriers already and the reader would hit a page fault
> > +	 * if it stumbled over a reaped memory.
> > +	 */
> > +	set_bit(MMF_UNSTABLE, &mm->flags);
> 
> And this is racy anyway.
> 
> Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
