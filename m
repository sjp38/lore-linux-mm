Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 03B816B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 11:32:54 -0400 (EDT)
Date: Wed, 27 Mar 2013 11:32:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130327153226.GF29052@cmpxchg.org>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
 <20130327145727.GD29052@cmpxchg.org>
 <20130327151104.GK16579@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327151104.GK16579@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 04:11:04PM +0100, Michal Hocko wrote:
> On Wed 27-03-13 10:58:25, Johannes Weiner wrote:
> > On Wed, Mar 27, 2013 at 09:36:39AM +0100, Michal Hocko wrote:
> [...]
> > > +	/*
> > > +	 * kmem_cache_create_memcg duplicates the given name and
> > > +	 * cgroup_name for this name requires RCU context.
> > > +	 * This static temporary buffer is used to prevent from
> > > +	 * pointless shortliving allocation.
> > > +	 */
> > > +	if (!tmp_name) {
> > > +		tmp_name = kmalloc(PAGE_SIZE, GFP_KERNEL);
> > > +		WARN_ON_ONCE(!tmp_name);
> > 
> > Just use the page allocator directly and get a free allocation failure
> > warning. 
> 
> WARN_ON_ONCE is probably pointless.
> 
> > Then again, order-0 pages are considered cheap enough that they never
> > even fail in our current implementation.
> > 
> > Which brings me to my other point: why not just a simple single-page
> > allocation?
> 
> No objection from me. I was previously thinking about the "proper"
> size for something that is a file name. So I originally wanted to use
> PATH_MAX instead but ended up with PAGE_SIZE for reasons I do not
> remember now.  Maybe we can use NAME_MAX instead. I just do not like to
> use page allocator directly when allocatating something like strings
> etc...

Don't grep for GFP_TEMPORARY then, we do it in a couple places :-)
NAME_MAX is just for single dentry names, not path names, no?  Might
be a little short.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
