Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D9B3D6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 08:13:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i14so14633428qke.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:13:41 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q143si8156083qke.220.2017.09.26.05.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 05:13:40 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:13:00 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
References: <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
 <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 26, 2017 at 01:21:34PM +0200, Michal Hocko wrote:
> On Tue 26-09-17 11:59:25, Roman Gushchin wrote:
> > On Mon, Sep 25, 2017 at 10:25:21PM +0200, Michal Hocko wrote:
> > > On Mon 25-09-17 19:15:33, Roman Gushchin wrote:
> > > [...]
> > > > I'm not against this model, as I've said before. It feels logical,
> > > > and will work fine in most cases.
> > > > 
> > > > In this case we can drop any mount/boot options, because it preserves
> > > > the existing behavior in the default configuration. A big advantage.
> > > 
> > > I am not sure about this. We still need an opt-in, ragardless, because
> > > selecting the largest process from the largest memcg != selecting the
> > > largest task (just consider memcgs with many processes example).
> > 
> > As I understand Johannes, he suggested to compare individual processes with
> > group_oom mem cgroups. In other words, always select a killable entity with
> > the biggest memory footprint.
> > 
> > This is slightly different from my v8 approach, where I treat leaf memcgs
> > as indivisible memory consumers independent on group_oom setting, so
> > by default I'm selecting the biggest task in the biggest memcg.
> 
> My reading is that he is actually proposing the same thing I've been
> mentioning. Simply select the biggest killable entity (leaf memcg or
> group_oom hierarchy) and either kill the largest task in that entity
> (for !group_oom) or the whole memcg/hierarchy otherwise.

He wrote the following:
"So I'm leaning toward the second model: compare all oomgroups and
standalone tasks in the system with each other, independent of the
failed hierarchical control structure. Then kill the biggest of them."

>  
> > While the approach suggested by Johannes looks clear and reasonable,
> > I'm slightly concerned about possible implementation issues,
> > which I've described below:
> > 
> > > 
> > > > The only thing, I'm slightly concerned, that due to the way how we calculate
> > > > the memory footprint for tasks and memory cgroups, we will have a number
> > > > of weird edge cases. For instance, when putting a single process into
> > > > the group_oom memcg will alter the oom_score significantly and result
> > > > in significantly different chances to be killed. An obvious example will
> > > > be a task with oom_score_adj set to any non-extreme (other than 0 and -1000)
> > > > value, but it can also happen in case of constrained alloc, for instance.
> > > 
> > > I am not sure I understand. Are you talking about root memcg comparing
> > > to other memcgs?
> > 
> > Not only, but root memcg in this case will be another complication. We can
> > also use the same trick for all memcg (define memcg oom_score as maximum oom_score
> > of the belonging tasks), it will turn group_oom into pure container cleanup
> > solution, without changing victim selection algorithm
> 
> I fail to see the problem to be honest. Simply evaluate the memcg_score
> you have so far with one minor detail. You only check memcgs which have
> tasks (rather than check for leaf node check) or it is group_oom. An
> intermediate memcg will get a cumulative size of the whole subhierarchy
> and then you know you can skip the subtree because any subtree can be larger.
> 
> > But, again, I'm not against approach suggested by Johannes. I think that overall
> > it's the best possible semantics, if we're not taking some implementation details
> > into account.
> 
> I do not see those implementation details issues and let me repeat do
> not develop a semantic based on implementation details.

There are no problems in "select the biggest leaf or group_oom memcg, then
kill the biggest task or all tasks depending on group_oom" approach,
which you're describing. Comparing tasks and memcgs (what Johannes is suggesting)
may have some issues.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
