Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f43.google.com (mail-vk0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 317946B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 10:57:09 -0500 (EST)
Received: by mail-vk0-f43.google.com with SMTP id c3so171833925vkb.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:57:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l197si19374944vke.15.2016.03.01.07.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 07:57:08 -0800 (PST)
Date: Tue, 1 Mar 2016 17:57:04 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160301175431-mutt-send-email-mst@redhat.com>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
 <20160301155212.GJ9461@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301155212.GJ9461@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2016 at 04:52:12PM +0100, Michal Hocko wrote:
> [CCing vhost-net maintainer]
> 
> On Mon 29-02-16 20:02:09, Vladimir Davydov wrote:
> > An mm_struct may be pinned by a file. An example is vhost-net device
> > created by a qemu/kvm (see vhost_net_ioctl -> vhost_net_set_owner ->
> > vhost_dev_set_owner).
> 
> The more I think about that the more I am wondering whether this is
> actually OK and correct. Why does the driver have to pin the address
> space? Nothing really prevents from parallel tearing down of the address
> space anyway so the code cannot expect all the vmas to stay. Would it be
> enough to pin the mm_struct only?

I'll need to research this. It's a fact that as long as the
device is not stopped, vhost can attempt to access
the address space.

> I am not sure I understand the code properly but what prevents from
> the situation when a VHOST_SET_OWNER caller dies without calling
> VHOST_RESET_OWNER and so the mm would be pinned indefinitely?
> 
> [Keeping the reset of the email for reference]

We have:

static const struct file_operations vhost_net_fops = {
        .owner          = THIS_MODULE,
        .release        = vhost_net_release,
...
};

When caller dies and after fds are closed,
vhost_net_release calls vhost_dev_cleanup and that
drops the mm reference.

> > If such process gets OOM-killed, the reference to
> > its mm_struct will only be released from exit_task_work -> ____fput ->
> > __fput -> vhost_net_release -> vhost_dev_cleanup, which is called after
> > exit_mmap, where TIF_MEMDIE is cleared. As a result, we can start
> > selecting the next victim before giving the last one a chance to free
> > its memory. In practice, this leads to killing several VMs along with
> > the fattest one.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > ---
> >  kernel/exit.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/kernel/exit.c b/kernel/exit.c
> > index fd90195667e1..cc50e12165f7 100644
> > --- a/kernel/exit.c
> > +++ b/kernel/exit.c
> > @@ -434,8 +434,6 @@ static void exit_mm(struct task_struct *tsk)
> >  	task_unlock(tsk);
> >  	mm_update_next_owner(mm);
> >  	mmput(mm);
> > -	if (test_thread_flag(TIF_MEMDIE))
> > -		exit_oom_victim(tsk);
> >  }
> >  
> >  static struct task_struct *find_alive_thread(struct task_struct *p)
> > @@ -746,6 +744,8 @@ void do_exit(long code)
> >  		disassociate_ctty(1);
> >  	exit_task_namespaces(tsk);
> >  	exit_task_work(tsk);
> > +	if (test_thread_flag(TIF_MEMDIE))
> > +		exit_oom_victim(tsk);
> >  	exit_thread();
> >  
> >  	/*
> > -- 
> > 2.1.4
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
