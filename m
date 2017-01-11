Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDF66B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:32:07 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so11125621wjc.5
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:32:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v30si4789942wrv.154.2017.01.11.08.32.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 08:32:06 -0800 (PST)
Date: Wed, 11 Jan 2017 17:32:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
Message-ID: <20170111163203.GH16365@dhcp22.suse.cz>
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 11-01-17 16:20:45, Ganapatrao Kulkarni wrote:
> Hi,
> 
> we are seeing OOM/stalls messages when we run ltp cpuset01(cpuset01 -I
> 360) test for few minutes, even through the numa system has adequate
> memory on both nodes.
> 
> this we have observed same on both arm64/thunderx numa and on x86 numa system!
> 
> using latest ltp from master branch version 20160920-197-gbc4d3db
> and linux kernel version 4.9
> 
> is this known bug already?
> 
> below is the oops log:
> [ 2280.275193] cgroup: new mount options do not match the existing
> superblock, will be ignored
> [ 2316.565940] cgroup: new mount options do not match the existing
> superblock, will be ignored
> [ 2393.388361] cpuset01: page allocation stalls for 10051ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)

For some reason I thought we are printing the nodemask here. We are
not... Which sucks in situations like this. I will cook up a patch...

[...[
> [ 2393.388457] Node 1 Normal free:11937124kB min:45532kB low:62044kB
> high:78556kB active_anon:58896kB inactive_anon:58552kB
> active_file:288kB inactive_file:0kB unevictable:4kB
> writepending:23384kB present:16777216kB managed:16512808kB mlocked:4kB
> slab_reclaimable:37876kB slab_unreclaimable:44812kB
> kernel_stack:4264kB pagetables:27612kB bounce:0kB free_pcp:2240kB
> local_pcp:0kB free_cma:0kB

It seems that there is a lot of free memory in this node which seems to
be the only eligible one because there are no details about Node 0
zones. So there shouldn't be any real reason to stall this allocation.
Unless there was a huge memory pressure and the relief came only
recently when the current task just managed to get out of the reclaim
and report the stall.

Is there any other workload running on this system?
[...]
> [ 2397.331098] cpuset01 invoked oom-killer:
> gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
> order=0, oom_score_adj=0

Please attach the full oom report.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
