Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id BD88E6B0070
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:19:52 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id k11so2361690wes.3
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:19:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cj10si5170189wid.85.2015.01.22.07.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 07:19:51 -0800 (PST)
Date: Thu, 22 Jan 2015 10:19:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150122151943.GA27368@phnom.home.cmpxchg.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <54BCFDCF.9090603@arm.com>
 <20150121163955.GM4549@arm.com>
 <20150122134550.GA13876@phnom.home.cmpxchg.org>
 <20150122143454.GA4507@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122143454.GA4507@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Vladimir Davydov <vdavydov@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Hi,

On Thu, Jan 22, 2015 at 09:34:54AM -0500, Tejun Heo wrote:
> On Thu, Jan 22, 2015 at 08:45:50AM -0500, Johannes Weiner wrote:
> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index bb263d0caab3..9a09308c8066 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -1819,8 +1819,11 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
> >  			goto out_unlock;
> >  		}
> >  
> > -		if (root->flags ^ opts.flags)
> > -			pr_warn("new mount options do not match the existing superblock, will be ignored\n");
> > +		if (root->flags ^ opts.flags) {
> > +			pr_warn("new mount options do not match the existing superblock\n");
> > +			ret = -EBUSY;
> > +			goto out_unlock;
> > +		}
> 
> Do we really need the above chunk?

Inform and ignore or fail hard?  I guess we can drop this hunk and
keep with the current behavior.

> > @@ -1909,7 +1912,7 @@ static void cgroup_kill_sb(struct super_block *sb)
> >  	 *
> >  	 * And don't kill the default root.
> >  	 */
> > -	if (css_has_online_children(&root->cgrp.self) ||
> > +	if (!list_empty(&root->cgrp.self.children) ||
> >  	    root == &cgrp_dfl_root)
> >  		cgroup_put(&root->cgrp);
> 
> I tried to do something a bit more advanced so that eventual async
> release of dying children, if they happen, can also release the
> hierarchy but I don't think it really matters unless we can forcefully
> drain.  So, shouldn't just the above part be enough?

Yep, I'd be fine with that.

---
