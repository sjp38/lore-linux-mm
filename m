Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 52BCF6B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:25:56 -0400 (EDT)
Date: Fri, 23 Jul 2010 17:25:52 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-ID: <20100723152552.GE8127@basil.fritz.box>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
 <20100723234938.88EB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723234938.88EB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 24, 2010 at 12:10:49AM +0900, KOSAKI Motohiro wrote:
> > The zone->lru_lock is heavily contented in workload where activate_page()
> > is frequently used. We could do batch activate_page() to reduce the lock
> > contention. The batched pages will be added into zone list when the pool
> > is full or page reclaim is trying to drain them.
> > 
> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> > processes shared map to the file. Each process read access the whole file and
> > then exit. The process exit will do unmap_vmas() and cause a lot of
> > activate_page() call. In such workload, we saw about 58% total time reduction
> > with below patch.
> 
> I'm not sure this. Why process exiting on your workload call unmap_vmas?

Trick question? 

Getting rid of a mm on process exit requires unmapping the vmas.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
