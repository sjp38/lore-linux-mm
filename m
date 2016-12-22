Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26E746B041B
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 08:41:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so359350850pfx.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:41:12 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id z16si30838247pfi.113.2016.12.22.05.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 05:41:10 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id g1so18407066pgn.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:41:10 -0800 (PST)
Date: Thu, 22 Dec 2016 22:40:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161222134029.GD413@tigerII.localdomain>
References: <20161214181850.GC16763@dhcp22.suse.cz>
 <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
 <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
 <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222105350.GJ25166@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222105350.GJ25166@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, sergey.senozhatsky@gmail.com, mhocko@suse.com, linux-mm@kvack.org

On (12/22/16 11:53), Petr Mladek wrote:
> > Thank you. I tried "[PATCHv6 0/7] printk: use printk_safe to handle printk()
> > recursive calls" at https://lkml.org/lkml/2016/12/21/232 on top of linux.git
> > as of commit 52bce91165e5f2db "splice: reinstate SIGPIPE/EPIPE handling", but
> > it turned out that your patch set does not solve this problem.
> >
> > I was assuming that sending to consoles from printk() is offloaded to a kernel
> > thread dedicated for that purpose, but your patch set does not do it. As a result,
> > somebody who called out_of_memory() is still preempted by other threads consuming
> > CPU time due to cond_resched() from console_unlock() as demonstrated by below patch.
> 
> Ah, it was a misunderstanding. The "printk_safe" patchset allows to
> call printk() from inside some areas guarded by logbuf_lock. By other
> words, it allows to print errors from inside printk() code. I does
> not solve the soft-/live-locks.

ineeed.

> We need the async printk patchset here. It will allow to offload the
> console handling to the kthread. AFAIK, Sergey wanted to rebase it
> on top of the printk_safe patchset. I am not sure when he want or
> will have time to do so, though.

sure. this is still the case. and in fact my tree here
https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred

contains both patch sets: 9 patche in total (rebased agains linux-next
20161221).

first 7 patches are printk-safe, the last 2 -- async printk.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
