Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 824B86003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 20:01:37 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0R11WZv004793
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 Jan 2010 10:01:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DAF0545DE56
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 10:01:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9404745DE53
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 10:01:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 69EE21DB803F
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 10:01:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DDCB0E38004
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 10:01:30 +0900 (JST)
Date: Wed, 27 Jan 2010 09:58:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100126161952.ee267d1c.akpm@linux-foundation.org>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010 16:19:52 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 27 Jan 2010 08:53:55 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > Hardly anyone will know to enable
> > > it so the feature won't get much testing and this binary decision
> > > fractures the testing effort.  It would be much better if we can get
> > > everyone running the same code.  I mean, if there are certain workloads
> > > on certain machines with which the oom-killer doesn't behave correctly
> > > then fix it!
> > Yes, I think you're right. But "breaking current behaviro of our servers!"
> > arguments kills all proposal to this area and this oom-killer or vmscan is
> > a feature should be tested by real users. (I'll write fork-bomb detector
> > and RSS based OOM again.)
> 
> Well don't break their servers then ;)
> 
> What I'm not understanding is: why is it not possible to improve the
> behaviour on the affected machines without affecting the behaviour on
> other machines?
> 

Now, /proc/<pid>/oom_score and /proc/<pid>/oom_adj are used by servers.
After this patch, badness() returns different value based on given context.
Changing format of them was an idea, but, as David said, using "RSS" values
will show unstable oom_score. So, I didn't modify oom_score (for this time).

To be honest, all my work are for guys who don't tweak oom_adj based on oom_score.
IOW, this is for usual novice people. And I don't wan't to break servers which
depends on oom black magic currently supported.

It may be better to show lowmem_rss via /proc/<pid>/statm or somewhere. But
I didn't do that because usual people doesn't check that in periodic and
tweak oom_adj.

For my customers, I don't like oom black magic. I'd like to recommend to
use memcg, of course ;) But lowmem oom cannot be handled by memcg, well.
So I started from this. 


> What are these "servers" to which you refer?
Almost all servers/PCs/laptops which have multiple zones in memory layout.


> x86_32 servers, I assume
> - the patch shouldn't affect 64-bit machines.  Why don't they also want
> this treatment and in what way does the patch "break" them?

Ah, explanation was not enough.

This patch depends on mm-add-lowmem-detection-logic.patch
The lowmem is
   - ZONE_NORMAL in x86-32 which has HIGHMEM
   - ZONE_DMA32  in x86-64 which has ZONE_NORMAL
   - ZONE_DMA    in x86-64 which doesn't have ZONE_NORMAL(memory < 4G)
   - ZONE_DMA    in ia64 which has ZONE_NORMAL(memory > 4G)
   - no zone     in ppc. all zone are DMA. (lowmem_zone=-1)

So, this affects x86-64 hosts, especially when it has 4 Gbytes of memory
and 32bit pci cards.

Thanks,
-Kame














--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
