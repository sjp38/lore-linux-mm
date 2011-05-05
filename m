Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 553D26B0011
	for <linux-mm@kvack.org>; Thu,  5 May 2011 17:00:51 -0400 (EDT)
Date: Thu, 5 May 2011 14:00:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Message-Id: <20110505140000.e4f315b5.akpm@linux-foundation.org>
In-Reply-To: <1304431865.2576.3.camel@mulgrave.site>
References: <1304366849.15370.27.camel@mulgrave.site>
	<20110502224838.GB10278@cmpxchg.org>
	<BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
	<1304380698.15370.36.camel@mulgrave.site>
	<20110503063817.GD10278@cmpxchg.org>
	<1304431865.2576.3.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Balbir Singh <balbir@linux.vnet.ibm.com>


The trail seems to have cooled off here, but it's pretty urgent.

Having re-read the threads I find it notable that James hit a kswapd
softlockup with "non-PREEMPT CGROUP but disabled GROUP_MEM_RES_CTLR". 
This suggests that the problem isn't with memcg.  Or at least, we
should fix this kswapd lockup before worrying about memcg.

And I'm not sure that we should be assuming that there's something
wrong in shrink_slab().  We know that kswapd has gone berserk, and that
it will frequently call shrink_slab() when in that mode.  But this may
be because the top-level balance_pgdat() loop isn't terminating for
reasons unrelated to shrink_slab().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
