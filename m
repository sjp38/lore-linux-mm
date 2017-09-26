Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9DD26B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:26:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so13204687wrf.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:26:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m19si121032eda.511.2017.09.26.10.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Sep 2017 10:26:21 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:26:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170926172610.GA26694@cmpxchg.org>
References: <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
 <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
 <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 26, 2017 at 03:30:40PM +0200, Michal Hocko wrote:
> On Tue 26-09-17 13:13:00, Roman Gushchin wrote:
> > On Tue, Sep 26, 2017 at 01:21:34PM +0200, Michal Hocko wrote:
> > > On Tue 26-09-17 11:59:25, Roman Gushchin wrote:
> > > > On Mon, Sep 25, 2017 at 10:25:21PM +0200, Michal Hocko wrote:
> > > > > On Mon 25-09-17 19:15:33, Roman Gushchin wrote:
> > > > > [...]
> > > > > > I'm not against this model, as I've said before. It feels logical,
> > > > > > and will work fine in most cases.
> > > > > > 
> > > > > > In this case we can drop any mount/boot options, because it preserves
> > > > > > the existing behavior in the default configuration. A big advantage.
> > > > > 
> > > > > I am not sure about this. We still need an opt-in, ragardless, because
> > > > > selecting the largest process from the largest memcg != selecting the
> > > > > largest task (just consider memcgs with many processes example).
> > > > 
> > > > As I understand Johannes, he suggested to compare individual processes with
> > > > group_oom mem cgroups. In other words, always select a killable entity with
> > > > the biggest memory footprint.
> > > > 
> > > > This is slightly different from my v8 approach, where I treat leaf memcgs
> > > > as indivisible memory consumers independent on group_oom setting, so
> > > > by default I'm selecting the biggest task in the biggest memcg.
> > > 
> > > My reading is that he is actually proposing the same thing I've been
> > > mentioning. Simply select the biggest killable entity (leaf memcg or
> > > group_oom hierarchy) and either kill the largest task in that entity
> > > (for !group_oom) or the whole memcg/hierarchy otherwise.
> > 
> > He wrote the following:
> > "So I'm leaning toward the second model: compare all oomgroups and
> > standalone tasks in the system with each other, independent of the
> > failed hierarchical control structure. Then kill the biggest of them."
> 
> I will let Johannes to comment but I believe this is just a
> misunderstanding. If we compared only the biggest task from each memcg
> then we are basically losing our fairness objective, aren't we?

Sorry about the confusion.

Yeah I was making the case for what Michal proposed, to kill the
biggest terminal consumer, which is either a task or an oomgroup.

You'd basically iterate through all the tasks and cgroups in the
system and pick the biggest task that isn't in an oom group or the
biggest oom group and then kill that.

Yeah, you'd have to compare the memory footprints of tasks with the
memory footprints of cgroups. These aren't defined identically, and
tasks don't get attributed every type of allocation that a cgroup
would. But it should get us in the ballpark, and I cannot picture a
scenario where this would lead to a completely undesirable outcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
