Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B13618D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 00:31:20 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p285UPsL023144
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 21:30:26 -0800
Received: from gye5 (gye5.prod.google.com [10.243.50.5])
	by wpaz17.hot.corp.google.com with ESMTP id p285U2jN032428
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 21:30:24 -0800
Received: by gye5 with SMTP id 5so2266013gye.38
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 21:30:24 -0800 (PST)
Date: Mon, 7 Mar 2011 21:30:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com> <20110303135223.0a415e69.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com> <20110307165119.436f5d21.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com> <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com> <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Mar 2011, KAMEZAWA Hiroyuki wrote:

> Hmm? That's an unexpected answer. Why system's capacity is problem here ?
> (root memcg has no 'limit' always.)
> 
> Is it a problem that 'there is no 'guarantee' or 'private page pool'
> for daemons ?
> 

It's not an inherent problem of memcg, it's a configuration issue: if your 
userspace application cannot respond to address an oom condition in a 
memcg for whatever reason (such as it being in an oom memcg itself), then 
there's a chance that the memcg will livelock since the kernel cannot do 
anything to fix the issue itself.

That's aside from the general purpose of the new 
memory.oom_delay_millisecs: users may want a grace period for userspace to 
increase the hard limit or kill a task before deferring to the kernel.  
That seems exponentially more useful than simply disabling the oom killer 
entirely with memory.oom_control.  I think it's unfortunate 
memory.oom_control was merged frst and seems to have tainted this entire 
discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
