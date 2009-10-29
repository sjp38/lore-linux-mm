Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 94FC66B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 21:08:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9T180tl032290
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Oct 2009 10:08:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07F2545DE51
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:08:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D1B2A45DE4F
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:07:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D7A8F8008
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:07:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F81D8F8006
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:07:59 +0900 (JST)
Date: Thu, 29 Oct 2009 10:05:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix wrong pointer initialization at page
 migration when memcg is disabled.
Message-Id: <20091029100530.c8bafc53.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091029095051.7812e5ad.nishimura@mxp.nes.nec.co.jp>
References: <20091029093013.cd58f3a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091029095051.7812e5ad.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Lee.Schermerhorn@hp.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009 09:50:51 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > Index: linux-2.6.32-rc5/mm/memcontrol.c
> > ===================================================================
> > --- linux-2.6.32-rc5.orig/mm/memcontrol.c
> > +++ linux-2.6.32-rc5/mm/memcontrol.c
> > @@ -1990,7 +1990,8 @@ int mem_cgroup_prepare_migration(struct 
> >  	struct page_cgroup *pc;
> >  	struct mem_cgroup *mem = NULL;
> >  	int ret = 0;
> > -
> > +	/* this pointer will be checked at end_migration */
> > +	*ptr = NULL;
> >  	if (mem_cgroup_disabled())
> >  		return 0;
> >  
> > 
> I thought unmap_and_move() itself initializes "mem" to NULL, but it doesn't...
> I personaly prefer initializing "mem" to NULL in unmap_and_move(), but anyway
> I think this patch is also correct.
> 
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
Ok, here
> And I think we should send a fix for this bug to -stable too.
I think so, too.


==
Lee Schermerhorn reported that he saw bad pointer dereference
in mem_cgroup_end_migration() when he disabled memcg by boot option.

memcg's page migration logic works as

	mem_cgroup_prepare_migration(page, &ptr);
	do page migration
	mem_cgroup_end_migration(page, ptr);

Now, ptr is not initialized when memcg is disabled by boot option.
This patch fixes it.

Changelog: 2009/10/29
 - modified "fix" from memcontrol.c to migrate.c


Reported-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/migrate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.32-rc5/mm/migrate.c
===================================================================
--- linux-2.6.32-rc5.orig/mm/migrate.c
+++ linux-2.6.32-rc5/mm/migrate.c
@@ -602,7 +602,7 @@ static int unmap_and_move(new_page_t get
 	struct page *newpage = get_new_page(page, private, &result);
 	int rcu_locked = 0;
 	int charge = 0;
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem = NULL;
 
 	if (!newpage)
 		return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
