Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C32BA6B0075
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 08:39:41 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id cc10so10455799wib.7
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 05:39:41 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t5si7579210wiy.1.2014.10.08.05.39.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Oct 2014 05:39:40 -0700 (PDT)
Date: Wed, 8 Oct 2014 08:39:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm: hugetlb_controller: convert to lockless page
 counters
Message-ID: <20141008123938.GB14361@cmpxchg.org>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-3-git-send-email-hannes@cmpxchg.org>
 <20141007152149.GF14243@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141007152149.GF14243@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 07, 2014 at 05:21:49PM +0200, Michal Hocko wrote:
> On Wed 24-09-14 11:43:09, Johannes Weiner wrote:
> > Abandon the spinlock-protected byte counters in favor of the unlocked
> > page counters in the hugetlb controller as well.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> One minor thing below:
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thank you!

> >  static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
> >  				    char *buf, size_t nbytes, loff_t off)
> >  {
> > -	int idx, name, ret;
> > -	unsigned long long val;
> > +	int ret, idx;
> > +	unsigned long nr_pages;
> >  	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
> >  
> > +	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
> > +		return -EINVAL;
> > +
> >  	buf = strstrip(buf);
> > +	ret = page_counter_memparse(buf, &nr_pages);
> > +	if (ret)
> > +		return ret;
> > +
> >  	idx = MEMFILE_IDX(of_cft(of)->private);
> > -	name = MEMFILE_ATTR(of_cft(of)->private);
> >  
> > -	switch (name) {
> > +	switch (MEMFILE_ATTR(of_cft(of)->private)) {
> >  	case RES_LIMIT:
> > -		if (hugetlb_cgroup_is_root(h_cg)) {
> > -			/* Can't set limit on root */
> > -			ret = -EINVAL;
> > -			break;
> > -		}
> > -		/* This function does all necessary parse...reuse it */
> > -		ret = res_counter_memparse_write_strategy(buf, &val);
> > -		if (ret)
> > -			break;
> > -		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
> > -		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
> > +		nr_pages = ALIGN(nr_pages, 1UL<<huge_page_order(&hstates[idx]));
> 
> memcg doesn't round up to the next page so I guess we do not have to do
> it here as well.

That rounding was introduced very recently and for no good reason
except that "memcg rounds up too".  Meh.  I'll remove it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
