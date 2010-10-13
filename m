Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7B7CF6B00F3
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 02:26:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D6Q2vk021044
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 15:26:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2F7345DE55
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:26:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 30E7245DE52
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:26:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 125A81DB8057
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:26:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 956A71DB8056
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:26:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 0/3] mm: reserve max drift pages at boot time instead using zone_page_state_snapshot()
In-Reply-To: <20101013121913.ADB4.A69D9226@jp.fujitsu.com>
References: <20101012162526.GG30667@csn.ul.ie> <20101013121913.ADB4.A69D9226@jp.fujitsu.com>
Message-Id: <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 15:25:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> > @@ -2378,7 +2378,9 @@ static int kswapd(void *p)
> >  				 */
> >  				if (!sleeping_prematurely(pgdat, order, remaining)) {
> >  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +					enable_pgdat_percpu_threshold(pgdat);
> >  					schedule();
> > +					disable_pgdat_percpu_threshold(pgdat);
> 
> If we have 4096 cpus, max drift = 125x4096x4096 ~= 2GB. It is higher than zone watermark.
> Then, such sysmtem can makes memory exshost before kswap call disable_pgdat_percpu_threshold().
> 
> Hmmm....
> This seems fundamental problem. current our zone watermark and per-cpu stat threshold have completely
> unbalanced definition.
> 
> zone watermak:             very few (few mega bytes)
>                                        propotional sqrt(mem)
>                                        no propotional nr-cpus
> 
> per-cpu stat threshold:  relatively large (desktop: few mega bytes, server ~50MB, SGI 2GB ;-)
>                                        propotional log(mem)
>                                        propotional log(nr-cpus)
> 
> It mean, much cpus break watermark assumption.....

I've tryied to implement different patch.
The key idea is, max-drift is very small value if the system don't have
>1024CPU.

three model case: 

    Case1: typical desktop
      CPU: 2
      MEM: 2GB
      max-drift = 2 x log2(2) x log2(2x1024/128) x 2 = 40 pages

    Case2: relatively large server
      CPU: 64
      MEM: 8GBx4 (=32GB)
      max-drift = 2 x log2(64) x log2(8x1024/128) x 64 = 6272 pages = 24.5MB

    Case3: ultimately big server
      CPU: 2048
      MEM: 64GBx256 (=16TB)
      max-drift = 125 x 2048 = 256000 pages = 1000MB


So, I think we can accept 20MB memory waste for good performance. but can't
accept 1000MB waste ;-)
Fortunatelly, >1000CPU machine are always used for HPC in nowadays. then,
zone_page_state_snapshot() overhead isn't so big matter on it.

So, My idea is,

Case1 and Case2: reserve max-drift pages at first.
Case3:           using zone_page_state_snapshot()




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
