Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 183FB6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:30:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so21688032pgn.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:30:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si5836146ple.374.2017.09.26.06.30.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:30:42 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:30:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
References: <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
 <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 26-09-17 13:13:00, Roman Gushchin wrote:
> On Tue, Sep 26, 2017 at 01:21:34PM +0200, Michal Hocko wrote:
> > On Tue 26-09-17 11:59:25, Roman Gushchin wrote:
> > > On Mon, Sep 25, 2017 at 10:25:21PM +0200, Michal Hocko wrote:
> > > > On Mon 25-09-17 19:15:33, Roman Gushchin wrote:
> > > > [...]
> > > > > I'm not against this model, as I've said before. It feels logical,
> > > > > and will work fine in most cases.
> > > > > 
> > > > > In this case we can drop any mount/boot options, because it preserves
> > > > > the existing behavior in the default configuration. A big advantage.
> > > > 
> > > > I am not sure about this. We still need an opt-in, ragardless, because
> > > > selecting the largest process from the largest memcg != selecting the
> > > > largest task (just consider memcgs with many processes example).
> > > 
> > > As I understand Johannes, he suggested to compare individual processes with
> > > group_oom mem cgroups. In other words, always select a killable entity with
> > > the biggest memory footprint.
> > > 
> > > This is slightly different from my v8 approach, where I treat leaf memcgs
> > > as indivisible memory consumers independent on group_oom setting, so
> > > by default I'm selecting the biggest task in the biggest memcg.
> > 
> > My reading is that he is actually proposing the same thing I've been
> > mentioning. Simply select the biggest killable entity (leaf memcg or
> > group_oom hierarchy) and either kill the largest task in that entity
> > (for !group_oom) or the whole memcg/hierarchy otherwise.
> 
> He wrote the following:
> "So I'm leaning toward the second model: compare all oomgroups and
> standalone tasks in the system with each other, independent of the
> failed hierarchical control structure. Then kill the biggest of them."

I will let Johannes to comment but I believe this is just a
misunderstanding. If we compared only the biggest task from each memcg
then we are basically losing our fairness objective, aren't we?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
