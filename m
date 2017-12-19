Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7736A6B0291
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:49:10 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g26so1067666wrb.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:49:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si1221573wmg.114.2017.12.19.04.49.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:49:09 -0800 (PST)
Date: Tue, 19 Dec 2017 13:49:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Message-ID: <20171219124908.GS2787@dhcp22.suse.cz>
References: <20171219000131.149170-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219000131.149170-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Mon 18-12-17 16:01:31, Shakeel Butt wrote:
> The memory controller in cgroup v1 provides the memory+swap (memsw)
> interface to account to the combined usage of memory and swap of the
> jobs. The memsw interface allows the users to limit or view the
> consistent memory usage of their jobs irrespectibe of the presense of
> swap on the system (consistent OOM and memory reclaim behavior). The
> memory+swap accounting makes the job easier for centralized systems
> doing resource usage monitoring, prediction or anomaly detection.
> 
> In cgroup v2, the 'memsw' interface was dropped and a new 'swap'
> interface has been introduced which allows to limit the actual usage of
> swap by the job. For the systems where swap is a limited resource,
> 'swap' interface can be used to fairly distribute the swap resource
> between different jobs. There is no easy way to limit the swap usage
> using the 'memsw' interface.
> 
> However for the systems where the swap is cheap and can be increased
> dynamically (like remote swap and swap on zram), the 'memsw' interface
> is much more appropriate as it makes swap transparent to the jobs and
> gives consistent memory usage history to centralized monitoring systems.
> 
> This patch adds memsw interface to cgroup v2 memory controller behind a
> mount option 'memsw'. The memsw interface is mutually exclusive with
> the existing swap interface. When 'memsw' is enabled, reading or writing
> to 'swap' interface files will return -ENOTSUPP and vice versa. Enabling
> or disabling memsw through remounting cgroup v2, will only be effective
> if there are no decendants of the root cgroup.
> 
> When memsw accounting is enabled then "memory.high" is comapred with
> memory+swap usage. So, when the allocating job's memsw usage hits its
> high mark, the job will be throttled by triggering memory reclaim.

>From a quick look, this looks like a mess. We have agreed to go with
the current scheme for some good reasons. There are cons/pros for both
approaches but I am not convinced we should convolute the user API for
the usecase you describe.

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
