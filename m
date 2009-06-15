Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5C26B0099
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:15:42 -0400 (EDT)
Date: Mon, 15 Jun 2009 12:09:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: Low overhead patches for the memory cgroup controller (v4)
Message-Id: <20090615120933.61941977.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <4A35B936.70301@linux.vnet.ibm.com>
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
	<20090515181639.GH4451@balbir.in.ibm.com>
	<20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
	<20090531235121.GA6120@balbir.in.ibm.com>
	<20090602085744.2eebf211.kamezawa.hiroyu@jp.fujitsu.com>
	<20090605053107.GF11755@balbir.in.ibm.com>
	<20090614183740.GD23577@balbir.in.ibm.com>
	<20090615111817.84123ea1.nishimura@mxp.nes.nec.co.jp>
	<4A35B936.70301@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 08:30:06 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Daisuke Nishimura wrote:
> 
> >  	pc->mem_cgroup = mem;
> >  	smp_wmb();
> > -	pc->flags = pcg_default_flags[ctype];
> 
> pc->flags needs to be reset here, otherwise we have the danger the carrying over
> older bits. I'll merge your changes and test.
> 
hmm, why ?

I do in my patch:

+	switch (ctype) {
+	case MEM_CGROUP_CHARGE_TYPE_CACHE:
+	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
+		SetPageCgroupCache(pc);
+		SetPageCgroupUsed(pc);
+		break;
+	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+		ClearPageCgroupCache(pc);
+		SetPageCgroupUsed(pc);
+		break;
+	default:
+		break;
+	}

So, all the necessary flags are set and all the unnecessary ones are cleared, right ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
