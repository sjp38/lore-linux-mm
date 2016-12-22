Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 865686B0419
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 08:33:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so358179473pfb.6
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:33:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b1si30811746pld.129.2016.12.22.05.33.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 05:33:50 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
	<201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
	<20161219122738.GB427@tigerII.localdomain>
	<20161220153948.GA575@tigerII.localdomain>
	<201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
In-Reply-To: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
Message-Id: <201612222233.CBC56295.LFOtMOVQSJOFHF@I-love.SAKURA.ne.jp>
Date: Thu, 22 Dec 2016 22:33:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky@gmail.com
Cc: mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

Tetsuo Handa wrote:
> Now, what options are left other than replacing !mutex_trylock(&oom_lock)
> with mutex_lock_killable(&oom_lock) which also stops wasting CPU time?
> Are we waiting for offloading sending to consoles?

 From http://lkml.kernel.org/r/20161222115057.GH6048@dhcp22.suse.cz :
> > Although I don't know whether we agree with mutex_lock_killable(&oom_lock)
> > change, I think this patch alone can go as a cleanup.
> 
> No, we don't agree on that part. As this is a printk issue I do not want
> to workaround it in the oom related code. That is just ridiculous. The
> very same issue would be possible due to other continous source of log
> messages.

I don't think so. Lockup caused by printk() is printk's problem. But printk
is not the only source of lockup. If CONFIG_PREEMPT=y, it is possible that
a thread which held oom_lock can sleep for unbounded period depending on
scheduling priority. Then, you call such latency as scheduler's problem?
mutex_lock_killable(&oom_lock) change helps coping with whatever delays
OOM killer/reaper might encounter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
