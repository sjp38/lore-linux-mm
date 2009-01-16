Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 673A86B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 02:50:56 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G7orOs009968
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 16:50:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7112045DE4F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:50:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3215E45DE53
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:50:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D7B2C1DB8038
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:50:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 70DAE1DB805B
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:50:52 +0900 (JST)
Date: Fri, 16 Jan 2009 16:49:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] memcg: hierarchical reclaim by CSS ID
Message-Id: <20090116164947.0c3cb725.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <497038CD.8010505@cn.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192943.7c1df53a.kamezawa.hiroyu@jp.fujitsu.com>
	<496FE30C.1090300@cn.fujitsu.com>
	<20090116103810.5ef55cc3.kamezawa.hiroyu@jp.fujitsu.com>
	<496FE791.9030208@cn.fujitsu.com>
	<20090116112211.ea4231aa.kamezawa.hiroyu@jp.fujitsu.com>
	<497038CD.8010505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 15:35:41 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> >>>>> +	while (!ret) {
> >>>>> +		rcu_read_lock();
> >>>>> +		nextid = root_mem->last_scanned_child + 1;
> >>>>> +		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
> >>>>> +				   &found);
> >>>>> +		if (css && css_is_populated(css) && css_tryget(css))
> >>>> I don't see why you need to check css_is_populated(css) ?
> >>>>
> >>> Main reason is for sanity. I don't like to hold css->refcnt of not populated css.
> >> I think this is a rare case. It's just a very short period when a cgroup is
> >> being created but not yet fully created.
> >>
> >>> Second reason is for avoinding unnecessary calls to try_to_free_pages(),
> >>> it's heavy. I should also add mem->res.usage == 0 case for skipping but not yet.
> >>>
> >> And if mem->res.usage == 0 is checked, css_is_popuated() is just redundant.
> >>
> > Hmm ? Can I check mem->res.usage before css_tryget() ?
> > 
> 
> I think you can. If css != NULL, css is valid (otherwise how can we access css->flags
> in css_tryget), so mem is valid. Correct me if I'm wrong. :)
> 
Ok, I'll remove css_is_populated(). (I alread removed it in my local set.)

BTW, because we can access cgroup outside of cgroup_lock via CSS ID scanning,
I want some way to confirm this cgroup is worth to be looked into or not.

*And* I think it's better to mark cgroup as NOT VALID in which initialization is
not complete.
And it's better to notify user that "you should rmdir this incomplete cgroup"
when populate() finally fails. Do you have  idea ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
