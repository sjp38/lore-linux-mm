Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCB266B0268
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 11:34:45 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q12so11825161plk.16
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 08:34:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m7si15088871pfh.357.2017.12.21.08.34.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Dec 2017 08:34:44 -0800 (PST)
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second allocation
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171211115723.GC4779@dhcp22.suse.cz>
	<201712132006.DDE78145.FMFJSOOHVFQtOL@I-love.SAKURA.ne.jp>
	<201712192336.GHG30208.MLFSVJQOHOFtOF@I-love.SAKURA.ne.jp>
	<20171219145508.GZ2787@dhcp22.suse.cz>
In-Reply-To: <20171219145508.GZ2787@dhcp22.suse.cz>
Message-Id: <201712220034.HIC12926.OtQJOOFFVFMSLH@I-love.SAKURA.ne.jp>
Date: Fri, 22 Dec 2017 00:34:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

Michal Hocko wrote:
> On Tue 19-12-17 23:36:02, Tetsuo Handa wrote:
> > If http://lkml.kernel.org/r/20171219114012.GK2787@dhcp22.suse.cz ,
> > is direction below acceptable?
> 
> The same applies here. You are touching the way how the memory reserves
> are access in non-trivial way. You better have a very good reason for
> that. So far you keep playing with different corner cases while you keep
> showing that you do not really want to understand a bigger picture. This
> can end up in regressions easily.

Any OOM-killed thread is allowed to use memory reserves up to ALLOC_OOM
watermark. How can allowing all OOM-killed threads to try ALLOC_OOM
watermark cause regressions?

Commit cd04ae1e2dc8e365 ("mm, oom: do not rely on TIF_MEMDIE for memory
reserves access") changed from only TIF_MEMDIE thread to all threads in
one thread group. But we don't call it a regression.

My proposal is nothing but changes from all threads in one thread group to
all threads in all thread groups (which were killed due to sharing the
victim's mm). And how can we call it a regression?

>                                   Let me repeat something I've said a
> long ago. We do not optimize for corner cases. We want to survive but if
> an alternative is to kill another task then we can live with that.
>  

Setting MMF_OOM_SKIP before all OOM-killed threads try memory reserves
leads to needlessly selecting more OOM victims.

Unless any OOM-killed thread fails to satisfy allocation even with ALLOC_OOM,
no OOM-killed thread needs to select more OOM victims. Commit 696453e66630ad45
("mm, oom: task_will_free_mem should skip oom_reaped tasks") obviously broke
it, which is exactly a regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
