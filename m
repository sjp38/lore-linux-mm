Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0501E6B0264
	for <linux-mm@kvack.org>; Fri, 27 May 2016 11:51:43 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id e93so189205491qgf.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 08:51:43 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id y5si10838931yba.283.2016.05.27.08.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 08:51:42 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id j74so6802178ywg.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 08:51:42 -0700 (PDT)
Date: Fri, 27 May 2016 11:51:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: add RCU locking around
 css_for_each_descendant_pre() in memcg_offline_kmem()
Message-ID: <20160527155140.GN23194@mtj.duckdns.org>
References: <20160526203018.GG23194@mtj.duckdns.org>
 <20160526140202.077d611dbe0926ce290b4e53@linux-foundation.org>
 <20160527153124.GT27686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527153124.GT27686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, May 27, 2016 at 05:31:24PM +0200, Michal Hocko wrote:
> On Thu 26-05-16 14:02:02, Andrew Morton wrote:
> > On Thu, 26 May 2016 16:30:18 -0400 Tejun Heo <tj@kernel.org> wrote:
> > 
> > > memcg_offline_kmem() may be called from memcg_free_kmem() after a css
> > > init failure.  memcg_free_kmem() is a ->css_free callback which is
> > > called without cgroup_mutex and memcg_offline_kmem() ends up using
> > > css_for_each_descendant_pre() without any locking.  Fix it by adding
> > > rcu read locking around it.
> > > 
> > >  mkdir: cannot create directory ___65530___: No space left on device
> > >  [  527.241361] ===============================
> > >  [  527.241845] [ INFO: suspicious RCU usage. ]
> > >  [  527.242367] 4.6.0-work+ #321 Not tainted
> > >  [  527.242730] -------------------------------
> > >  [  527.243220] kernel/cgroup.c:4008 cgroup_mutex or RCU read lock required!
> > 
> > cc:stable?
> 
> Also which kernel versions would be affected? I have tried to look and
> got lost in the indirection of the css_free path.

I think it's actually from 0b8f73e10428 ("mm: memcontrol: clean up
alloc, online, offline, free functions") which got merged during this
cycle, so no need for -stable.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
