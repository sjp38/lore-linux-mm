Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 266CD6B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 19:30:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5PNVU2l000612
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 26 Jun 2009 08:31:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7690945DE6E
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:31:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 48B0645DE60
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:31:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 245641DB8041
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:31:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C71AD1DB803B
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:31:29 +0900 (JST)
Date: Fri, 26 Jun 2009 08:29:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] memcg: cgroup fix rmdir hang
Message-Id: <20090626082956.a90335db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090625142809.ac6b7b85.akpm@linux-foundation.org>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090625142809.ac6b7b85.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009 14:28:09 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 23 Jun 2009 16:07:20 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > previous discussion was this => http://marc.info/?t=124478543600001&r=1&w=2
> > 
> > This patch tries to fix problem as
> >   - rmdir can sleep very very long if swap entry is shared between multiple
> >     cgroups
> > 
> > Now, cgroup's rmdir path does following
> > 
> > ==
> > again:
> > 	check there are no tasks and children group.
> > 	call pre_destroy()
> > 	check css's refcnt
> > 	if (refcnt > 0) {
> > 		sleep until css's refcnt goes down to 0.
> > 		goto again
> > 	}
> > ==
> > 
> > Unfortunately, memory cgroup does following at charge.
> > 
> > 	css_get(&memcg->css)
> > 	....
> > 	charge(memcg) (increase USAGE)
> > 	...
> > And this "memcg" is not necessary to include the caller, task.
> > 
> > pre_destroy() tries to reduce memory usage until USAGE goes down to 0.
> > Then, there is a race that
> > 	- css's refcnt > 0 (and memcg's usage > 0)
> > 	- rmdir() caller sleeps until css->refcnt goes down 0.
> > 	- But to make css->refcnt be 0, pre_destroy() should be called again.
> > 
> > This patch tries to fix this in asyhcnrounos way (i.e. without big lock.)
> > Any comments are welcome.
> > 
> 
> Do you believe that these fixes should be backported into 2.6.30.x?

Yes, I think so. (If it's easy)

To be honest:

To cause the problem,
  - swap cgroup should be shared between cgroup.
  - rmdir should be called in critical chance.

Considering usual usage of cgroup is "container", there will be no share of swap
in typical users. But,  2.6.30 can be a base kernel of a major distro. So,
I hope this in 2.6.30 if we have no difficulties.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
