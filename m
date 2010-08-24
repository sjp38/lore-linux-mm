Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E016660080F
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 00:08:40 -0400 (EDT)
Date: Tue, 24 Aug 2010 13:04:02 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: use ID in page_cgroup
Message-Id: <20100824130402.9ee7447b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100824105405.abf226e6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823143237.b7822ffc.nishimura@mxp.nes.nec.co.jp>
	<20100824085243.8dd3c8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20100824101425.2dc25773.nishimura@mxp.nes.nec.co.jp>
	<20100824105405.abf226e6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 10:54:05 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 24 Aug 2010 10:14:25 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > > > @@ -723,6 +729,11 @@ static inline bool mem_cgroup_is_root(st
> > > > >  	return (mem == root_mem_cgroup);
> > > > >  }
> > > > >  
> > > > > +static inline bool mem_cgroup_is_rootid(unsigned short id)
> > > > > +{
> > > > > +	return (id == 1);
> > > > > +}
> > > > > +
> > > > It might be better to add
> > > > 
> > > > 	BUG_ON(newid->id != 1)
> > > > 
> > > > in cgroup.c::cgroup_init_idr().
> > > > 
> > > 
> > > Why ??
> > > 
> > Just to make sure that the root css has id==1. mem_cgroup_is_rootid() make
> > use of the fact.
> > I'm sorry if I miss something.
> > 
> 
> Hmm. The function allocating ID does
> 
> 4530 static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
> 4531 {
> ==
> 4546         spin_lock(&ss->id_lock);
> 4547         /* Don't use 0. allocates an ID of 1-65535 */
> 4548         error = idr_get_new_above(&ss->idr, newid, 1, &myid);
> 4549         spin_unlock(&ss->id_lock);
> ==
> 
> and allocates ID above "1", always.
> 
> Adding BUG_ON(newid->id != 1) will mean that we doubt the bitmap function and
> consider possibility that new->id == 0.
> 
> But, we're 100% sure that it never happens.
> 
> I don't think adding a comment is a right thing to do.
> 
Okey, I don't have strong requirement to add BUG_ON() anyway.

These patches looks good to me except for some minor points I've commented.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
