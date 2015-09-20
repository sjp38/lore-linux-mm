Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 54B896B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 09:19:40 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so35890918qkf.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 06:19:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s7si17121097qge.4.2015.09.20.06.19.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 06:19:39 -0700 (PDT)
Date: Sun, 20 Sep 2015 15:16:39 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150920131639.GC2104@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <20150919155819.GB9094@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150919155819.GB9094@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 09/19, Michal Hocko wrote:
>
> On Sat 19-09-15 17:03:16, Oleg Nesterov wrote:
> >
> > Stupid idea. Can't we help the memory hog to free its memory? This is
> > orthogonal to other improvements we can do.
> >
> > Please don't tell me the patch below is ugly, incomplete and suboptimal
> > in many ways, I know ;) I am not sure it is even correct. Just to explain
> > what I mean.
>
> Unmapping the memory for the oom victim has been already mentioned as a
> way to improve the OOM killer behavior. Nobody has implemented that yet
> though unfortunately. I have that on my TODO list since we have
> discussed it with Mel at LSF.

OK, good. So perhaps we should try to do this.

>
> > Perhaps oom_unmap_func() should only zap the anonymous vmas... and there
> > are a lot of other details which should be discussed if this can make any
> > sense.
>
> I have just returned from an internal conference so my head is
> completely cabbaged. I will have a look on Monday. From a quick look
> the idea is feasible. You cannot rely on the worker context because
> workqueues might be completely stuck with at this stage.

Yes this is true. See another email, probably oom-kill.c needs its own
kthread.

And again, we should actually try to avoid queue_work or queue_kthread_work
in any case. But not in the initial implementation. And initial implementation
could use workqueues, I think. I the likely case system_unbound_wq pool
should have an idle thread.

> You also cannot
> do take mmap_sem directly because that might be held already so you need
> a try_lock instead.

Still can't understand this part. See other emails, perhaps I missed
something.

> Focusing on anonymous vmas first sounds like a good
> idea to me because that would be simpler I guess.

And safer.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
