Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E86846B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 09:41:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p46so12751956wrb.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 06:41:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j1si1375027edc.100.2017.10.05.06.41.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 06:41:44 -0700 (PDT)
Date: Thu, 5 Oct 2017 14:41:13 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v10 5/6] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171005134113.GA912@castle.dhcp.TheFacebook.com>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-6-guro@fb.com>
 <20171004200453.GE1501@cmpxchg.org>
 <20171005131419.4o6qynsl2qxomekb@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171005131419.4o6qynsl2qxomekb@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 05, 2017 at 03:14:19PM +0200, Michal Hocko wrote:
> On Wed 04-10-17 16:04:53, Johannes Weiner wrote:
> [...]
> > That will silently ignore what the user writes to the memory.oom_group
> > control files across the system's cgroup tree.
> > 
> > We'll have a knob that lets the workload declare itself an indivisible
> > memory consumer, that it would like to get killed in one piece, and
> > it's silently ignored because of a mount option they forgot to pass.
> > 
> > That's not good from an interface perspective.
> 
> Yes and that is why I think a boot time knob would be the most simple
> way. It will also open doors for more oom policies in future which I
> believe come sooner or later.

So, we would rely on grub config to set up OOM policy? Sounds weird.

We use boot options, when it's hard to implement on the fly switching
(like turning on/off socket memory accounting), but here is not this case.

> 
> > On the other hand, the only benefit of this patch is to shield users
> > from changes to the OOM killing heuristics. Yet, it's really hard to
> > imagine that modifying the victim selection process slightly could be
> > called a regression in any way. We have done that many times over,
> > without a second thought on backwards compatibility:
> > 
> > 5e9d834a0e0c oom: sacrifice child with highest badness score for parent
> > a63d83f427fb oom: badness heuristic rewrite
> > 778c14affaf9 mm, oom: base root bonus on current usage
> 
> yes we have changed that without a deeper considerations. Some of those
> changes are arguable (e.g. child scarification). The oom badness
> heuristic rewrite has triggered quite some complains AFAIR (I remember
> Kosaki has made several attempts to revert it). I think that we are
> trying to be more careful about user visible changes than we used to be.
> 
> More importantly I do not think that the current (non-memcg aware) OOM
> policy is somehow obsolete and many people expect it to behave
> consistently. As I've said already, I have seen many complains that the
> OOM killer doesn't kill the right task. Most of them were just NUMA
> related issues where the oom report was not clear enough. I do not want
> to repeat that again now. Memcg awareness is certainly a useful
> heuristic but I do not see it universally applicable to all workloads.
> 
> > Let's not make the userspace interface crap because of some misguided
> > idea that the OOM heuristic is a hard promise to userspace. It's never
> > been, and nobody has complained about changes in the past.
> > 
> > This case is doubly silly, as the behavior change only applies to
> > cgroup2, which doesn't exactly have a large base of legacy users yet.
> 
> I agree on the interface part but I disagree with making it default just
> because v2 is not largerly adopted yet.

I believe that the only real regression can be caused by active using of
oom_score_adj. I really don't know how many cgroup v2 users are relying
on it (hopefully, 0).

So, personally I would prefer to have an opt-out cgroup v2 mount option
(sane new behavior for most users, 100% backward compatibility for rare
strange setups), but I don't have a very strong opinion here.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
