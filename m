Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00D8B8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:36:56 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p280as0Q030130
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 16:36:54 -0800
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz5.hot.corp.google.com with ESMTP id p280aBi5009937
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 16:36:53 -0800
Received: by pzk36 with SMTP id 36so1076272pzk.30
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 16:36:52 -0800 (PST)
Date: Mon, 7 Mar 2011 16:36:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110307162912.2d8c70c1.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
 <20110303135223.0a415e69.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011, Andrew Morton wrote:

> > So the question I'd ask is
> 
> What about my question?  Why is your usersapce oom-handler "unresponsive"?
> 

If we have a per-memcg userspace oom handler, then it's absolutely 
required that it either increase the hard limit of the oom memcg or kill a 
task to free memory; anything else risks livelocking that memcg.  At 
the same time, the oom handler's memcg isn't really important: it may be 
in a different memcg but it may be oom at the same time.  If we risk 
livelocking the memcg when it is oom and the oom killer cannot respond 
(the only reason for the oom killer to exist in the first place), then 
there's no guarantee that a userspace oom handler could respond under 
livelock.

For users who don't choose to implement their own userspace oom handler, 
memory.oom_delay_millisecs could also be used to delay killing a task in a 
memcg unless it has reached the hard limit for only a specific period of 
time and doesn't rely on memory thresholds to signal the task to start 
freeing some of its own memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
