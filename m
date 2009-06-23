Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 032816B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 00:44:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N4jtom012934
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 13:45:55 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F76A45DE4E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:45:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F12B145DE50
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:45:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB3FDE08003
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:45:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E0751DB803C
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:45:54 +0900 (JST)
Date: Tue, 23 Jun 2009 13:44:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] cgroup: fix permanent wait in rmdir
Message-Id: <20090623134420.9103eac5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090623131333.be387c84.nishimura@mxp.nes.nec.co.jp>
References: <20090622183707.dd9e665b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090623092223.a44e7b20.kamezawa.hiroyu@jp.fujitsu.com>
	<20090623131333.be387c84.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009 13:13:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 23 Jun 2009 09:22:23 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 22 Jun 2009 18:37:07 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > previous discussion was this => http://marc.info/?t=124478543600001&r=1&w=2
> > > 
> > > I think this is a minimum fix (in code size and behavior) and because
> > > we can take a BIG LOCK, this kind of check is necessary, anyway.
> > > Any comments are welcome.
> > 
> > I'll split this into 2 patches...and I found I should check page-migration, too.
> I'll wait a new version, but can you explain in advance this page-migration case ?
> 

Not far from swap-in case.

Assume cgroup "A" which includes file caches. A task in other group mmap file caches
and do page migration and rmdir against "A" is called at the same time.

In mem_cgroup_prepare_migration(), following check is used.

==
	lock_page_cgroup(pc);
	if (PageCgroupUsed(pc)) {
		mem = pc->mem_cgroup;
		css_get(&mem->css);
	}
	unlock_page_cgroup(pc);
	<======================================(*)
	if (mem) {
		<==============================(**)
		try_charge();
		...
	}
==

At (*), we grab css refcnt which can be under pre_destroy() and
At (**), pre_destroy may returns 0 but charge may be done after the end of pre_destroy().


> > > +static int mem_cgroup_retry_rmdir(struct cgroup_subsys *ss,
> > > +				  struct cgroup *cont)
> > > +{
> > > +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> > > +
> > > +	if (res_counter_read_u64(&memcg->res, RES_USAGE))
> It should be &mem->res.
> 
yes.
too many typos in my patches in these days..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
