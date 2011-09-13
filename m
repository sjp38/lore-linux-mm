Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 464A1900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 01:40:48 -0400 (EDT)
Date: Tue, 13 Sep 2011 07:40:33 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 01/11] mm: memcg: consolidate hierarchy iteration
 primitives
Message-ID: <20110913054033.GC2929@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-2-git-send-email-jweiner@redhat.com>
 <20110912223746.GA20765@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110912223746.GA20765@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 13, 2011 at 01:37:46AM +0300, Kirill A. Shutemov wrote:
> On Mon, Sep 12, 2011 at 12:57:18PM +0200, Johannes Weiner wrote:
> > -static struct mem_cgroup *mem_cgroup_get_next(struct mem_cgroup *iter,
> > -					struct mem_cgroup *root,
> > -					bool cond)
> > -{
> > -	int nextid = css_id(&iter->css) + 1;
> > -	int found;
> > -	int hierarchy_used;
> > -	struct cgroup_subsys_state *css;
> > +	if (prev && !remember)
> > +		id = css_id(&prev->css);
> >  
> > -	hierarchy_used = iter->use_hierarchy;
> > +	if (prev && prev != root)
> > +		css_put(&prev->css);
> >  
> > -	css_put(&iter->css);
> > -	/* If no ROOT, walk all, ignore hierarchy */
> > -	if (!cond || (root && !hierarchy_used))
> > -		return NULL;
> > +	if (!root->use_hierarchy && root != root_mem_cgroup) {
> > +		if (prev)
> > +			return NULL;
> > +		return root;
> > +	}
> >  
> > -	if (!root)
> > -		root = root_mem_cgroup;
> > +	while (!mem) {
> > +		struct cgroup_subsys_state *css;
> >  
> > -	do {
> > -		iter = NULL;
> > -		rcu_read_lock();
> > +		if (remember)
> > +			id = root->last_scanned_child;
> >  
> > -		css = css_get_next(&mem_cgroup_subsys, nextid,
> > -				&root->css, &found);
> > -		if (css && css_tryget(css))
> > -			iter = container_of(css, struct mem_cgroup, css);
> > +		rcu_read_lock();
> > +		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
> > +		if (css) {
> > +			if (css == &root->css || css_tryget(css))
> 
> When does css != &root->css here?

It does not grab an extra reference to the passed hierarchy root, as
all callsites must already hold one to guarantee it's not going away.

> > +static void mem_cgroup_iter_break(struct mem_cgroup *root,
> > +				  struct mem_cgroup *prev)
> > +{
> > +	if (!root)
> > +		root = root_mem_cgroup;
> > +	if (prev && prev != root)
> > +		css_put(&prev->css);
> > +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
