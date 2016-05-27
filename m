Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0543D828E2
	for <linux-mm@kvack.org>; Fri, 27 May 2016 11:31:27 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ne4so56165674lbc.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 08:31:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y9si26689564wjq.103.2016.05.27.08.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 08:31:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a136so15974766wme.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 08:31:25 -0700 (PDT)
Date: Fri, 27 May 2016 17:31:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: add RCU locking around
 css_for_each_descendant_pre() in memcg_offline_kmem()
Message-ID: <20160527153124.GT27686@dhcp22.suse.cz>
References: <20160526203018.GG23194@mtj.duckdns.org>
 <20160526140202.077d611dbe0926ce290b4e53@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160526140202.077d611dbe0926ce290b4e53@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu 26-05-16 14:02:02, Andrew Morton wrote:
> On Thu, 26 May 2016 16:30:18 -0400 Tejun Heo <tj@kernel.org> wrote:
> 
> > memcg_offline_kmem() may be called from memcg_free_kmem() after a css
> > init failure.  memcg_free_kmem() is a ->css_free callback which is
> > called without cgroup_mutex and memcg_offline_kmem() ends up using
> > css_for_each_descendant_pre() without any locking.  Fix it by adding
> > rcu read locking around it.
> > 
> >  mkdir: cannot create directory ___65530___: No space left on device
> >  [  527.241361] ===============================
> >  [  527.241845] [ INFO: suspicious RCU usage. ]
> >  [  527.242367] 4.6.0-work+ #321 Not tainted
> >  [  527.242730] -------------------------------
> >  [  527.243220] kernel/cgroup.c:4008 cgroup_mutex or RCU read lock required!
> 
> cc:stable?

Also which kernel versions would be affected? I have tried to look and
got lost in the indirection of the css_free path.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
