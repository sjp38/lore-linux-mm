Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0A376B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:00:15 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t46so10852004qtj.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:00:15 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l128si7844311qkd.548.2017.09.26.04.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 04:00:14 -0700 (PDT)
Date: Tue, 26 Sep 2017 11:59:25 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
References: <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 25, 2017 at 10:25:21PM +0200, Michal Hocko wrote:
> On Mon 25-09-17 19:15:33, Roman Gushchin wrote:
> [...]
> > I'm not against this model, as I've said before. It feels logical,
> > and will work fine in most cases.
> > 
> > In this case we can drop any mount/boot options, because it preserves
> > the existing behavior in the default configuration. A big advantage.
> 
> I am not sure about this. We still need an opt-in, ragardless, because
> selecting the largest process from the largest memcg != selecting the
> largest task (just consider memcgs with many processes example).

As I understand Johannes, he suggested to compare individual processes with
group_oom mem cgroups. In other words, always select a killable entity with
the biggest memory footprint.

This is slightly different from my v8 approach, where I treat leaf memcgs
as indivisible memory consumers independent on group_oom setting, so
by default I'm selecting the biggest task in the biggest memcg.

While the approach suggested by Johannes looks clear and reasonable,
I'm slightly concerned about possible implementation issues,
which I've described below:

> 
> > The only thing, I'm slightly concerned, that due to the way how we calculate
> > the memory footprint for tasks and memory cgroups, we will have a number
> > of weird edge cases. For instance, when putting a single process into
> > the group_oom memcg will alter the oom_score significantly and result
> > in significantly different chances to be killed. An obvious example will
> > be a task with oom_score_adj set to any non-extreme (other than 0 and -1000)
> > value, but it can also happen in case of constrained alloc, for instance.
> 
> I am not sure I understand. Are you talking about root memcg comparing
> to other memcgs?

Not only, but root memcg in this case will be another complication. We can
also use the same trick for all memcg (define memcg oom_score as maximum oom_score
of the belonging tasks), it will turn group_oom into pure container cleanup
solution, without changing victim selection algorithm

But, again, I'm not against approach suggested by Johannes. I think that overall
it's the best possible semantics, if we're not taking some implementation details
into account.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
