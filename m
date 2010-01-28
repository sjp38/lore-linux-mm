Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A48D36B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 19:29:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0S0TKri009025
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 Jan 2010 09:29:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C17F945DE55
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 09:29:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8690D45DE52
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 09:29:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 68542E18006
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 09:29:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 18206E18003
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 09:29:20 +0900 (JST)
Date: Thu, 28 Jan 2010 09:26:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100128092600.95e044f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Thank you for comment. But I stoppped this already....

On Thu, 28 Jan 2010 00:16:36 +0000
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > Now, /proc/<pid>/oom_score and /proc/<pid>/oom_adj are used by servers.
> 
> And embedded, and some desktops (including some neat experimental hacks
> where windows slowly get to be bigger bigger oom targes the longer
> they've been non-focussed)
> 
Sure.

> > For my customers, I don't like oom black magic. I'd like to recommend to
> > use memcg, of course ;) But lowmem oom cannot be handled by memcg, well.
> > So I started from this. 
> 
> I can't help feeling this is the wrong approach. IFF we are running out
> of low memory pages then killing stuff for that reason is wrong to begin
> with except in extreme cases and those extreme cases are probably also
> cases the kill won't help.
> 
> If we have a movable user page (even an mlocked one) then if there is
> space in other parts of memory (ie the OOM is due to a single zone
> problem) we should *never* be killing in the first place, we should be
> moving the page. The mlock case is a bit hairy but the non mlock case is
> exactly the same sequence of operations as a page out and page in
> somewhere else skipping the widdling on the disk bit in the middle.
> 
> There are cases we can't do that - eg if the kernel has it pinned for
> DMA, but in that case OOM isn't going to recover the page either - at
> least not until the DMA or whatever unpins it (at which point you could
> just move it).
> 
> Am I missing something fundamental here ?
> 

I just wanted to make oom-killer shouldn't kill sshd or X-serivce or
task launcher IOW, oom-killer shouldn't do not-reasonalble selection.

If lowmem user is killed, I'll be satisfied with the cace "Oh, the process
is killed because lowmem was in short and it used lowmem, Hmmm..." and
never be satisfied with the cace "Ohch!, F*cking OOM killer killed X-server
and 10s of innocent processes!!!".

But year, I stop this. For me, panic_on_oom=1 is all and enough.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
