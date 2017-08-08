Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A590C6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 19:06:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y129so49197849pgy.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:06:42 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id z70si1535810pfk.642.2017.08.08.16.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 16:06:40 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id t86so20190516pfe.2
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:06:40 -0700 (PDT)
Date: Tue, 8 Aug 2017 16:06:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v4 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170801152548.GA29502@castle.dhcp.TheFacebook.com>
Message-ID: <alpine.DEB.2.10.1708081559001.54505@chino.kir.corp.google.com>
References: <20170726132718.14806-1-guro@fb.com> <20170726132718.14806-3-guro@fb.com> <20170801145435.GN15774@dhcp22.suse.cz> <20170801152548.GA29502@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 1 Aug 2017, Roman Gushchin wrote:

> > To the rest of the patch. I have to say I do not quite like how it is
> > implemented. I was hoping for something much simpler which would hook
> > into oom_evaluate_task. If a task belongs to a memcg with kill-all flag
> > then we would update the cumulative memcg badness (more specifically the
> > badness of the topmost parent with kill-all flag). Memcg will then
> > compete with existing self contained tasks (oom_badness will have to
> > tell whether points belong to a task or a memcg to allow the caller to
> > deal with it). But it shouldn't be much more complex than that.
> 
> I'm not sure, it will be any simpler. Basically I'm doing the same:
> the difference is that you want to iterate over tasks and for each
> task traverse the memcg tree, update per-cgroup oom score and find
> the corresponding memcg(s) with the kill-all flag. I'm doing the opposite:
> traverse the cgroup tree, and for each leaf cgroup iterate over processes.
> 
> Also, please note, that even without the kill-all flag the decision is made
> on per-cgroup level (except tasks in the root cgroup).
> 

I think your implementation is preferred and is actually quite simple to 
follow, and I would encourage you to follow through with it.  It has a 
similar implementation to what we have done for years to kill a process 
from a leaf memcg.

I did notice that oom_kill_memcg_victim() calls directly into 
__oom_kill_process(), however, so we lack the traditional oom killer 
output that shows memcg usage and potential tasklist.  I think we should 
still be dumping this information to the kernel log so that we can see a 
breakdown of charged memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
