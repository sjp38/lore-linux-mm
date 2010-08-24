Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 97FD46008DF
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 04:43:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O8hgnT030127
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 17:43:42 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E96D45DE51
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:43:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F25145DD77
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:43:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 66E801DB8038
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:43:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D944A1DB803A
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:43:38 +0900 (JST)
Date: Tue, 24 Aug 2010 17:38:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: use ID in page_cgroup
Message-Id: <20100824173839.d8285b85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93r5hojtly.fsf@ninji.mtv.corp.google.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93aaoco3ix.fsf@ninji.mtv.corp.google.com>
	<20100824165108.dd986751.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93r5hojtly.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 01:35:37 -0700
Greg Thelen <gthelen@google.com> wrote:

> > rcu_read_lock() is just for delaying to discard object, not for avoiding
> > racy updates. All _updates_ requires proper lock or speculative logic as
> > atomic_inc_not_zero() etc... Basically, RCU is for avoiding use-after-free.
> 
> 
> Thanks for the info.  Referring to your original patch:
> > @@ -2014,11 +2025,11 @@ static int mem_cgroup_move_account(struc
> >  {
> >  	int ret = -EINVAL;
> >  	lock_page_cgroup(pc);
> > -	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
> > +	if (PageCgroupUsed(pc) && id_to_memcg(pc->mem_cgroup, true) == from) {
> >  		__mem_cgroup_move_account(pc, from, to, uncharge);
> >  		ret = 0;
> >  	}
> > -	unlock_page_cgroup(pc);
> > +	rcu_read_unlock();
> > 
> 
> It seems like mem_cgroup_move_account() is not balanced.  Why is
> lock_page_cgroup(pc) used to lock but rcu_read_unlock() used to unlock?
> 

Nice catch. It's bug. It seems my eyes were corrupted..
Will be fixed in the next version. Sorry for bad code.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
