Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 459E18D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 02:30:16 -0500 (EST)
Message-ID: <4D7489BF.9030808@cn.fujitsu.com>
Date: Mon, 07 Mar 2011 15:31:11 +0800
From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
References: <1298888105-3778-1-git-send-email-arighi@develer.com> <20110228230114.GB20845@redhat.com> <20110302132830.GB2061@linux.develer.com> <20110302214705.GD2547@redhat.com> <20110306155247.GA1687@linux.develer.com>
In-Reply-To: <20110306155247.GA1687@linux.develer.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrea Righi wrote:
> On Wed, Mar 02, 2011 at 04:47:05PM -0500, Vivek Goyal wrote:
>> On Wed, Mar 02, 2011 at 02:28:30PM +0100, Andrea Righi wrote:
>>> On Mon, Feb 28, 2011 at 06:01:14PM -0500, Vivek Goyal wrote:
>>>> On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
>>>>> Overview
>>>>> ========
>>>>> Currently the blkio.throttle controller only support synchronous IO requests.
>>>>> This means that we always look at the current task to identify the "owner" of
>>>>> each IO request.
>>>>>
>>>>> However dirty pages in the page cache can be wrote to disk asynchronously by
>>>>> the per-bdi flusher kernel threads or by any other thread in the system,
>>>>> according to the writeback policy.
>>>>>
>>>>> For this reason the real writes to the underlying block devices may
>>>>> occur in a different IO context respect to the task that originally
>>>>> generated the dirty pages involved in the IO operation. This makes the
>>>>> tracking and throttling of writeback IO more complicate respect to the
>>>>> synchronous IO from the blkio controller's perspective.
>>>>>
>>>>> Proposed solution
>>>>> =================
>>>>> In the previous patch set http://lwn.net/Articles/429292/ I proposed to resolve
>>>>> the problem of the buffered writes limitation by tracking the ownership of all
>>>>> the dirty pages in the system.
>>>>>
>>>>> This would allow to always identify the owner of each IO operation at the block
>>>>> layer and apply the appropriate throttling policy implemented by the
>>>>> blkio.throttle controller.
>>>>>
>>>>> This solution makes the blkio.throttle controller to work as expected also for
>>>>> writeback IO, but it does not resolve the problem of faster cgroups getting
>>>>> blocked by slower cgroups (that would expose a potential way to create DoS in
>>>>> the system).
>>>>>
>>>>> In fact, at the moment critical IO requests (that have dependency with other IO
>>>>> requests made by other cgroups) and non-critical requests are mixed together at
>>>>> the filesystem layer in a way that throttling a single write request may stop
>>>>> also other requests in the system, and at the block layer it's not possible to
>>>>> retrieve such informations to make the right decision.
>>>>>
>>>>> A simple solution to this problem could be to just limit the rate of async
>>>>> writes at the time a task is generating dirty pages in the page cache. The
>>>>> big advantage of this approach is that it does not need the overhead of
>>>>> tracking the ownership of the dirty pages, because in this way from the blkio
>>>>> controller perspective all the IO operations will happen from the process
>>>>> context: writes in memory and synchronous reads from the block device.
>>>>>
>>>>> The drawback of this approach is that the blkio.throttle controller becomes a
>>>>> little bit leaky, because with this solution the controller is still affected
>>>>> by the IO spikes during the writeback of dirty pages executed by the kernel
>>>>> threads.
>>>>>
>>>>> Probably an even better approach would be to introduce the tracking of the
>>>>> dirty page ownership to properly account the cost of each IO operation at the
>>>>> block layer and apply the throttling of async writes in memory only when IO
>>>>> limits are exceeded.
>>>> Andrea, I am curious to know more about it third option. Can you give more
>>>> details about accouting in block layer but throttling in memory. So say 
>>>> a process starts IO, then it will still be in throttle limits at block
>>>> layer (because no writeback has started), then the process will write
>>>> bunch of pages in cache. By the time throttle limits are crossed at
>>>> block layer, we already have lots of dirty data in page cache and
>>>> throttling process now is already late?
>>> Charging the cost of each IO operation at the block layer would allow
>>> tasks to write in memory at the maximum speed. Instead, with the 3rd
>>> approach, tasks are forced to write in memory at the rate defined by the
>>> blkio.throttle.write_*_device (or blkio.throttle.async.write_*_device).
>>>
>>> When we'll have the per-cgroup dirty memory accounting and limiting
>>> feature, with this approach each cgroup could write to its dirty memory
>>> quota at the maximum rate.
>> Ok, so this is option 3 which you have already implemented in this
>> patchset. 
>>
>> I guess then I am confused with option 2. Can you elaborate a little
>> more there.
> 
> With option 3, we can just limit the rate at which dirty pages are
> generated in memory. And this can be done introducing the files
> blkio.throttle.async.write_bps/iops_device.
> 
> At the moment in blk_throtl_bio() we charge the dispatched bytes/iops
> _and_ we check if the bio can be dispatched. These two distinct
> operations are now done by the same function.
> 
> With option 2, I'm proposing to split these two operations and place
> throtl_charge_io() at the block layer in __generic_make_request() and an
> equivalent of tg_may_dispatch_bio() (maybe a better name would be
> blk_is_throttled()) at the page cache layer, in
> balance_dirty_pages_ratelimited_nr():
> 
> A prototype for blk_is_throttled() could be the following:
> 
> bool blk_is_throttled(void);
> 
> This means in balance_dirty_pages_ratelimited_nr() we won't charge any
> bytes/iops to the cgroup, but we'll just check if the limits are
> exceeded. And stop it in that case, so that no more dirty pages can be
> generated by this cgroup.
> 
> Instead at the block layer WRITEs will be always dispatched in
> blk_throtl_bio() (tg_may_dispatch_bio() will always return true), but
> the throtl_charge_io() would charge the cost of the IO operation to the
> right cgroup.
> 
> To summarize:
> 
> __generic_make_request():
> 	blk_throtl_bio(q, &bio);
> 
> balance_dirty_pages_ratelimited_nr():
> 	if (blk_is_throttled())
> 		// add the current task into a per-group wait queue and
> 		// wake up once this cgroup meets its quota
> 
> What do you think?

Hi Andrea,

This means when you throttle writes, the reads issued by this task are also throttled?

Thanks,
Gui

> 
> Thanks,
> -Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
