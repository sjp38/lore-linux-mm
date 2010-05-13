Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BD59C620088
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:04:30 -0400 (EDT)
Subject: Re: [PATCH 0/9] mm: generic adaptive large memory allocation APIs
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1273744147-7594-1-git-send-email-xiaosuo@gmail.com>
References: <1273744147-7594-1-git-send-email-xiaosuo@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 May 2010 10:04:15 -0500
Message-ID: <1273763055.4353.136.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Changli Gao <xiaosuo@gmail.com>
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 17:49 +0800, Changli Gao wrote:
> generic adaptive large memory allocation APIs
> 
> kv*alloc are used to allocate large contiguous memory and the users don't mind
> whether the memory is physically or virtually contiguous. The allocator always
> try its best to allocate physically contiguous memory first.

This isn't necessarily true ... most drivers and filesystems have to
know what type they're getting.  Often they have to do extra tricks to
process vmalloc areas.  Conversely, large kmalloc areas are a very
precious commodity: if a driver or filesystem can handle vmalloc for
large allocations, it should: it's easier for us to expand the vmalloc
area than to try to make page reclaim keep large contiguous areas ... I
notice your proposed API does the exact opposite of this ... tries
kmalloc first and then does vmalloc.

Given this policy problem, isn't it easier simply to hand craft the
vmalloc fall back to kmalloc (or vice versa) in the driver than add this
whole massive raft of APIs for it?

> In this patch set, some APIs are introduced: kvmalloc(), kvzalloc(), kvcalloc(),
> kvrealloc(), kvfree() and kvfree_inatomic().
> 
> Some code are converted to use the new generic APIs instead.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  drivers/infiniband/hw/ehca/ipz_pt_fn.c |   22 +-----
>  drivers/net/cxgb3/cxgb3_defs.h         |    2 
>  drivers/net/cxgb3/cxgb3_offload.c      |   31 ---------
>  drivers/net/cxgb3/l2t.c                |    4 -
>  drivers/net/cxgb4/cxgb4.h              |    3 
>  drivers/net/cxgb4/cxgb4_main.c         |   37 +----------
>  drivers/net/cxgb4/l2t.c                |    2 
>  drivers/scsi/cxgb3i/cxgb3i_ddp.c       |   12 +--
>  drivers/scsi/cxgb3i/cxgb3i_ddp.h       |   26 -------
>  drivers/scsi/cxgb3i/cxgb3i_offload.c   |    6 -
>  fs/ext4/super.c                        |   21 +-----
>  fs/file.c                              |  109 ++++-----------------------------
>  include/linux/mm.h                     |   31 +++++++++
>  include/linux/vmalloc.h                |    1 
>  kernel/cgroup.c                        |   47 +-------------
>  kernel/relay.c                         |   35 ----------
>  mm/nommu.c                             |    6 +
>  mm/util.c                              |  104 +++++++++++++++++++++++++++++++
>  mm/vmalloc.c                           |   14 ++++
>  19 files changed, 207 insertions(+), 306 deletions(-)

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
