Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 845336B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 21:19:26 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n162JNZP027280
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Feb 2009 11:19:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9119045DE51
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 11:19:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 70B0745DE4F
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 11:19:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5738B1DB805B
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 11:19:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 143D11DB8043
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 11:19:23 +0900 (JST)
Date: Fri, 6 Feb 2009 11:18:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID
Message-Id: <20090206111812.da1de0d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <498B9B6C.3000808@cn.fujitsu.com>
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
	<498B9B6C.3000808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Feb 2009 10:07:40 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > +/*
> > + * A helper function to get mem_cgroup from ID. must be called under
> > + * rcu_read_lock(). Because css_tryget() is called under this, css_put
> > + * should be called later.
> > + */
> > +static struct mem_cgroup *mem_cgroup_lookup_get(unsigned short id)
> > +{
> > +	struct cgroup_subsys_state *css;
> > +
> > +	/* ID 0 is unused ID */
> > +	if (!id)
> > +		return NULL;
> > +	css = css_lookup(&mem_cgroup_subsys, id);
> > +	if (css && css_tryget(css))
> > +		return container_of(css, struct mem_cgroup, css);
> > +	return NULL;
> > +}
> 
> the returned mem_cgroup needn't be protected by rcu_read_lock(), so I
> think this is better:
> 	rcu_read_lock();
> 	css = css_lookup(&mem_cgroup_subsys, id);
> 	rcu_read_unlock();
> and no lock is needed when calling mem_cgroup_lookup_get().
> 
Hmm, maybe you're right.

> >   * Returns old value at success, NULL at failure.
> >   * (Of course, old value can be NULL.)
> >   */
> > -struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> > +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
> 
> kernel-doc needs to be updated
> 
ok.

> >   * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
> >   * @ent: swap entry to be looked up.
> >   *
> > - * Returns pointer to mem_cgroup at success. NULL at failure.
> > + * Returns CSS ID of mem_cgroup at success. NULL at failure.
> 
> s/NULL/0/
> 
yes.

Okay, thanks.

BTW, this patch is totally buggy ;( Sorry. Below is my memo.
==

 - mem_cgroup can by destroyed() while there are swap_cgroup point to mem_cgroup.
   If there are reference from swap_cgroup, kfree() is delayed.
 - But this patch just uses css_tryget(). css_tryget() returnes false if
   mem_cgroup is destroyed.
 - So, refcnt for destroyed mem_cgroup will not be decreased and memory for
   mem_cgroup will be never freed.

 - Even if we use ID instead of pointer, the situation does not change.
   we have to prevent ID to be reused....
 - One choice for removing all swap_account at destroy() is forget all swap
   accounts. But this may need "scan" all swap_cgroup in the system at rmdir().
   This will be unacceptably slow on large swap systems. 
==

I'll post v2 but it will be still tricky. 

Thanks,
-Kame


















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
