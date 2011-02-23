Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1537E8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 03:32:09 -0500 (EST)
Date: Wed, 23 Feb 2011 09:32:06 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH 0/5] blk-throttle: writeback and swap IO control
Message-ID: <20110223083206.GA2174@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
 <20110222193403.GG28269@redhat.com>
 <20110222224141.GA23723@linux.develer.com>
 <20110223000358.GM28269@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110223000358.GM28269@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Feb 22, 2011 at 07:03:58PM -0500, Vivek Goyal wrote:
> > I think we should accept to have an inode granularity. We could redesign
> > the writeback code to work per-cgroup / per-page, etc. but that would
> > add a huge overhead. The limit of inode granularity could be an
> > acceptable tradeoff, cgroups are supposed to work to different files
> > usually, well.. except when databases come into play (ouch!).
> 
> Agreed. Granularity of per inode level might be accetable in many 
> cases. Again, I am worried faster group getting stuck behind slower
> group.
> 
> I am wondering if we are trying to solve the problem of ASYNC write throttling
> at wrong layer. Should ASYNC IO be throttled before we allow task to write to
> page cache. The way we throttle the process based on dirty ratio, can we
> just check for throttle limits also there or something like that.(I think
> that's what you had done in your initial throttling controller implementation?)

Right. This is exactly the same approach I've used in my old throttling
controller: throttle sync READs and WRITEs at the block layer and async
WRITEs when the task is dirtying memory pages.

This is probably the simplest way to resolve the problem of faster group
getting blocked by slower group, but the controller will be a little bit
more leaky, because the writeback IO will be never throttled and we'll
see some limited IO spikes during the writeback. However, this is always
a better solution IMHO respect to the current implementation that is
affected by that kind of priority inversion problem.

I can try to add this logic to the current blk-throttle controller if
you think it is worth to test it.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
