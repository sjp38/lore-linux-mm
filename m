Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F39A6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:45:14 -0500 (EST)
Date: Tue, 10 Nov 2009 14:44:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
Message-Id: <20091110144438.dbab0ba8.akpm@linux-foundation.org>
In-Reply-To: <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	<20091104234923.GA25306@redhat.com>
	<alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>
	<alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
	<20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 10:11:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 5 Nov 2009 10:36:06 -0500 (EST)
> Christoph Lameter <cl@linux-foundation.org> wrote:
> 
> > From: Christoph Lameter <cl@linux-foundation.org>
> > Subject: Make mm counters per cpu V2
> > 
> > Changing the mm counters to per cpu counters is possible after the introduction
> > of the generic per cpu operations (currently in percpu and -next).
> > 
> > With that the contention on the counters in mm_struct can be avoided. The
> > USE_SPLIT_PTLOCKS case distinction can go away. Larger SMP systems do not
> > need to perform atomic updates to mm counters anymore. Various code paths
> > can be simplified since per cpu counter updates are fast and batching
> > of counter updates is no longer needed.
> > 
> > One price to pay for these improvements is the need to scan over all percpu
> > counters when the actual count values are needed.
> > 
> > V1->V2
> > - Remove useless and buggy per cpu counter initialization.
> >   alloc_percpu already zeros the values.
> > 
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> > 
> Thanks. My small concern is read-side.

Me too.

For example, with 1000 possible CPUs (possible, not present and not
online), and 1000 processes, ps(1) will have to wallow through a
million cachelines in task_statm().

And then we have get_mm_rs(), which now will hit 1000 cachelines.  And
get_mm_rs() is called (via
account_user_time()->acct_update_integrals()) from the clock tick.

Adding a thousand cache misses to the timer interrupt is the sort of
thing which makes people unhappy?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
