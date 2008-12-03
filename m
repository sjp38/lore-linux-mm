Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB33tUEw026121
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 12:55:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E41E45DD87
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 12:55:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57B7945DD81
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 12:55:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D3B71DB8041
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 12:55:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB9D41DB803C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 12:55:29 +0900 (JST)
Date: Wed, 3 Dec 2008 12:54:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] cgroup: fix pre_destroy and semantics of
 css->refcnt
Message-Id: <20081203125440.482279ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <493600A4.6040802@cn.fujitsu.com>
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
	<20081201150208.6b24506b.kamezawa.hiroyu@jp.fujitsu.com>
	<493600A4.6040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 03 Dec 2008 11:44:36 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > +/*
> > + * Try to set all subsys's refcnt to be 0.
> > + * css->refcnt==0 means this subsys will be destroy()'d.
> > + */
> > +static bool cgroup_set_subsys_removed(struct cgroup *cgrp)
> > +{
> > +	struct cgroup_subsys *ss;
> > +	struct cgroup_subsys_state *css, *tmp;
> > +
> > +	for_each_subsys(cgrp->root, ss) {
> > +		css = cgrp->subsys[ss->subsys_id];
> > +		if (!atomic_dec_and_test(&css->refcnt))
> > +			goto rollback;
> > +	}
> > +	return true;
> > +rollback:
> > +	for_each_subsys(cgrp->root, ss) {
> > +		tmp = cgrp->subsys[ss->subsys_id];
> > +		atomic_inc(&tmp->refcnt);
> > +		if (tmp == css)
> > +			break;
> > +	}
> > +	return false;
> > +}
> > +
> 
> This function may return false, then causes rmdir() fail. So css_tryget(subsys1)
> returns 0 doesn't necessarily mean subsys1->destroy() will be called,
> if subsys2's css's refcnt is >1 when cgroup_set_subsys_removed() is called.
> 
> Will this bring up bugs and problems?
> 

current user of css_get() is only memcg, so no problem now.

"css_tryget() fails" means "rmdir" is called against this cgroup. So, not so
troublesome in genral, I think. (the user will retry rmdir()).

To be honest, I don't want to return -EBUSY but wait for success in the kernel.
and go back to pre_destroy() for this temporal race.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
