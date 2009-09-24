Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AC3016B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 02:59:37 -0400 (EDT)
Date: Thu, 24 Sep 2009 15:54:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 3/8] memcg: cleanup mem_cgroup_move_parent()
Message-Id: <20090924155438.37152f25.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924153750.bb64f85e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144602.da3c3ab0.nishimura@mxp.nes.nec.co.jp>
	<20090924153750.bb64f85e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > @@ -1584,38 +1581,35 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
> >  	if (!pcg)
> >  		return -EINVAL;
> >  
> > +	ret = -EBUSY;
> > +	if (!get_page_unless_zero(page))
> > +		goto out;
> > +	if (isolate_lru_page(page))
> > +		goto put;
> >  
> > -	parent = mem_cgroup_from_cont(pcg);
> > -
> > +	ret = -EINVAL;
> > +	lock_page_cgroup(pc);
> > +	if (!PageCgroupUsed(pc) || pc->mem_cgroup != child) { /* early check */
> > +		unlock_page_cgroup(pc);
> > +		goto put_back;
> > +	}
> 
> I wonder...it's ok to remove this check. We'll do later and
> racy case will be often. Then, the codes will be simpler.
> Any ideas ?
> 
Yes, it can be removed. mem_cgroup_move_account() called later will check it again.
It's just an early check to avoid try_charge() if possible, but it's O.K.
for me to remove it.

will fix in next post.


Thanks,
Daisuke Nishimura.

> Thanks,
> -Kame
> 
> > +	unlock_page_cgroup(pc);
> >  
> > +	parent = mem_cgroup_from_cont(pcg);
> >  	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
> >  	if (ret || !parent)
> > -		return ret;
> > -
> > -	if (!get_page_unless_zero(page)) {
> > -		ret = -EBUSY;
> > -		goto uncharge;
> > -	}
> > -
> > -	ret = isolate_lru_page(page);
> > -
> > -	if (ret)
> > -		goto cancel;
> > +		goto put_back;
> >  
> >  	ret = mem_cgroup_move_account(pc, child, parent);
> > -
> > +	if (!ret)
> > +		css_put(&parent->css);	/* drop extra refcnt by try_charge() */
> > +	else
> > +		__mem_cgroup_cancel_charge(parent);	/* does css_put */
> > +put_back:
> >  	putback_lru_page(page);
> > -	if (!ret) {
> > -		put_page(page);
> > -		/* drop extra refcnt by try_charge() */
> > -		css_put(&parent->css);
> > -		return 0;
> > -	}
> > -
> > -cancel:
> > +put:
> >  	put_page(page);
> > -uncharge:
> > -	__mem_cgroup_cancel_charge(parent);
> > +out:
> >  	return ret;
> >  }
> >  
> > -- 
> > 1.5.6.1
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
