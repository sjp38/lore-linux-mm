Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6EBE6B032E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 11:21:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 68so19115812wmz.5
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:21:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vu9si15690327wjb.227.2016.11.04.08.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 08:21:12 -0700 (PDT)
Date: Fri, 4 Nov 2016 11:21:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memory.force_empty is deprecated
Message-ID: <20161104152103.GC8825@cmpxchg.org>
References: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhao Hui Ding <dingzhh@cn.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hi,

On Fri, Nov 04, 2016 at 04:24:25PM +0800, Zhao Hui Ding wrote:
> Hello,
> 
> I'm Zhaohui from IBM Spectrum LSF development team. I got below message 
> when running LSF on SUSE11.4, so I would like to share our use scenario 
> and ask for the suggestions without using memory.force_empty.
> 
> memory.force_empty is deprecated and will be removed. Let us know if it is 
> needed in your usecase at linux-mm@kvack.org
> 
> LSF is a batch workload scheduler, it uses cgroup to do batch jobs 
> resource enforcement and accounting. For each job, LSF creates a cgroup 
> directory and put job's PIDs to the cgroup.
> 
> When we implement LSF cgroup integration, we found creating a new cgroup 
> is much slower than renaming an existing cgroup, it's about hundreds of 
> milliseconds vs less than 10 milliseconds.

Cgroup creation/deletion is not expected to be an ultra-hot path, but
I'm surprised it takes longer than actually reclaiming leftover pages.

By the time the jobs conclude, how much is usually left in the group?

That said, is it even necessary to pro-actively remove the leftover
cache from the group before starting the next job? Why not leave it
for the next job to reclaim it lazily should memory pressure arise?
It's easy to reclaim page cache, and the first to go as it's behind
the next job's memory on the LRU list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
