Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D54962012A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 21:16:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o741GhdA021602
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Aug 2010 10:16:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E1DD45DE53
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:16:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4239B45DE51
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:16:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C6F1D1DB801C
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:16:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E90881DB8016
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:16:40 +0900 (JST)
Date: Wed, 4 Aug 2010 10:11:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 3/5] memcg scalable file stat accounting method
Message-Id: <20100804101150.d7b05ce2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100804095513.6fef0a3d.nishimura@mxp.nes.nec.co.jp>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191559.6af0cded.kamezawa.hiroyu@jp.fujitsu.com>
	<20100804095513.6fef0a3d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 2010 09:55:13 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -1074,7 +1075,49 @@ static unsigned int get_swappiness(struc
> >  	return swappiness;
> >  }
> >  
> > -/* A routine for testing mem is not under move_account */
> > +static void mem_cgroup_start_move(struct mem_cgroup *mem)
> > +{
> > +	int cpu;
> > +	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
> > +	spin_lock(&mc.lock);
> > +	for_each_possible_cpu(cpu)
> > +		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> > +	spin_unlock(&mc.lock);
> > +
> > +	synchronize_rcu();
> > +}
> > +
> > +static void mem_cgroup_end_move(struct mem_cgroup *mem)
> > +{
> > +	int cpu;
> > +
> > +	if (!mem)
> > +		return;
> Is this check necessary?
> 

Yes, I hit NULL here.
That happens migration=off case, IIRC.

Thanks,
-Kame

> Thanks,
> Daisuke Nishimura.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
