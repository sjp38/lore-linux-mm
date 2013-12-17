Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1076B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:12:43 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so2437042eek.27
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:12:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si4955291eeo.214.2013.12.17.05.12.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:12:42 -0800 (PST)
Date: Tue, 17 Dec 2013 14:12:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131217131241.GE28991@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
 <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
 <52AFC163.5010507@huawei.com>
 <20131217122926.GC29989@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217122926.GC29989@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 17-12-13 07:29:26, Tejun Heo wrote:
> Hello, Li.
> 
> On Tue, Dec 17, 2013 at 11:13:39AM +0800, Li Zefan wrote:
> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index c36d906..769b5bb 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -868,6 +868,15 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
> >  		struct cgroup *cgrp = dentry->d_fsdata;
> >  
> >  		BUG_ON(!(cgroup_is_dead(cgrp)));
> > +
> > +		/*
> > +		 * We should remove the cgroup object from idr before its
> > +		 * grace period starts, so we won't be looking up a cgroup
> > +		 * while the cgroup is being freed.
> > +		 */
> 
> Let's remove this comment and instead comment that this is to be made
> per-css.  I mixed up the lifetime rules of the cgroup and css and
> thought css_from_id() should fail once css is confirmed to be offline,
> so the above comment.  It looks like we'll eventually have to move
> cgrp->id to css->id (just simple per-ss idr) as the two objects'
> lifetime rules will be completely separate.  Other than that, looks
> good to me.

Yeah, please remove it. It made me think that idr_remove cannot be
pulled to later and that's why I ruled out css based solution from the
beginning.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
