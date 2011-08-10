Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8292B6B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 02:11:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 028E93EE0BD
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 15:11:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D949D45DE5F
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 15:11:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B420345DE55
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 15:11:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A4CBF1DB8043
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 15:11:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 674A91DB8056
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 15:11:17 +0900 (JST)
Date: Wed, 10 Aug 2011 15:03:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 0/6]  memg: better numa scanning
Message-Id: <20110810150358.89290de4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110810091544.d73c7775.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809143314.GJ7463@tiehlicka.suse.cz>
	<20110810091544.d73c7775.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 10 Aug 2011 09:15:44 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 9 Aug 2011 16:33:14 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hmm, 57% reduction of major page faults which doesn't fit with other
> > numbers. At least I do not see any corelation with them. Your workload
> > has freed more or less the same number of file pages (>1% less). Do you
> > have a theory for that?
> > 
> > Is it possible that this is caused by "memcg: stop vmscan when enough
> > done."?
> > 
> 

I did more runs. In this time, I did 3 sequence of runs per test. Then, 2nd, 3rd
runs will see some garbage(file cache) of previous runs. cpuset is not used.

[Nopatch]
[1] 772.07user 308.73system 4:05.41elapsed 440%CPU (0avgtext+0avgdata 1458400maxresident)k
    4519512inputs+7485704outputs (8078major+35671016minor)pagefaults 0swaps
[2] 774.19user 306.19system 4:03.05elapsed 444%CPU (0avgtext+0avgdata 1455472maxresident)k
    4502272inputs+5168832outputs (7815major+35691489minor)pagefaults 0swaps
[3] 773.99user 310.71system 4:00.31elapsed 451%CPU (0avgtext+0avgdata 1458144maxresident)k
    4518448inputs+8695352outputs (7768major+35683064minor)pagefaults 0swaps

[Patch 1-3 applied]
[1] 771.75user 312.82system 4:09.55elapsed 434%CPU (0avgtext+0avgdata 1458320maxresident)k
    4413032inputs+7895152outputs (8793major+35691822minor)pagefaults 0swaps
[2] 772.66user 308.93system 4:15.22elapsed 423%CPU (0avgtext+0avgdata 1457504maxresident)k
    4469120inputs+12484960outputs (10952major+35702053minor)pagefaults 0swaps
[3] 771.83user 305.53system 3:57.63elapsed 453%CPU (0avgtext+0avgdata 1457856maxresident)k
    4355392inputs+5169560outputs (6985major+35680863minor)pagefaults 0swaps

[Full Patched]
[1] 771.19user 303.37system 3:49.47elapsed 468%CPU (0avgtext+0avgdata 1458400maxresident)k
    4260032inputs+4919824outputs (5496major+35672873minor)pagefaults 0swaps
[2] 772.51user 305.90system 3:56.89elapsed 455%CPU (0avgtext+0avgdata 1458416maxresident)k
    4463728inputs+4621496outputs (6301major+35671610minor)pagefaults 0swaps
[3] 773.14user 305.02system 3:55.09elapsed 458%CPU (0avgtext+0avgdata 1458240maxresident)k
    4447088inputs+5190792outputs (5106major+35699087minor)pagefaults 0swaps

The patch 3 is require for patch 5 to work correctly (It makes node-selection unused.)
But it seems to be not more than that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
