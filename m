Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0F76B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:07:56 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so37228802pac.2
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 03:07:56 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fu3si9473005pbd.138.2015.09.23.03.07.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 03:07:55 -0700 (PDT)
Date: Wed, 23 Sep 2015 13:07:40 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm, oom: remove task_lock protecting comm printing
Message-ID: <20150923100740.GF12318@esperanza>
References: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
 <20150923080632.GD12318@esperanza>
 <20150923091354.GA640@swordfish>
 <20150923093021.GE12318@esperanza>
 <20150923094358.GB8644@dhcp22.suse.cz>
 <20150923095022.GB640@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150923095022.GB640@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed, Sep 23, 2015 at 06:50:22PM +0900, Sergey Senozhatsky wrote:
> On (09/23/15 11:43), Michal Hocko wrote:
> [..]
> > > > the previous name was already null terminated,
> > > 
> > > Yeah, but if the old name is shorter than the new one, set_task_comm()
> > > overwrites the terminating null of the old name before writing the new
> > > terminating null, so there is a short time window during which tsk->comm
> > > might be not null-terminated, no?
> > 
> > Not really:
> >         case PR_SET_NAME:
> >                 comm[sizeof(me->comm) - 1] = 0;
> >                 if (strncpy_from_user(comm, (char __user *)arg2,
> >                                       sizeof(me->comm) - 1) < 0)
> >                         return -EFAULT;
> > 
> > So it first writes the terminating 0 and only then starts copying.

It writes 0 to a temporary buffer, not to tsk->comm, so I don't think
it's related. However, reading tsk->comm w/o locking must be safe
anyway, because tsk->comm[TASK_COMM_LEN-1] is always 0 (inherited from
init_task) and it never gets overwritten, because __set_task_comm() uses
strlcpy().

> 
> right.
> 
> hm, shouldn't set_task_comm()->__set_task_comm() do the same?

I don't think so - see above.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
