Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 286FE6B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:33:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n2so40396064wma.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:33:54 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 8si35827470wmu.15.2016.05.31.02.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 02:33:53 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so30759620wmg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:33:52 -0700 (PDT)
Date: Tue, 31 May 2016 11:33:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: add RCU locking around
 css_for_each_descendant_pre() in memcg_offline_kmem()
Message-ID: <20160531093351.GG26128@dhcp22.suse.cz>
References: <20160526203018.GG23194@mtj.duckdns.org>
 <20160526140202.077d611dbe0926ce290b4e53@linux-foundation.org>
 <20160527153124.GT27686@dhcp22.suse.cz>
 <20160527155140.GN23194@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527155140.GN23194@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Sorry for a late response.

On Fri 27-05-16 11:51:40, Tejun Heo wrote:
> On Fri, May 27, 2016 at 05:31:24PM +0200, Michal Hocko wrote:
> > On Thu 26-05-16 14:02:02, Andrew Morton wrote:
> > > On Thu, 26 May 2016 16:30:18 -0400 Tejun Heo <tj@kernel.org> wrote:
> > > 
> > > > memcg_offline_kmem() may be called from memcg_free_kmem() after a css
> > > > init failure.  memcg_free_kmem() is a ->css_free callback which is
> > > > called without cgroup_mutex and memcg_offline_kmem() ends up using
> > > > css_for_each_descendant_pre() without any locking.  Fix it by adding
> > > > rcu read locking around it.
> > > > 
> > > >  mkdir: cannot create directory ___65530___: No space left on device
> > > >  [  527.241361] ===============================
> > > >  [  527.241845] [ INFO: suspicious RCU usage. ]
> > > >  [  527.242367] 4.6.0-work+ #321 Not tainted
> > > >  [  527.242730] -------------------------------
> > > >  [  527.243220] kernel/cgroup.c:4008 cgroup_mutex or RCU read lock required!
> > > 
> > > cc:stable?
> > 
> > Also which kernel versions would be affected? I have tried to look and
> > got lost in the indirection of the css_free path.
> 
> I think it's actually from 0b8f73e10428 ("mm: memcontrol: clean up
> alloc, online, offline, free functions") which got merged during this
> cycle, so no need for -stable.

yes you are right! memcg_free_kmem didn't call memcg_offline_kmem before
that commit. Thanks for the clarification.

Anyway
$ git describe --contains 0b8f73e10428
v4.5-rc1~30^2~11

So it would be stable # 4.5+
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
