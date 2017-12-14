Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFA9C6B025E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:10:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l33so3201152wrl.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:10:39 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z12si3275208wrb.55.2017.12.14.05.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 05:10:38 -0800 (PST)
Date: Thu, 14 Dec 2017 14:10:37 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: d1fc031747 ("sched/wait: assert the wait_queue_head lock is
	.."):  EIP: __wake_up_common
Message-ID: <20171214131037.GD10791@lst.de>
References: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com> <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org> <20171214125809.GB30288@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214125809.GB30288@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com, Stephen Rothwell <sfr@canb.auug.org.au>

On Thu, Dec 14, 2017 at 04:58:09AM -0800, Matthew Wilcox wrote:
> On Wed, Dec 13, 2017 at 05:03:00PM -0800, Andrew Morton wrote:
> > >     sched/wait: assert the wait_queue_head lock is held in __wake_up_common
> > >     
> > >     Better ensure we actually hold the lock using lockdep than just commenting
> > >     on it.  Due to the various exported _locked interfaces it is far too easy
> > >     to get the locking wrong.
> > 
> > I'm probably sitting on an older version.  I've dropped
> > 
> > epoll: use the waitqueue lock to protect ep->wq
> > sched/wait: assert the wait_queue_head lock is held in __wake_up_common
> 
> Looks pretty clear to me that userfaultfd is also abusing the wake_up_locked
> interfaces:
> 
>         spin_lock(&ctx->fault_pending_wqh.lock);
>         __wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
>         __wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
>         spin_unlock(&ctx->fault_pending_wqh.lock);
> 
> Sure, it's locked, but not by the lock you thought it was going to be.
> 
> There doesn't actually appear to be a bug here; fault_wqh is always serialised
> by fault_pending_wqh.lock, but lockdep can't know that.  I think this patch
> will solve the problem.

Or userfaultfd could just always use the waitqueue lock, similar to what
we are doing in epoll.

But unless someone care about micro-optimizatations I'm tempted to
add your patch to the next iteration of the series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
