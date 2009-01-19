Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 07E316B00A1
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 05:08:24 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0JA8MpE009429
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Jan 2009 19:08:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C52B45DD79
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 19:08:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 32F3A45DE57
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 19:08:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E08F91DB8049
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 19:08:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 897581DB8038
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 19:08:21 +0900 (JST)
Date: Mon, 19 Jan 2009 19:07:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
Message-Id: <20090119190717.6e07b7cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090119095738.GG6039@balbir.in.ibm.com>
References: <496ED2B7.5050902@cn.fujitsu.com>
	<20090119174922.a30146be.kamezawa.hiroyu@jp.fujitsu.com>
	<20090119095738.GG6039@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009 15:27:38 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-19 17:49:22]:
> 
> > On Thu, 15 Jan 2009 14:07:51 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > 1. task p1 is in /memcg/0
> > > 2. p1 does mmap(4096*2, MAP_LOCKED)
> > > 3. echo 4096 > /memcg/0/memory.limit_in_bytes
> > > 
> > > The above 'echo' will never return, unless p1 exited or freed the memory.
> > > The cause is we can't reclaim memory from p1, so the while loop in
> > > mem_cgroup_resize_limit() won't break.
> > > 
> > > This patch fixes it by decrementing retry_count regardless the return value
> > > of mem_cgroup_hierarchical_reclaim().
> > > 
> > 
> > Maybe a patch like this is necessary.  But details are not fixed yet. 
> > Any comments are welcome.
> > 
> > (This is base on my CSS ID patch set.)
> > 
> > -Kame
> > ==
> > 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > As Li Zefan pointed out, shrinking memcg's limit should return -EBUSY
> > after reasonable retries. This patch tries to fix the current behavior
> > of shrink_usage.
> > 
> > Before looking into "shrink should return -EBUSY" problem, we should fix
> > hierarchical reclaim code. It compares current usage and current limit,
> > but it only makes sense when the kernel reclaims memory because hit limits.
> > This is also a problem.
> > 
> > What this patch does are.
> > 
> >   1. add new argument "shrink" to hierarchical reclaim. If "shrink==true",
> >      hierarchical reclaim returns immediately and the caller checks the kernel
> >      should shrink more or not.
> >      (At shrinking memory, usage is always smaller than limit. So check for
> >       usage < limit is useless.)
> > 
> >   2. For adjusting to above change, 2 changes in "shrink"'s retry path.
> >      2-a. retry_count depends on # of children because the kernel visits
> > 	  the children under hierarchy one by one.
> >      2-b. rather than checking return value of hierarchical_reclaim's progress,
> > 	  compares usage-before-shrink and usage-after-shrink.
> > 	  If usage-before-shrink > usage-after-shrink, retry_count is
> > 	  decremented.
> 
> The code seems to do the reverse, it checks for
>         if (currusage >= oldusage)
> 
Ah, the text is wrong ;(

> > -		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> > -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true);
> > +		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
> >  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> > +		/* Usage is reduced ? */
> >  		if (curusage >= oldusage)
> >  			retry_count--;
> > +		else
> > +			oldusage = curusage;
> >  	}
> >  	return ret;
> >  }
> 
> Has this been tested? It seems OK to the naked eye :)
> 
Thank you, and yes, tested.
I'll try to make this patch simpler and queue on my stack.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
