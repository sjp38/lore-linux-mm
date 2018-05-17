Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4F56B049D
	for <linux-mm@kvack.org>; Thu, 17 May 2018 06:43:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so2760147wrg.11
        for <linux-mm@kvack.org>; Thu, 17 May 2018 03:43:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m25-v6si2188091edf.0.2018.05.17.03.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 03:43:01 -0700 (PDT)
Date: Thu, 17 May 2018 11:42:16 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] Add the memcg print oom info for system oom
Message-ID: <20180517104211.GA5670@castle.DHCP.thefacebook.com>
References: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com>
 <20180517071140.GQ12670@dhcp22.suse.cz>
 <CAHCio2gOLnj4NpkFrxpYVygg6ZeSeuwgp2Lwr6oTHRxHpbmcWw@mail.gmail.com>
 <20180517102330.GS12670@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180517102330.GS12670@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Thu, May 17, 2018 at 12:23:30PM +0200, Michal Hocko wrote:
> On Thu 17-05-18 17:44:43, c|1e??e?(R) wrote:
> > Hi Michal
> > I think the current OOM report is imcomplete. I can get the task which
> > invoked the oom-killer and the task which has been killed by the
> > oom-killer, and memory info when the oom happened. But I cannot infer the
> > certain memcg to which the task killed by oom-killer belongs, because that
> > task has been killed, and the dump_task will print all of the tasks in the
> > system.
> 
> I can see how the origin memcg might be useful, but ...
> > 
> > mem_cgroup_print_oom_info will print five lines of content including
> > memcg's name , usage, limit. I don't think five lines of content will cause
> > a big problem. Or it at least prints the memcg's name.

I want only add here that if system-wide OOM is a rare event, you can look
at per-cgroup oom counters to find the cgroup, which contained the killed
task. Not super handy, but might work for debug purposes.

> this is not 5 lines at all. We dump memcg stats for the whole oom memcg
> subtree. For your patch it would be the whole subtree of the memcg of
> the oom victim. With cgroup v1 this can be quite deep as tasks can
> belong to inter-nodes as well. Would be
> 
> 		pr_info("Task in ");
> 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> 		pr_cont(" killed as a result of limit of ");
> 
> part of that output sufficient for your usecase? You will not get memory
> consumption of the group but is that really so relevant when we are
> killing individual tasks? Please note that there are proposals to make
> the global oom killer memcg aware and select by the memcg size rather
> than pick on random tasks
> (http://lkml.kernel.org/r/20171130152824.1591-1-guro@fb.com). Maybe that
> will be more interesting for your container usecase.

Speaking about memcg OOM reports more broadly, IMO
rather than spam with memcg-local OOM dumps to dmesg,
it's better to add a new interface to read memcg-specific OOM reports.

The current dmesg OOM report contains a lot of low-level stuff,
which is handy for debugging system-wide OOM issues,
and memcg-aware stuff too; that makes it bulky.

Anyway, Michal's 1-line proposal looks quite acceptable to me.

Thanks!
