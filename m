Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A6BD6B0087
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 21:03:29 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0K23QCd012296
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jan 2009 11:03:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F0F245DE52
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:03:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 67D7F45DE50
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:03:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B8851DB8040
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:03:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E6F3A1DB8038
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:03:25 +0900 (JST)
Date: Tue, 20 Jan 2009 11:02:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
Message-Id: <20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009 17:39:40 -0800
Paul Menage <menage@google.com> wrote:

> On Thu, Jan 15, 2009 at 2:27 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > cgroup creation is done in several stages.
> > After allocated and linked to cgroup's hierarchy tree, all necessary
> > control files are created.
> >
> > When using CSS_ID, scanning cgroups without cgrouo_lock(), status
> > of cgroup is important. At removal of cgroup/css, css_tryget() works fine
> > and we can write a safe code.
> 
> What problems are you currently running into during creation? Won't
> the fact that the css for the cgroup has been created, and its pointer
> been stored in the cgroup, be sufficient?
> 
> Or is the problem that a cgroup that fails creation half-way could
> result in the memory code alreadying having taken a reference on the
> memcg, which can't then be cleanly destroyed?
> 
Ah, this is related to CSS ID scanning. No real problem to current codes.

Now, in my patch, CSS ID is attached just after create().

Then, "scan by CSS ID" can find a cgroup which is not populated yet.
I just wanted to skip them for avoiding mess.

For example, css_tryget() can succeed against css which belongs to not-populated
cgroup. If creation of cgroup fails, it's destroyed and freed without RCU synchronize.
This may breaks CSS ID scanning's assumption that "we're safe under rcu_read_lock".
And allows destroy css while css->refcnt > 1.

I'm now rewriting codes a bit, what I want is something like this.
==
	for_each_subsys(root, ss) {
		/* if error , goto destroy "/
		create();
		if (ss->use_id)
			attach_id();
	}
	create dir and populate files.
	.....
destroy:
	synchronize_rcu();
	/* start destroy here */
==

css_is_populated() is to show "ok, you can call css_tryget()".
If css_tryget() itself checks CSS_POPULATED bit, it's maybe clearer.

-Kame





> Paul
> 
> > "This cgroup is not ready yet"
> >
> > This patch adds CSS_POPULATED flag.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > ---
> > Index: mmotm-2.6.29-Jan14/include/linux/cgroup.h
> > ===================================================================
> > --- mmotm-2.6.29-Jan14.orig/include/linux/cgroup.h
> > +++ mmotm-2.6.29-Jan14/include/linux/cgroup.h
> > @@ -69,6 +69,7 @@ struct cgroup_subsys_state {
> >  enum {
> >        CSS_ROOT, /* This CSS is the root of the subsystem */
> >        CSS_REMOVED, /* This CSS is dead */
> > +       CSS_POPULATED, /* This CSS finished all initialization */
> >  };
> >
> >  /*
> > @@ -90,6 +91,11 @@ static inline bool css_is_removed(struct
> >        return test_bit(CSS_REMOVED, &css->flags);
> >  }
> >
> > +static inline bool css_is_populated(struct cgroup_subsys_state *css)
> > +{
> > +       return test_bit(CSS_POPULATED, &css->flags);
> > +}
> > +
> >  /*
> >  * Call css_tryget() to take a reference on a css if your existing
> >  * (known-valid) reference isn't already ref-counted. Returns false if
> > Index: mmotm-2.6.29-Jan14/kernel/cgroup.c
> > ===================================================================
> > --- mmotm-2.6.29-Jan14.orig/kernel/cgroup.c
> > +++ mmotm-2.6.29-Jan14/kernel/cgroup.c
> > @@ -2326,8 +2326,10 @@ static int cgroup_populate_dir(struct cg
> >        }
> >
> >        for_each_subsys(cgrp->root, ss) {
> > +               struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
> >                if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
> >                        return err;
> > +               set_bit(CSS_POPULATED, &css->flags);
> >        }
> >
> >        return 0;
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
