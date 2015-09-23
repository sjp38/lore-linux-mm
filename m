Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B6FE16B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 05:30:37 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so1790355pac.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 02:30:37 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pn2si9258653pac.121.2015.09.23.02.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 02:30:37 -0700 (PDT)
Date: Wed, 23 Sep 2015 12:30:22 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm, oom: remove task_lock protecting comm printing
Message-ID: <20150923093021.GE12318@esperanza>
References: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
 <20150923080632.GD12318@esperanza>
 <20150923091354.GA640@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150923091354.GA640@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed, Sep 23, 2015 at 06:13:54PM +0900, Sergey Senozhatsky wrote:
> On (09/23/15 11:06), Vladimir Davydov wrote:
> > Hi,
> > 
> > On Tue, Sep 22, 2015 at 04:30:13PM -0700, David Rientjes wrote:
> > > The oom killer takes task_lock() in a couple of places solely to protect
> > > printing the task's comm.
> > > 
> > > A process's comm, including current's comm, may change due to
> > > /proc/pid/comm or PR_SET_NAME.
> > > 
> > > The comm will always be NULL-terminated, so the worst race scenario would
> > > only be during update.  We can tolerate a comm being printed that is in
> > > the middle of an update to avoid taking the lock.
> > > 
> > > Other locations in the kernel have already dropped task_lock() when
> > > printing comm, so this is consistent.
> > 
> > Without the protection, can't reading task->comm race with PR_SET_NAME
> > as described below?
> 
> the previous name was already null terminated,

Yeah, but if the old name is shorter than the new one, set_task_comm()
overwrites the terminating null of the old name before writing the new
terminating null, so there is a short time window during which tsk->comm
might be not null-terminated, no?

Thanks,
Vladimir

> so it should be
> 
> 	[name\0old_name\0]
> 
> 	-ss
> 
> > 
> > Let T->comm[16] = "name\0rubbish1234"
> > 
> > CPU1                                    CPU2
> > ----                                    ----
> > set_task_comm(T, "longname\0")
> >   T->comm[0] = 'l'
> >   T->comm[1] = 'o'
> >   T->comm[2] = 'n'
> >   T->comm[3] = 'g'
> >   T->comm[4] = 'n'
> >                                         printk("%s\n", T->comm)
> >                                           T->comm = "longnrubbish1234"
> >                                           OOPS: the string is not
> >                                                 nil-terminated!
> >   T->comm[5] = 'a'
> >   T->comm[6] = 'm'
> >   T->comm[7] = 'e'
> >   T->comm[8] = '\0'
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
