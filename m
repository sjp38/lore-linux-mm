Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAH0dDBP010422
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 17 Nov 2008 09:39:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EC7C2AEA81
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:39:13 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 545711EF082
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:39:13 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 38A7C1DB803E
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:39:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id E9A2F1DB8038
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 09:39:12 +0900 (JST)
Date: Mon, 17 Nov 2008 09:38:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after
 swap_cluster_max pages
Message-Id: <20081117093832.f383bd61.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081116163316.F205.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081113171208.6985638e@bree.surriel.com>
	<20081116163316.F205.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 16:38:56 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> One more point.
> 
> > Sometimes the VM spends the first few priority rounds rotating back
> > referenced pages and submitting IO.  Once we get to a lower priority,
> > sometimes the VM ends up freeing way too many pages.
> > 
> > The fix is relatively simple: in shrink_zone() we can check how many
> > pages we have already freed and break out of the loop.
> > 
> > However, in order to do this we do need to know how many pages we already
> > freed, so move nr_reclaimed into scan_control.
> 
> IIRC, Balbir-san explained the implemetation of the memcgroup 
> force cache dropping feature need non bail out at the past reclaim 
> throttring discussion.
> 
> I am not sure about this still right or not (iirc, memcgroup implemetation
> was largely changed).
> 
> Balbir-san, Could you comment to this patch?
> 
> 
I'm not Balbir-san but there is no "force-cache-dropping" feature now.
(I have no plan to do that.)

But, mem+swap controller will need to modify reclaim path to do "cache drop
first" becasue the amount of "mem+swap" will not change when "mem+swap" hit
limit. It's now set "sc.may_swap" to 0.

Hmm, I hope memcg is a silver bullet to this kind of special? workload in
long term.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
