Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A39BF6B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 19:10:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0S0AVP9008874
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jan 2009 09:10:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CF8F45DD7E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:10:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2641D45DD7D
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:10:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07FE01DB803B
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:10:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AED331DB8037
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:10:30 +0900 (JST)
Date: Wed, 28 Jan 2009 09:09:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [FIX][PATCH 6/7] cgroup/memcg: fix frequent -EBUSY at rmdir
Message-Id: <20090128090924.23653c8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090126165823.dcf9cf78.randy.dunlap@oracle.com>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090122184018.5cd3c3b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090126165823.dcf9cf78.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Jan 2009 16:58:23 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Thu, 22 Jan 2009 18:40:18 +0900 KAMEZAWA Hiroyuki wrote:
> 
> >  Documentation/cgroups/cgroups.txt |    6 +-
> >  include/linux/cgroup.h            |   16 +-----
> >  kernel/cgroup.c                   |   97 ++++++++++++++++++++++++++++++++------
> >  mm/memcontrol.c                   |    5 +
> >  4 files changed, 93 insertions(+), 31 deletions(-)
> > 
> > Index: mmotm-2.6.29-Jan16/Documentation/cgroups/cgroups.txt
> > ===================================================================
> > --- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/cgroups.txt
> > +++ mmotm-2.6.29-Jan16/Documentation/cgroups/cgroups.txt
> > @@ -478,11 +478,13 @@ cgroup->parent is still valid. (Note - c
> >  newly-created cgroup if an error occurs after this subsystem's
> >  create() method has been called for the new cgroup).
> >  
> > -void pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
> > +int pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
> >  
> >  Called before checking the reference count on each subsystem. This may
> >  be useful for subsystems which have some extra references even if
> > -there are not tasks in the cgroup.
> > +there are not tasks in the cgroup. If pre_destroy() returns error code,
> > +rmdir() will fail with it. From this behavior, pre_destroy() can be
> > +called plural times against a cgroup.
> 
> s/plural/multiple/ please.
> 
ok, thank you for review.

-Kame

> >  
> >  int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> >  	       struct task_struct *task)
> 
> 
> ---
> ~Randy
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
