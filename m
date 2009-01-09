Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BCB326B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 23:48:41 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n094mddL014612
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Jan 2009 13:48:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 66E0D45DD82
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 13:48:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4532645DD76
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 13:48:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6D891DB803C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 13:48:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 75BC91DB803A
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 13:48:38 +0900 (JST)
Date: Fri, 9 Jan 2009 13:47:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: fix for
 mem_cgroup_get_reclaim_stat_from_page
Message-Id: <20090109134736.a995fc49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090109043257.GB9737@balbir.in.ibm.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
	<20090109043257.GB9737@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 10:02:57 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> >  	pc = lookup_page_cgroup(page);
> > +	smp_rmb();
> 
> Do you really need the read memory barrier?
> 
Necessary.

> > +	if (!PageCgroupUsed(pc))
> > +		return NULL;
> > +
> 
> In this case we've hit a case where the page is valid and the pc is
> not. This does fix the problem, but won't this impact us getting
> correct reclaim stats and thus indirectly impact the working of
> pressure?
> 
 - If retruns NULL, only global LRU's status is updated. 

Because this page is not belongs to any memcg, we cannot update
any counters. But yes, your point is a concern.

Maybe moving acitvate_page() to
==
do_swap_page()
{
    
- activate_page()
   mem_cgroup_try_charge()..
   ....
   mem_cgroup_commit_charge()....
   ....
+  activate_page()   
}
==
is necessary. How do you think, kosaki ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
