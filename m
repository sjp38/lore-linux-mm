Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 558736B02B2
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 17:07:42 -0400 (EDT)
Date: Thu, 5 Aug 2010 14:07:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-Id: <20100805140755.501af8a7.akpm@linux-foundation.org>
In-Reply-To: <20100726050827.GA24047@sli10-desk.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
	<20100723234938.88EB.A69D9226@jp.fujitsu.com>
	<20100726050827.GA24047@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 26 Jul 2010 13:08:27 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> The zone->lru_lock is heavily contented in workload where activate_page()
> is frequently used. We could do batch activate_page() to reduce the lock
> contention. The batched pages will be added into zone list when the pool
> is full or page reclaim is trying to drain them.
> 
> For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> processes shared map to the file. Each process read access the whole file and
> then exit. The process exit will do unmap_vmas() and cause a lot of
> activate_page() call. In such workload, we saw about 58% total time reduction
> with below patch.

What happened to the 2% regression that earlier changelogs mentioned?

afacit the patch optimises the rare munmap() case.  But what effect
does it have upon the common case?  How do we know that it is a net
benefit?

Because the impact on kernel footprint is awful.  x86_64 allmodconfig:

   text    data     bss     dec     hex filename
   5857    1426    1712    8995    2323 mm/swap.o
   6245    1587    1840    9672    25c8 mm/swap.o

and look at x86_64 allnoconfig:

   text    data     bss     dec     hex filename
   2344     768       4    3116     c2c mm/swap.o
   2632     896       4    3532     dcc mm/swap.o

that's a uniprocessor kernel where none of this was of any use!

Looking at the patch, I'm not sure where all this bloat came from.  But
the SMP=n case is pretty bad and needs fixing, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
