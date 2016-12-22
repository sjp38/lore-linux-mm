Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECDD6B03F5
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:53:53 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so35331742wmw.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 02:53:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1si31333425wjf.235.2016.12.22.02.53.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 02:53:52 -0800 (PST)
Date: Thu, 22 Dec 2016 11:53:50 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161222105350.GJ25166@pathway.suse.cz>
References: <20161214181850.GC16763@dhcp22.suse.cz>
 <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
 <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
 <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, mhocko@suse.com, linux-mm@kvack.org

On Thu 2016-12-22 19:27:17, Tetsuo Handa wrote:
> Sergey Senozhatsky wrote:
> > On (12/19/16 21:27), Sergey Senozhatsky wrote:
> > [..]
> > >
> > > I'll finish re-basing the patch set tomorrow.
> > >
> > 
> > pushed
> > 
> > https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred
> > 
> > not tested. will test and send out the patch set tomorrow.
> > 
> >      -ss
> 
> Thank you. I tried "[PATCHv6 0/7] printk: use printk_safe to handle printk()
> recursive calls" at https://lkml.org/lkml/2016/12/21/232 on top of linux.git
> as of commit 52bce91165e5f2db "splice: reinstate SIGPIPE/EPIPE handling", but
> it turned out that your patch set does not solve this problem.
>
> I was assuming that sending to consoles from printk() is offloaded to a kernel
> thread dedicated for that purpose, but your patch set does not do it. As a result,
> somebody who called out_of_memory() is still preempted by other threads consuming
> CPU time due to cond_resched() from console_unlock() as demonstrated by below patch.

Ah, it was a misunderstanding. The "printk_safe" patchset allows to
call printk() from inside some areas guarded by logbuf_lock. By other
words, it allows to print errors from inside printk() code. I does
not solve the soft-/live-locks.

We need the async printk patchset here. It will allow to offload the
console handling to the kthread. AFAIK, Sergey wanted to rebase it
on top of the printk_safe patchset. I am not sure when he want or
will have time to do so, though.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
