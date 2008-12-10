Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBA2Ogk9011223
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 11:24:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6445C45DD7E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:24:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A8A145DD7D
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:24:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18F4A1DB803A
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:24:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4C931DB803C
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:24:41 +0900 (JST)
Date: Wed, 10 Dec 2008 11:23:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Message-Id: <20081210112348.3060f1d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <493F2737.9060901@cn.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	<493F2737.9060901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 10:19:35 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > +static bool memcg_is_obsolete(struct mem_cgroup *mem)
> > +{
> 
> Will this function be called with mem->css.refcnt == 0? If yes, then
> this function is racy.
> 
> cg = mem->css.cgroup
> 				cgroup_diput()
> 				  mem_cgroup_destroy()
> 				    mem->css.cgroup = NULL;
> 				  kfree(cg);
> if (!cg || cgroup_is_removed(cg)...)
> 
> (accessing invalid cg)
> 
Hmm.  then we have to add flag to css itself, anyway.


> > +	struct cgroup *cg = mem->css.cgroup;
> > +	/*
> > +	 * "Being Removed" means pre_destroy() handler is called.
> > +	 * After  "pre_destroy" handler is called, memcg should not
> > +	 * have any additional charges.
> > +	 * This means there are small races for mis-accounting. But this
> > +	 * mis-accounting should happen only under swap-in opration.
> > +	 * (Attachin new task will fail if cgroup is under rmdir()).
> > +	 */
> > +
> > +	if (!cg || cgroup_is_removed(cg) || cgroup_is_being_removed(cg))
> > +		return true;
> > +	return false;
> > +}
> > +
> 
> ...
> 
> >  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
> >  				struct cgroup *cont)
> >  {
> > -	mem_cgroup_free(mem_cgroup_from_cont(cont));
> > +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont):
> > +	mem_cgroup_free(mem);
> > +	/* forget */
> > +	mem->css.cgroup = NULL;
> 
> mem might already be destroyed by mem_cgroup_free(mem).
> 
Ah, maybe. will fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
