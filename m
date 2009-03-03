Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8F9E36B0047
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 19:04:24 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2304Lni029414
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Mar 2009 09:04:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 976C645DE51
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:04:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AF4F45DE4E
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:04:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 451F01DB8041
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:04:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAD0C1DB803B
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:04:20 +0900 (JST)
Date: Tue, 3 Mar 2009 09:03:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090303090303.ca430b43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090302175235.GN11421@balbir.in.ibm.com>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
	<20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302044043.GC11421@balbir.in.ibm.com>
	<20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060519.GG11421@balbir.in.ibm.com>
	<20090302151830.3770e528.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302175235.GN11421@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009 23:22:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 15:18:30]:
> 
> > On Mon, 2 Mar 2009 11:35:19 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > > Then, not-sorted RB-tree can be there.
> > > > 
> > > > BTW,
> > > >    time_after(jiffies, 0)
> > > > is buggy (see definition). If you want make this true always,
> > > >    time_after(jiffies, jiffies +1)
> > > >
> > > 
> > > HZ/4 is 250/4 jiffies in the worst case (62). We have
> > > time_after(jiffies, next_update_interval) and next_update_interval is
> > > set to last_tree_update + 62. Not sure if I got what you are pointing
> > > to.
> > > 
> > +	unsigned long next_update = 0;
> > +	unsigned long flags;
> > +
> > +	if (!css_tryget(&mem->css))
> > +		return;
> > +	prev_usage_in_excess = mem->usage_in_excess;
> > +	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > +
> > +	if (time_check)
> > +		next_update = mem->last_tree_update +
> > +				MEM_CGROUP_TREE_UPDATE_INTERVAL;
> > +	if (new_usage_in_excess && time_after(jiffies, next_update)) {
> > +		if (prev_usage_in_excess)
> > +			mem_cgroup_remove_exceeded(mem);
> > +		mem_cgroup_insert_exceeded(mem);
> > +		updated_tree = true;
> > +	} else if (prev_usage_in_excess && !new_usage_in_excess) {
> > +		mem_cgroup_remove_exceeded(mem);
> > +		updated_tree = true;
> > +	}
> > 
> > My point is what happens if time_check==false.
> > time_afrter(jiffies, 0) is buggy.
> >
> 
> I see your point now, but the idea behind doing so is that
> time_after(jiffies, 0) will always return false, which forces the
> prev_usage_in_excess and !new_usage_in_excess check to execute. We set
> the value to false only from __mem_cgroup_free().
> 
> Are you suggesting that calling time_after(jiffies, 0) is buggy?
> The comment
> 
>   Do this with "<0" and ">=0" to only test the sign of the result. A
>  
> I think refers to the comparison check and not to the parameters. I
> hope I am reading this right.

 106 #define time_after(a,b)         \
 107         (typecheck(unsigned long, a) && \
 108          typecheck(unsigned long, b) && \
 109          ((long)(b) - (long)(a) < 0))

Reading above.

  if b==0.
     if (long)a <0  -> false
     if (long)a >0  -> true

jiffies is unsigned value. please think of bit-pattern of signed/unsigned value.


Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
