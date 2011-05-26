Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 49A5E6B0022
	for <linux-mm@kvack.org>; Thu, 26 May 2011 15:52:15 -0400 (EDT)
Date: Thu, 26 May 2011 12:52:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4] memcg: reclaim memory from node in round-robin
Message-Id: <20110526125207.e02e5775.akpm@linux-foundation.org>
In-Reply-To: <20110506151302.a7256987.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
	<20110428093513.5a6970c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110428103705.a284df87.nishimura@mxp.nes.nec.co.jp>
	<20110428104912.6f86b2ee.kamezawa.hiroyu@jp.fujitsu.com>
	<20110504142623.8aa3bddb.akpm@linux-foundation.org>
	<20110506151302.a7256987.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Fri, 6 May 2011 15:13:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > It would be much better to work out the optimum time at which to rotate
> > the index via some deterministic means.
> > 
> > If we can't think of a way of doing that then we should at least pace
> > the rotation frequency via something saner than wall-time.  Such as
> > number-of-pages-scanned.
> > 
> 
> 
> What I think now is using reclaim_stat or usigng some fairness based on
> the ratio of inactive file caches. We can calculate the total sum of
> recalaim_stat which gives us a scan_ratio for a whole memcg. And we can
> calculate LRU rotate/scan ratio per node. If rotate/scan ratio is small,
> it will be a good candidate of reclaim target. Hmm,
> 
>   - check which memory(anon or file) should be scanned.
>     (If file is too small, rotate/scan ratio of file is meaningless.)
>   - check rotate/scan ratio of each nodes.
>   - calculate weights for each nodes (by some logic ?)
>   - give a fair scan w.r.t node's weight.
> 
> Hmm, I'll have a study on this.

How's the study coming along ;)

I'll send this in to Linus today, but I'll feel grumpy while doing so. 
We really should do something smarter here - the magic constant will
basically always be suboptimal for everyone and we end up tweaking its
value (if we don't, then the feature just wasn't valuable in the first
place) and then we add a tunable and then people try to tweak the
default setting of the tunable and then I deride them for not setting
the tunable in initscripts and then we have to maintain the stupid
tunable after we've changed the internal implementation and it's all
basically screwed up.

How to we automatically determine the optimum time at which to rotate,
at runtime?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
