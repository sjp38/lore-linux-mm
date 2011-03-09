Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ACE538D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:24:29 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p29LOHMq007574
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 13:24:26 -0800
Received: from gwaa18 (gwaa18.prod.google.com [10.200.27.18])
	by kpbe18.cbf.corp.google.com with ESMTP id p29LCEBe013411
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 13:13:14 -0800
Received: by gwaa18 with SMTP id a18so214283gwa.5
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 13:13:14 -0800 (PST)
Date: Wed, 9 Mar 2011 13:12:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110307165119.436f5d21.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com> <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com> <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com> <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com> <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com> <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 9 Mar 2011, KAMEZAWA Hiroyuki wrote:

> For me, I want an oom-killall module Or oom-SIGSTOP-all module.
> oom-killall will be useful for killing fork-bombs and very quick recovery.
> 

That doesn't need to be in kernelspace, though, the global oom killer will 
give access to memory reserves to any task that invokes it that has a 
pending SIGKILL, so we could extend that to the memcg oom killer as well 
and then use an oom notifier to trigger a killall in userspace.

> For me, the 1st motivation of oom-disable is to taking core-dump of 
> memory leaking process and look into it for checking memory leak.
> (panic_on_oom -> kdump is used for supporting my customer.)
> 

I remember your advocacy of panic_on_oom during the oom killer rewrite 
discussion, this makes it more clear.

> Anyway, if you add notifier, please give us a user of it. If possible,
> it should be a function which can never be implemented in userland even
> with sane programmers, admins, and users.
> 
> For example, if all process's oom_score_adj was set to -1000 and oom-killer
> doesn't work, do you implement a timeout ? I think you'll say it's a
> wrong configuration. memcg's oom_disable timeout is the same thing.
> 

You know me quite well, actually :)  We've agreed to drop this patch and 
carry it internally until we can deprecate it and implement a separate oom 
handling thread in the root memcg that will detect the situation for a 
given period of time (either via an oom notifier or by checking that the 
usage of the memcg of interest equals to the limit) and then do the 
killall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
