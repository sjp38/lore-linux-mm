Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AE13460021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 00:09:32 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB959TCC027088
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Dec 2009 14:09:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BB9E445DE57
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 14:09:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 88A0445DE55
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 14:09:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F9DC1DB8043
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 14:09:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C6F63E1800B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 14:09:28 +0900 (JST)
Date: Wed, 9 Dec 2009 14:06:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-Id: <20091209140620.79785cf9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B1F2FC6.7040406@cn.fujitsu.com>
References: <200912081016.198135742@firstfloor.org>
	<20091208211639.8499FB151F@basil.firstfloor.org>
	<4B1F2FC6.7040406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, menage@google.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 09 Dec 2009 13:04:06 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > +#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +u64 hwpoison_filter_memcg;
> > +EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
> > +static int hwpoison_filter_task(struct page *p)
> > +{
> > +	struct mem_cgroup *mem;
> > +	struct cgroup_subsys_state *css;
> > +	unsigned long ino;
> > +
> > +	if (!hwpoison_filter_memcg)
> > +		return 0;
> > +
> > +	mem = try_get_mem_cgroup_from_page(p);
> > +	if (!mem)
> > +		return -EINVAL;
> > +
> > +	css = mem_cgroup_css(mem);
> > +	ino = css->cgroup->dentry->d_inode->i_ino;
> 
> I have a question, can try_get_mem_cgroup_from_page() return
> root_mem_cgroup?
> 
yes.

> if it can, then css->cgroup->dentry is NULL, if memcg is
> not mounted and there is no subdir in memcg. Because the root
> cgroup of an inactive subsystem has no dentry.
> 

Nice catch. It sounds possible. That should be handled.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
