Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCDF6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 05:44:01 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so230576757wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 02:44:00 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ao8si8246075wjc.186.2015.09.23.02.43.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 02:44:00 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so229647245wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 02:43:59 -0700 (PDT)
Date: Wed, 23 Sep 2015 11:43:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: remove task_lock protecting comm printing
Message-ID: <20150923094358.GB8644@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
 <20150923080632.GD12318@esperanza>
 <20150923091354.GA640@swordfish>
 <20150923093021.GE12318@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923093021.GE12318@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed 23-09-15 12:30:22, Vladimir Davydov wrote:
> On Wed, Sep 23, 2015 at 06:13:54PM +0900, Sergey Senozhatsky wrote:
> > On (09/23/15 11:06), Vladimir Davydov wrote:
> > > Hi,
> > > 
> > > On Tue, Sep 22, 2015 at 04:30:13PM -0700, David Rientjes wrote:
> > > > The oom killer takes task_lock() in a couple of places solely to protect
> > > > printing the task's comm.
> > > > 
> > > > A process's comm, including current's comm, may change due to
> > > > /proc/pid/comm or PR_SET_NAME.
> > > > 
> > > > The comm will always be NULL-terminated, so the worst race scenario would
> > > > only be during update.  We can tolerate a comm being printed that is in
> > > > the middle of an update to avoid taking the lock.
> > > > 
> > > > Other locations in the kernel have already dropped task_lock() when
> > > > printing comm, so this is consistent.
> > > 
> > > Without the protection, can't reading task->comm race with PR_SET_NAME
> > > as described below?
> > 
> > the previous name was already null terminated,
> 
> Yeah, but if the old name is shorter than the new one, set_task_comm()
> overwrites the terminating null of the old name before writing the new
> terminating null, so there is a short time window during which tsk->comm
> might be not null-terminated, no?

Not really:
        case PR_SET_NAME:
                comm[sizeof(me->comm) - 1] = 0;
                if (strncpy_from_user(comm, (char __user *)arg2,
                                      sizeof(me->comm) - 1) < 0)
                        return -EFAULT;

So it first writes the terminating 0 and only then starts copying.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
