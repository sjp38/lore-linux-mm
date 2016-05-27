Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF12C6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 04:33:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so21611788lfz.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:33:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a199si10697217wmd.114.2016.05.27.01.33.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 01:33:53 -0700 (PDT)
Date: Fri, 27 May 2016 10:33:51 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 13/20] hung_task: Convert hungtaskd into kthread
 worker API
Message-ID: <20160527083351.GJ23103@pathway.suse.cz>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
 <1460646879-617-14-git-send-email-pmladek@suse.com>
 <47fb67eb-1756-7189-0245-f59c5a4c5f41@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47fb67eb-1756-7189-0245-f59c5a4c5f41@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-watchdog@vger.kernel.org

On Thu 2016-05-26 06:56:38, Tetsuo Handa wrote:
> On 2016/04/15 0:14, Petr Mladek wrote:
> > This patch converts hungtaskd() in kthread worker API because
> > it modifies the priority.
> > 
> > This patch moves one iteration of the main cycle into a self-queuing
> > delayed kthread work. It does not longer check if it was called
> > earlier. Instead, the work is scheduled only when needed. This
> > requires storing the time of the last check into a global
> > variable.
> 
> Is it guaranteed that that work is fired when timeout expires? It is
> common that tasks sleep in uninterruptible state due to waiting for
> memory allocations. Unless a dedicated worker like vmstat_wq is used
> for watchdog, I think it might fail to report such tasks due to all
> workers being busy but the system is under OOM.
> 
>   vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);

We are on the safe side. You might be confused because the kthread
worker API has similar semantic like workqueues (using workers and
works).  The main difference is that each kthread worker has its
own dedicated kthread. There are no pools, no dynamic assignment,
and no further allocations needed.

Thanks a lot for looking at it.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
