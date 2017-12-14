Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC1636B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:12:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y62so4808384pfd.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:12:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o3si3187912pld.695.2017.12.14.06.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 06:12:44 -0800 (PST)
Date: Thu, 14 Dec 2017 06:12:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: d1fc031747 ("sched/wait: assert the wait_queue_head lock is
 .."):  EIP: __wake_up_common
Message-ID: <20171214141240.GD30288@bombadil.infradead.org>
References: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com>
 <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
 <20171214125809.GB30288@bombadil.infradead.org>
 <20171214131037.GD10791@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214131037.GD10791@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com, Stephen Rothwell <sfr@canb.auug.org.au>

On Thu, Dec 14, 2017 at 02:10:37PM +0100, Christoph Hellwig wrote:
> On Thu, Dec 14, 2017 at 04:58:09AM -0800, Matthew Wilcox wrote:
> > Looks pretty clear to me that userfaultfd is also abusing the wake_up_locked
> > interfaces:
> > 
> >         spin_lock(&ctx->fault_pending_wqh.lock);
> >         __wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
> >         __wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
> >         spin_unlock(&ctx->fault_pending_wqh.lock);
> > 
> > Sure, it's locked, but not by the lock you thought it was going to be.
> > 
> > There doesn't actually appear to be a bug here; fault_wqh is always serialised
> > by fault_pending_wqh.lock, but lockdep can't know that.  I think this patch
> > will solve the problem.
> 
> Or userfaultfd could just always use the waitqueue lock, similar to what
> we are doing in epoll.
> 
> But unless someone care about micro-optimizatations I'm tempted to
> add your patch to the next iteration of the series.

userfaultfd is using the waitqueue lock -- it just has two waitqueues
that it's protecting with the same lock.

If the patch goes through as-is, try this changelog:

[PATCH] userfaultfd: Use fault_wqh lock

userfaultfd was using the fault_pending_wq lock to protect both
fault_pending_wq and fault_wqh.  With Christoph's addition of a lockdep
assert to the wait queue code, that will trigger warnings (although there
is no bug).  Remove the warning by using __wake_up which will take the
fault_wqh lock.  This lock now nests inside the fault_pending_wqh lock,
but that's not a problem since it was entireyl unused before.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
