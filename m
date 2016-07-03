Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1D46B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 11:30:17 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id i63so11292541vkb.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 08:30:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g188si1390253qkd.16.2016.07.03.08.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 08:30:16 -0700 (PDT)
Date: Sun, 3 Jul 2016 18:30:11 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160703182254-mutt-send-email-mst@redhat.com>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160703151829.GA28667@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

On Sun, Jul 03, 2016 at 05:18:29PM +0200, Oleg Nesterov wrote:
> On 07/03, Michael S. Tsirkin wrote:
> >
> > On Sun, Jul 03, 2016 at 03:47:19PM +0200, Oleg Nesterov wrote:
> > > On 07/01, Michal Hocko wrote:
> > > >
> > > > From: Michal Hocko <mhocko@suse.com>
> > > >
> > > > vhost driver relies on copy_from_user/get_user from a kernel thread.
> > > > This makes it impossible to reap the memory of an oom victim which
> > > > shares mm with the vhost kernel thread because it could see a zero
> > > > page unexpectedly and theoretically make an incorrect decision visible
> > > > outside of the killed task context.
> > >
> > > And I still can't understand how, but let me repeat that I don't understand
> > > this code at all.
> > >
> > > > To quote Michael S. Tsirkin:
> > > > : Getting an error from __get_user and friends is handled gracefully.
> > > > : Getting zero instead of a real value will cause userspace
> > > > : memory corruption.
> > >
> > > Which userspace memory corruption? We are going to kill the dev->mm owner,
> > > the task which did ioctl(VHOST_SET_OWNER) and (at first glance) the task
> > > who communicates with the callbacks fired by vhost_worker().
> > >
> > > Michael, could you please spell why should we care?
> >
> > I am concerned that
> > - oom victim is sharing memory with another task
> > - getting incorrect value from ring read makes vhost
> >   change that shared memory
> 
> Well, we are going to kill all tasks which share this memory. I mean, ->mm.
> If "sharing memory with another task" means, say, a file, then this memory
> won't be unmapped (if shared).
> 
> So let me ask again... Suppose, say, QEMU does VHOST_SET_OWNER and then we
> unmap its (anonymous/non-shared) memory. Who else's memory can be corrupted?

As you say, I mean anyone who shares memory with QEMU through a file.
IIUC current users that do this are all stateless so
even if they crash this is not a big deal, but it seems
wrong to assume this will be like this forever.

> Sorry, I simply do not know what vhost does, quite possibly a stupid question.
> 
> > Having said all that, how about we just add some kind of per-mm
> > notifier list, and let vhost know that owner is going away so
> > it should stop looking at memory?
> >
> > Seems cleaner than looking at flags at each memory access,
> > since vhost has its own locking.
> 
> Agreed... although of course I do not understand how this should work.

Add a linked list of callbacks in in struct mm_struct. vhost would add itself there.
In callback, set private_data for all vqs to NULL under vq mutex.


> But
> looks better in any case..
> 
> Or perhaps we can change oom_kill_process() to send SIGKILL to kthreads as
> well, this should not have any effect unless kthread does allow_signal(SIGKILL),
> then we can change vhost_worker() to catch SIGKILL and react somehow. Not sure
> this is really possible.
> 
> Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
