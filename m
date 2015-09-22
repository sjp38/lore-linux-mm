Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC656B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:48:55 -0400 (EDT)
Received: by ioii196 with SMTP id i196so16911972ioi.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 07:48:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si2928212ioi.23.2015.09.22.07.48.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 07:48:54 -0700 (PDT)
Date: Tue, 22 Sep 2015 16:45:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150922144551.GA31154@redhat.com>
References: <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com> <201509220151.CHF17629.LFFJSHQVOMtOFO@I-love.SAKURA.ne.jp> <20150922124303.GA24570@redhat.com> <201509222330.JDI64510.FOLOFQStMVFJOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509222330.JDI64510.FOLOFQStMVFJOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 09/22, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > On 09/22, Tetsuo Handa wrote:
> > > 	rcu_read_lock();
> > > 	for_each_process_thread(g, p) {
> > > 		if (likely(!fatal_signal_pending(p)))
> > > 			continue;
> > > 		task_lock(p);
> > > 		mm = p->mm;
> > > 		if (mm && mm->mmap && !mm->mmap_zapped && down_read_trylock(&mm->mmap_sem)) {
> >                                        ^^^^^^^^^^^^^^^
> >
> > We do not want mm->mmap_zapped, it can't work. We need mm->needs_zap
> > set by oom_kill_process() and cleared after zap_page_range().
> >
> > Because otherwise we can not handle CLONE_VM correctly. Suppose that
> > an innocent process P does vfork() and the child is killed but not
> > exited yet. mm_zapper() can find the child, do zap_page_range(), and
> > surprise its alive parent P which uses the same ->mm.
>
> kill(P's-child, SIGKILL) does not kill P sharing the same ->mm.
> Thus, mm_zapper() can be used for only OOM-kill case

Yes, and only if we know for sure that all tasks which can use
this ->mm were killed.

> and
> test_tsk_thread_flag(p, TIF_MEMDIE) should be used than
> fatal_signal_pending(p).

No. For example, just look at mark_oom_victim() at the start of
out_of_memory().

> > Tetsuo, can't we do something simple which "obviously can't hurt at
> > least" and then discuss the potential improvements?
>
> No problem. I can wait for your version.

All I wanted to say is that this all is a bit more complicated than it
looks at first glance.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
