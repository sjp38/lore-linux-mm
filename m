Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C8B956B0353
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 22:01:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O217AZ014345
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 11:01:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 896D345DE51
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 11:01:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BC3B45DD77
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 11:01:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 365A01DB803B
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 11:01:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E91F71DB8038
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 11:01:06 +0900 (JST)
Date: Tue, 24 Aug 2010 10:54:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: use ID in page_cgroup
Message-Id: <20100824105405.abf226e6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100824101425.2dc25773.nishimura@mxp.nes.nec.co.jp>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823143237.b7822ffc.nishimura@mxp.nes.nec.co.jp>
	<20100824085243.8dd3c8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20100824101425.2dc25773.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 10:14:25 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > > @@ -723,6 +729,11 @@ static inline bool mem_cgroup_is_root(st
> > > >  	return (mem == root_mem_cgroup);
> > > >  }
> > > >  
> > > > +static inline bool mem_cgroup_is_rootid(unsigned short id)
> > > > +{
> > > > +	return (id == 1);
> > > > +}
> > > > +
> > > It might be better to add
> > > 
> > > 	BUG_ON(newid->id != 1)
> > > 
> > > in cgroup.c::cgroup_init_idr().
> > > 
> > 
> > Why ??
> > 
> Just to make sure that the root css has id==1. mem_cgroup_is_rootid() make
> use of the fact.
> I'm sorry if I miss something.
> 

Hmm. The function allocating ID does

4530 static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
4531 {
==
4546         spin_lock(&ss->id_lock);
4547         /* Don't use 0. allocates an ID of 1-65535 */
4548         error = idr_get_new_above(&ss->idr, newid, 1, &myid);
4549         spin_unlock(&ss->id_lock);
==

and allocates ID above "1", always.

Adding BUG_ON(newid->id != 1) will mean that we doubt the bitmap function and
consider possibility that new->id == 0.

But, we're 100% sure that it never happens.

I don't think adding a comment is a right thing to do.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
