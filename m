Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F1AB6B00E9
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 05:10:03 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 25A8C3EE0BC
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:10:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04C6045DE6F
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:10:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE99A45DE69
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:09:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CCF821DB803C
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:09:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 863281DB8040
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:09:59 +0900 (JST)
Date: Mon, 24 Jan 2011 19:03:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg : fix mem_cgroup_check_under_limit
Message-Id: <20110124190359.a79deec8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110124100434.GS2232@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121154141.680c96d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110124100434.GS2232@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2011 11:04:34 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:
  
> >  	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> > -					gfp_mask, flags);
> > +					gfp_mask, flags, csize);
> >  	/*
> >  	 * try_to_free_mem_cgroup_pages() might not give us a full
> >  	 * picture of reclaim. Some pages are reclaimed and might be
> > @@ -1852,7 +1853,7 @@ static int __mem_cgroup_do_charge(struct
> >  	 * Check the limit again to see if the reclaim reduced the
> >  	 * current usage of the cgroup before giving up
> >  	 */
> > -	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
> > +	if (ret || mem_cgroup_check_under_limit(mem_over_limit, csize))
> >  		return CHARGE_RETRY;
> 
> This is the only site that is really involved with THP. 

yes.

> But you need to touch every site because you change mem_cgroup_check_under_limit()
> instead of adding a new function.
> 
Yes.

> I would suggest just adding another function for checking available
> space explicitely and only changing this single call site to use it.
> 
> Just ignore the return value of mem_cgroup_hierarchical_reclaim() and
> check for enough space unconditionally.
> 
> Everybody else is happy with PAGE_SIZE pages.
> 
Hmm. ok, let us changes to be small and see how often hugepage alloc will fail.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
