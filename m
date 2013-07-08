Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 62EFB6B0036
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 14:11:48 -0400 (EDT)
Date: Mon, 8 Jul 2013 14:11:44 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130708181144.GC9094@redhat.com>
References: <20130708100046.14417.12932.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130708100046.14417.12932.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Greg Thelen <gthelen@google.com>

On Mon, Jul 08, 2013 at 02:01:39PM +0400, Konstantin Khlebnikov wrote:
> RESEND: fix CC
> 
> This is proof of concept, just basic functionality for IO controller.
> This cgroup will control filesystem usage on vfs layer, it's main goal is
> bandwidth control. It's supposed to be much more lightweight than memcg/blkio.
> 
> This patch shows easy way for accounting pages in dirty/writeback state in
> per-inode manner. This is easier that doing this in memcg in per-page manner.

In the past other developers (CC Greg Thelen <gthelen@google.com>) have posted
patches where inode was associated with a memcg for writeback accounting.

So accounting was per inode and not per page. We lose granularity in the
process if two processes in different cgroups are doing IO to a file but it
was considered good enough approximation in general. 

> Main idea is in keeping on each inode pointer (->i_fsio) to cgroup which owns
> dirty data in that inode. It's settled by fsio_account_page_dirtied() when
> first dirty tag appears in the inode. Relying to mapping tags gives us locking
> for free, this patch doesn't add any new locks to hot paths.
> 
> Unlike to blkio this method works for all of filesystems, not just disk-backed.
> Also it's able to handle writeback, because each inode has context which can be
> used in writeback thread to account io operations.
> 
> This is early prototype, I have some plans about extra functionality because
> this accounting itself is mostly useless, but it can be used as basis for more
> usefull features.
> 
> Planned impovements:
> * Split bdi into several tiers and account them separately. For example:
>   hdd/ssd/usb/nfs. In complicated containerized environments that might be
>   different kinds of storages with different limits and billing. This is more
>   usefull that independent per-disk accounting and much easier to implement
>   because all per-tier structures are allocated before disk appearance.

What does this mean? With-in a cgroup there are different IO rate rules 
depending on who is backing the bdi? If yes, then can't this info be
exported to user space (if it is not already) and then user space can
set the rules accordingly on disk.

W.r.t the issue of being able to apply rules only when disk appears, I 
think we will need a solution for this in user space which applies the
rules when disk shows up.  I think systemd is planning to take care of of this
up to some extent where one can specify IO bandwidth limits and these
limits get applied when disk shows up. I am not sure if it allows
different limits for different disks or not.


> * Add some hooks for accounting actualy issued IO requests (iops).
> * Implement bandwidth throttlers for each tier individually (bps and iops).
>   This will be the most tasty feature. I already have very effective prototype.

Can you please give some details here and also explain why blkcg can not
achieve do the same.

> * Add hook into balance_dirty_pages to limit amount of dirty page for each
>   cgroup in each tier individually. This is required for accurate throttling,
>   because if we want to limit speed of writeback we also must limit amount
>   of dirty pages otherwise we have to inject enourmous delay after each sync().

So there is a separate knob for limiting on buffered write rate and it 
is not accounted towards direct writes etc?

Anyway, limiting dirty pages per memory cgroup will be required even if
we use blkcg.

> * Implement filtered writeback requests for writing only data which belongs to
>   particular fsio cgroup (or cgroups tree) to keep dirty balance in background.

I think Greg had done similar modifications and put inodes into cgroup
specific writeback lists and modify writeback logic.

So quite a few pieces w.r.t balance_dirty_pages() and inode tagging are
common even if we support writeback limits using blkcg. Only question we
will have to figure out why implement all this functinality using a new
cgroup controller instead of enhancing blkcg.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
