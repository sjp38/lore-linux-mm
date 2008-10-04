Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m94F57MC023450
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 5 Oct 2008 00:05:07 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A8741B8023
	for <linux-mm@kvack.org>; Sun,  5 Oct 2008 00:05:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D67082DC020
	for <linux-mm@kvack.org>; Sun,  5 Oct 2008 00:05:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3DF51DB803C
	for <linux-mm@kvack.org>; Sun,  5 Oct 2008 00:05:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66DED1DB8037
	for <linux-mm@kvack.org>; Sun,  5 Oct 2008 00:05:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
In-Reply-To: <20081003153810.5dd0a33e@bree.surriel.com>
References: <20081002124748.638c95ff.akpm@linux-foundation.org> <20081003153810.5dd0a33e@bree.surriel.com>
Message-Id: <20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  5 Oct 2008 00:05:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi

> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 02 Oct 2008 15:05:04 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > Let's get this ball rolling...
> > 
> > I don't think we're really able to get any MM balls rolling until we
> > get all the split-LRU stuff landed.  Is anyone testing it?  Is it good?
> 
> I've done some testing on it on my two test systems and have not
> found performance regressions against the mainline VM.
> 
> As for stability, I think we have done enough testing to conclude
> that it is stable by now.

Also my experience doesn't found any regression.
and in my experience, split-lru patch increase performance stability.

What is performance stability?
example, HPC parallel compution use many process and communication
each other.
Then, the system performance is decided by most slow process.

So, peek and average performance isn't only important, but also
worst case performance is important.

Especially, split-lru outperform mainline in anon and file mixed workload.


example, I ran himeno benchmark.
(this is one of most famous hpc benchmark in japan, this benchmark
 do matrix calculation on large memory (= use anon only))

machine
-------------
CPU IA64 x8
MEM 8G

benchmark setting
----------------
# of parallel: 4
use mem:  1.7G x4 (used nealy total mem)


first:
result of when other process stoped  (Unit: MFLOPS)
               
              each process
              result
               1    2    3    4    worst average
---------------------------------------------------------
2.6.27-rc8:   217  213  217  154   154   200
mmotm 02 Oct: 217  214  217  217   214   216

ok, these are the almost same


next:
result of when another io process running (Unit: MFLOPS)
(*) infinite loop of dd command used

               each process
               result
               1    2    3    4    worst  average
---------------------------------------------------------
2.6.27-rc8:    34  205   69  196    34     126
mmotm 02 Oct: 162  179  146  178   146     166


Wow, worst case is significant difference.
(this result is reprodusable)

because reclaim processing of mainline VM is too slow.
then, the process of calling direct reclaim is decreased performance largely.


this characteristics is not useful for hpc, but also useful for desktop.
because if X server (or another critical process) call direct reclaim, 
it can strike end-user-experience easily.


yup,
I know many people want to other benchmark result too.
I'll try to mesure other bench at next week.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
