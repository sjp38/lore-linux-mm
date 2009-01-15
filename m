Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7325E6B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:13:12 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F6DAmA002906
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 15:13:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A1A4345DE51
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:13:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7661845DE52
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:13:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C8DDE08010
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:13:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 82FA0E08007
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:13:08 +0900 (JST)
Date: Thu, 15 Jan 2009 15:12:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] cgroup: support per cgroup subsys state ID
 (CSS ID)
Message-Id: <20090115151203.e79271c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090112072147.GB27129@balbir.in.ibm.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
	<20090112072147.GB27129@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Sorry for delayed reply.


On Mon, 12 Jan 2009 12:51:48 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 18:28:17]:
> > There are several reasons to develop this.
> > 	- Saving space .... For example, memcg's swap_cgroup is array of
> > 	  pointers to cgroup. But it is not necessary to be very fast.
> > 	  By replacing pointers(8bytes per ent) to ID (2byes per ent), we can
> > 	  reduce much amount of memory usage.
> 
> 2 bytes per entry means that we restrict the entries to 2^16-1 for
> number of cgroups, using a pointer introduces no such restriction.
> 2^16-1 seems a reasonable number for now.
> 
yes.


> >  /* bits in struct cgroup_subsys_state flags field */
> > @@ -363,6 +367,11 @@ struct cgroup_subsys {
> >  	int active;
> >  	int disabled;
> >  	int early_init;
> > +	/*
> > +	 * True if this subsys uses ID. ID is not available before cgroup_init()
> > +	 * (not available in early_init time.)
>                                             ^ period should come later
sure.

;
> > +	/*
> > +	 * Hierarchy of CSS ID belongs to.
> > +	 */
> > +	unsigned short  stack[0]; /* Array of Length (depth+1) */
> 
> By maintaining the path up to the root here, is that how we avoid walking
> through cgroups links?
> 
yes. we can check this css is under hierarchy by

   css->stack[root->depth] == root->id.


> > +/**
> >   * idr_replace - replace pointer for given id
> >   * @idp: idr handle
> >   * @ptr: pointer you want associated with the id
> >
> 
> Overall, I've taken a quick look and the patches seem OK.
> 
thx,

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
