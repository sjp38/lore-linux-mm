Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70D3560021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 00:33:49 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp07.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB95Xem2013221
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 16:33:40 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB95TpXM1102054
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 16:29:51 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB95Xc5v026288
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 16:33:39 +1100
Date: Wed, 9 Dec 2009 11:03:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-ID: <20091209053333.GC3722@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <200912081016.198135742@firstfloor.org>
 <20091208211639.8499FB151F@basil.firstfloor.org>
 <4B1F2FC6.7040406@cn.fujitsu.com>
 <20091209140620.79785cf9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091209140620.79785cf9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, menage@google.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-12-09 14:06:20]:

> On Wed, 09 Dec 2009 13:04:06 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > > +#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > > +u64 hwpoison_filter_memcg;
> > > +EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
> > > +static int hwpoison_filter_task(struct page *p)
> > > +{
> > > +	struct mem_cgroup *mem;
> > > +	struct cgroup_subsys_state *css;
> > > +	unsigned long ino;
> > > +
> > > +	if (!hwpoison_filter_memcg)
> > > +		return 0;
> > > +
> > > +	mem = try_get_mem_cgroup_from_page(p);
> > > +	if (!mem)
> > > +		return -EINVAL;
> > > +
> > > +	css = mem_cgroup_css(mem);
> > > +	ino = css->cgroup->dentry->d_inode->i_ino;
> > 
> > I have a question, can try_get_mem_cgroup_from_page() return
> > root_mem_cgroup?
> > 
> yes.
> 
> > if it can, then css->cgroup->dentry is NULL, if memcg is
> > not mounted and there is no subdir in memcg. Because the root
> > cgroup of an inactive subsystem has no dentry.
> > 
> 
> Nice catch. It sounds possible. That should be handled.
> 
> 

Yes, agreed, good catch!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
