Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC156B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 20:32:27 -0400 (EDT)
Date: Thu, 1 Oct 2009 09:45:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 0/2] memcg: replace memcg's per cpu status counter
 with array counter like vmstat
Message-Id: <20091001094514.c9d2b3d9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Sep 2009 19:04:17 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hi,
> 
> In current implementation, memcg uses its own percpu counters for counting
> evetns and # of RSS, CACHES. Now, counter is maintainer per cpu without
> any synchronization as vm_stat[] or percpu_counter. So, this is
>  update-is-fast-but-read-is-slow conter.
> 
> Because "read" for these counter was only done by memory.stat file, I thought
> read-side-slowness was acceptable. Amount of memory usage, which affects
> memory limit check, can be read by memory.usage_in_bytes. It's maintained
> by res_counter.
> 
> But in current -rc, root memcg's memory usage is calcualted by this per cpu
> counter and read side slowness may be trouble if it's frequently read.
> 
> And, in recent discusstion, I wonder we should maintain NR_DIRTY etc...
> in memcg. So, slow-read-counter will not match our requirements, I guess.
> I want some counter like vm_stat[] in memcg.
> 
I see your concern.

But IMHO, it would be better to explain why we need a new percpu array counter
instead of using array of percpu_counter(size or consolidation of related counters ?),
IOW, what the benefit of percpu array counter is.


Thanks,
Daisuke Nishimura.

> This 2 patches are for using counter like vm_stat[] in memcg.
> Just an idea level implementaion but I think this is not so bad.
> 
> I confirmed this patch works well. I'm now thinking how to test performance...
> 
> Any comments are welcome. 
> This patch is onto mmotm + some myown patches...so...this is just an RFC.
> 
> Regards,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
