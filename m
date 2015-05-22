Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 28E9882A12
	for <linux-mm@kvack.org>; Fri, 22 May 2015 19:13:30 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so2480488wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 16:13:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fy6si419868wib.38.2015.05.22.16.13.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 16:13:28 -0700 (PDT)
Date: Fri, 22 May 2015 19:12:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/19] memcg: make mem_cgroup_read_{stat|event}() iterate
 possible cpus instead of online
Message-ID: <20150522231249.GA6485@cmpxchg.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
 <1432333416-6221-2-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432333416-6221-2-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri, May 22, 2015 at 06:23:18PM -0400, Tejun Heo wrote:
> cpu_possible_mask represents the CPUs which are actually possible
> during that boot instance.  For systems which don't support CPU
> hotplug, this will match cpu_online_mask exactly in most cases.  Even
> for systems which support CPU hotplug, the number of possible CPU
> slots is highly unlikely to diverge greatly from the number of online
> CPUs.  The only cases where the difference between possible and online
> caused problems were when the boot code failed to initialize the
> possible mask and left it fully set at NR_CPUS - 1.
> 
> As such, most per-cpu constructs allocate for all possible CPUs and
> often iterate over the possibles, which also has the benefit of
> avoiding the blocking CPU hotplug synchronization.
> 
> memcg open codes per-cpu stat counting for mem_cgroup_read_stat() and
> mem_cgroup_read_events(), which iterates over online CPUs and handles
> CPU hotplug operations explicitly.  This complexity doesn't actually
> buy anything.  Switch to iterating over the possibles and drop the
> explicit CPU hotplug handling.
> 
> Eventually, we want to convert memcg to use percpu_counter instead of
> its own custom implementation which also benefits from quick access
> w/o summing for cases where larger error margin is acceptable.
> 
> This will allow mem_cgroup_read_stat() to be called from non-sleepable
> contexts which will be used by cgroup writeback.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
