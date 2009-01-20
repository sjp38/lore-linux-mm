Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F21706B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 21:59:40 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0K2xcJc002880
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jan 2009 11:59:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1015045DE55
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:59:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAD3445DE53
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:59:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A14091DB8040
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:59:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 432F9E08003
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 11:59:37 +0900 (JST)
Date: Tue, 20 Jan 2009 11:58:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
Message-Id: <20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	<20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009 18:23:03 -0800
Paul Menage <menage@google.com> wrote:

> On Mon, Jan 19, 2009 at 6:02 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Ah, this is related to CSS ID scanning. No real problem to current codes.
> >
> > Now, in my patch, CSS ID is attached just after create().
> >
> > Then, "scan by CSS ID" can find a cgroup which is not populated yet.
> > I just wanted to skip them for avoiding mess.
> >
> > For example, css_tryget() can succeed against css which belongs to not-populated
> > cgroup. If creation of cgroup fails, it's destroyed and freed without RCU synchronize.
> > This may breaks CSS ID scanning's assumption that "we're safe under rcu_read_lock".
> > And allows destroy css while css->refcnt > 1.
> 
> So for the CSS ID case, we could solve this by not populating
> css_id->css until creation is guaranteed to have succeeded? (We'd
> still allocated the css_id along with the subsystem, just not complete
> its initialization). cgroup.c already knows about and hides the
> details of css_id, so this wouldn't be hard.
> 

Hmm, moving this call to after populate is not good because
id > max_id cannot be handled ;)

> +               if (ss->use_id)
> +                       if (alloc_css_id(ss, parent, cgrp))
> +                               goto err_destroy;
> +               /* At error, ->destroy() callback has to free assigned ID. */
>        }

Should I delay to set css_id->css pointer to valid value until the end of
populate() ? (add populage_css_id() call after cgroup_populate_dir()).

I'd like to write add-on patch to the patch [1/4]. (or update it.)
css_id->css == NULL case is handled now, anyway.



> The question is whether other users of css_tryget() might run into
> this problem, without using CSS IDs. But currently no-one's using
> css_tryget() apart from you, so that's a problem we can solve as it
> arises.
> 
yes ;)

> I think we're safe from css_get() being used in this case, since
> css_get() can only be used on css references obtained from a locked
> task, or from other pointers that are known to be ref-counted, which
> would be impossible if css_tryget() can't succeed on a css in the
> partially-completed state.
> 
> 

Thanks, I'll try some other patch. Maybe it's ok to delay updating css_id->css
pointer.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
