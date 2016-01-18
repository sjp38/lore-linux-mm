Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 78F3D6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 12:13:33 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so422610718pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:13:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id w83si35732283pfi.121.2016.01.18.09.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 09:13:32 -0800 (PST)
Date: Mon, 18 Jan 2016 18:13:28 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V2] sched/numa: Fix use-after-free bug in the
 task_numa_compare
Message-ID: <20160118171328.GT6357@twins.programming.kicks-ass.net>
References: <20160118143345.GQ6357@twins.programming.kicks-ass.net>
 <1453130661-16573-1-git-send-email-gavin.guo@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453130661-16573-1-git-send-email-gavin.guo@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gavin.guo@canonical.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jay.vosburgh@canonical.com, liang.chen@canonical.com, mgorman@suse.de, mingo@redhat.com, riel@redhat.com

On Mon, Jan 18, 2016 at 11:24:21PM +0800, gavin.guo@canonical.com wrote:
> From: Gavin Guo <gavin.guo@canonical.com>
> 
> The following message can be observed on the Ubuntu v3.13.0-65 with KASan
> backported:

<snip>

> As commit 1effd9f19324 ("sched/numa: Fix unsafe get_task_struct() in
> task_numa_assign()") points out, the rcu_read_lock() cannot protect the
> task_struct from being freed in the finish_task_switch(). And the bug
> happens in the process of calculation of imp which requires the access of
> p->numa_faults being freed in the following path:
> 
> do_exit()
>         current->flags |= PF_EXITING;
>     release_task()
>         ~~delayed_put_task_struct()~~
>     schedule()
>     ...
>     ...
> rq->curr = next;
>     context_switch()
>         finish_task_switch()
>             put_task_struct()
>                 __put_task_struct()
> 		    task_numa_free()
> 
> The fix here to get_task_struct() early before end of dst_rq->lock to
> protect the calculation process and also put_task_struct() in the
> corresponding point if finally the dst_rq->curr somehow cannot be
> assigned.
> 
> v1->v2:
> - Fix coding style suggested by Peter Zijlstra.
> 
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>

Argh, sorry for not noticing before; this SoB chain is not valid.

Gavin wrote (per From) and send me the patch (per actual email headers),
so Liang never touched it.

Should that be a reviewed-by for him?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
