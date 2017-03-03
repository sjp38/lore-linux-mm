Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA1C6B03A1
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:39:53 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y51so39662207wry.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:39:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s83si2978774wms.147.2017.03.03.05.39.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 05:39:52 -0800 (PST)
Date: Fri, 3 Mar 2017 14:39:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170303133950.GD31582@dhcp22.suse.cz>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Fri 03-03-17 19:48:30, Tetsuo Handa wrote:
> Continued from http://lkml.kernel.org/r/201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp :
> 
> While I was testing a patch which avoids infinite too_many_isolated() loop in
> shrink_inactive_list(), I hit a lockup where WQ_MEM_RECLAIM threads got stuck
> waiting for memory allocation. I guess that we overlooked a basic thing about
> WQ_MEM_RECLAIM.
> 
>   WQ_MEM_RECLAIM helps only when the cause of failing to complete
>   a work item is lack of "struct task_struct" to run that work item, for
>   WQ_MEM_RECLAIM preallocates one "struct task_struct" so that the workqueue
>   will not be blocked waiting for memory allocation for "struct task_struct".
> 
>   WQ_MEM_RECLAIM does not help when "struct task_struct" running that work
>   item is blocked waiting for memory allocation (or is indirectly blocked
>   on a lock where the owner of that lock is blocked waiting for memory
>   allocation). That is, WQ_MEM_RECLAIM users must guarantee forward progress
>   if memory allocation (including indirect memory allocation via
>   locks/completions) is needed.
> 
> In XFS, "xfs_mru_cache", "xfs-buf/%s", "xfs-data/%s", "xfs-conv/%s", "xfs-cil/%s",
> "xfs-reclaim/%s", "xfs-log/%s", "xfs-eofblocks/%s", "xfsalloc" and "xfsdiscard"
> workqueues are used, and all but "xfsdiscard" are WQ_MEM_RECLAIM workqueues.
> 
> What I observed is at http://I-love.SAKURA.ne.jp/tmp/serial-20170226.txt.xz .
> I guess that the key of this lockup is that xfs-data/sda1 and xfs-eofblocks/s
> workqueues (which are RESCUER) got stuck waiting for memory allocation.

If those workers are really required for a further progress of the
memory reclaim then they shouldn't block on allocation at all and either
use pre allocated memory or use PF_MEMALLOC in case there is a guarantee
that only very limited amount of memory is allocated from that context
and there will be at least the same amount of memory freed as a result
in a reasonable time.

This is something for xfs people to answer though. Please note that I
didn't really have time to look through the below traces so the above
note is rather generic. It would be really helpful if you could provide
a high level dependency chains to see why those rescuers are necessary
for the forward progress because it is really easy to get lost in so
many traces.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
