Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C43768D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 16:40:32 -0500 (EST)
Date: Tue, 1 Mar 2011 16:40:12 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
Message-ID: <20110301214012.GD2539@redhat.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
 <20110301162753.GB2539@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301162753.GB2539@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Moyer Jeff Moyer <jmoyer@redhat.com>

On Tue, Mar 01, 2011 at 11:27:53AM -0500, Vivek Goyal wrote:
> On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
> 
> [..]
> > TODO
> > ~~~~
> >  - Consider to add the following new files in the blkio controller to allow the
> >    user to explicitly limit async writes as well as sync writes:
> > 
> >    blkio.throttle.async.write_bps_limit
> >    blkio.throttle.async.write_iops_limit
> 
> I am kind of split on this.
> 
> - One way of thinking is that blkio.throttle.read/write_limits represent
>   the limits on requeuest queue of the IO which is actually passing
>   through queue now. So we should not mix the two and keep async limits
>   separately. This will also tell the customer explicitly that async
>   throttling does not mean the same thing as throttling happens before
>   entering the page cache and there can be/will be IO spikes later
>   at the request queue.
> 
>   Also creating the separate files leaves the door open for future
>   extension of implementing async control when async IO is actually
>   submitted to request queue. (Though I think that will be hard as
>   making sure all the filesystems, writeback logic, device mapper
>   drivers are aware of throttling and will take steps to ensure faster
>   groups are not stuck behind slower groups).
> 
>  So keeping async accounting separate will help differentiating that
>  async control is not same as sync control. There are fundamental
>  differences.
> 
> 
> - On the other hand, it makes life a bit simple for user as they don't
>   have to specify the async limits separately and there is one aggregate
>   limit for sync and async (assuming we fix the throttling state issues
>   so that throttling logic can handle both bio and task throttling out
>   of single limit).
> 
> Any thoughts?

Thinking more about it.

Was chatting with Jeff Moyer about this  and he mentioned that 
applications might not like this frequent blocking in buffered write
path. Which is a valid concern but I don't know how to address that.
dirty_ratio, dity_bytes and dirty_background_ratio will not be enough
to throttle the overall WRITE rate from application.

I am kind of now little inclined towards creating separate files for
async writeout and not mix these throttling at device level for 
following reasons.

- It is a different thorttling functionality at different layer and it is
  not same as throttling sync IO at device level when IO is submitted to
  device. We are just making use of existing throttling infrastructure to
  account for writting rates in page cache. So having separate file and
  separate async throttle state per group in blkio makes sense to me.

- There will be these unintutive side affects of frequent blocking
  and keeping it separate atleast allows us to disable this functionality.

- And we might come up with throttling async IO at device level and 
  keeping it separate helps us at that point of time.

So to me throttling the async rate while writting to page cache is
a different functionality and let it be controlled by separate blkio
files. The bigger question is that in what cases this kind of functionality
is really useful given that it can still produce IO spikes and given the fact
that application will be put to sleep freqently depending on throttling rate
configured.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
