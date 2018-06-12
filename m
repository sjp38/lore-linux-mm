Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFE16B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 13:24:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j14-v6so14057096wrq.4
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:24:49 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v5-v6si616706edr.266.2018.06.12.10.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 10:24:47 -0700 (PDT)
Date: Tue, 12 Jun 2018 10:24:11 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 2/3] mm, memcg: propagate memory effective protection
 on setting memory.min/low
Message-ID: <20180612172408.GA12904@castle.DHCP.thefacebook.com>
References: <20180611175418.7007-1-guro@fb.com>
 <20180611175418.7007-3-guro@fb.com>
 <20180612155242.GA6300@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180612155242.GA6300@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linuxfoundation.org>

On Tue, Jun 12, 2018 at 11:52:42AM -0400, Johannes Weiner wrote:
> On Mon, Jun 11, 2018 at 10:54:17AM -0700, Roman Gushchin wrote:
> > Explicitly propagate effective memory min/low values down by the tree.
> > 
> > If there is the global memory pressure, it's not really necessary.
> > Effective memory guarantees will be propagated automatically as we
> > traverse memory cgroup tree in the reclaim path.
> > 
> > But if there is no global memory pressure, effective memory protection
> > still matters for local (memcg-scoped) memory pressure.  So, we have to
> > update effective limits in the subtree, if a user changes memory.min and
> > memory.low values.
> > 
> > Link: http://lkml.kernel.org/r/20180522132528.23769-1-guro@fb.com
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Greg Thelen <gthelen@google.com>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Shuah Khan <shuah@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linuxfoundation.org>
> > ---
> >  mm/memcontrol.c | 14 ++++++++++++--
> >  1 file changed, 12 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 5a3873e9d657..485df6f63d26 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5084,7 +5084,7 @@ static int memory_min_show(struct seq_file *m, void *v)
> >  static ssize_t memory_min_write(struct kernfs_open_file *of,
> >  				char *buf, size_t nbytes, loff_t off)
> >  {
> > -	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> > +	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
> >  	unsigned long min;
> >  	int err;
> >  
> > @@ -5095,6 +5095,11 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
> >  
> >  	page_counter_set_min(&memcg->memory, min);
> >  
> > +	rcu_read_lock();
> > +	for_each_mem_cgroup_tree(iter, memcg)
> > +		mem_cgroup_protected(NULL, iter);
> > +	rcu_read_unlock();
> 
> I'm not quite following. mem_cgroup_protected() is a just-in-time
> query that depends on the groups' usage. How does it make sense to run
> this at the time the limit is set?

mem_cgroup_protected() emulates memory pressure to propagate
effective memory guarantee values.
> 
> Also, why is target reclaim different from global reclaim here? We
> have all the information we need, even if we don't start at the
> root_mem_cgroup. If we enter target reclaim against a specific cgroup,
> yes, we don't know the elow it receives from its parents. What we *do*
> know, though, is that it hit its own hard limit. What is happening
> higher up that group doesn't matter for the purpose of protection.
> 
> I.e. it seems to me that instead of this patch we should be treating
> the reclaim root and its first-level children the same way we treat
> root_mem_cgroup and top-level cgroups: no protection for the root,
> first children use their low setting as the elow, all descendants get
> the proportional low-usage distribution.
> 

Ok, we can keep it this way. We can have some races between the global
and targeted reclaim, but it's fine.

Andrew,
can you, please, drop these patches from the mm tree:
  selftests: cgroup: add test for memory.low corner cases
  mm, memcg: don't skip memory guarantee calculations
  mm, memcg: propagate memory effective protection on setting memory.min/low

The null pointer fix ("b2c21aa3690a mm: fix null pointer dereference in mem_cgroup_protected")
should be kept and merged asap.

Thank you!
