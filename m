Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 208E08D0039
	for <linux-mm@kvack.org>; Sun, 30 Jan 2011 19:04:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C44923EE0C2
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A53EE45DE4F
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BCF645DE50
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F02EEF8004
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A1B01DB803A
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:56 +0900 (JST)
Date: Mon, 31 Jan 2011 08:58:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
Message-Id: <20110131085853.b09aef2d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1101280917570.1194@router.home>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
	<AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
	<20110128064851.GB5054@balbir.in.ibm.com>
	<AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
	<20110128165605.3cbe5208.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1101280917570.1194@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 09:20:02 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 28 Jan 2011, KAMEZAWA Hiroyuki wrote:
> 
> > > > I see it as a tradeoff of when to check? add_to_page_cache or when we
> > > > are want more free memory (due to allocation). It is OK to wakeup
> > > > kswapd while allocating memory, somehow for this purpose (global page
> > > > cache), add_to_page_cache or add_to_page_cache_locked does not seem
> > > > the right place to hook into. I'd be open to comments/suggestions
> > > > though from others as well.
> >
> > I don't like add hook here.
> > AND I don't want to run kswapd because 'kswapd' has been a sign as
> > there are memory shortage. (reusing code is ok.)
> >
> > How about adding new daemon ? Recently, khugepaged, ksmd works for
> > managing memory. Adding one more daemon for special purpose is not
> > very bad, I think. Then, you can do
> >  - wake up without hook
> >  - throttle its work.
> >  - balance the whole system rather than zone.
> >    I think per-node balance is enough...
> 
> 
> I think we already have enough kernel daemons floating around. They are
> multiplying in an amazing way. What would be useful is to map all
> the memory management background stuff into a process. May call this memd
> instead? Perhaps we can fold khugepaged into kswapd as well etc.
> 

Making kswapd slow for whis "additional", "requested by user, not by system"
work is good thing ? I think workqueue works enough well, it's scale based on
workloads, if using thread is bad.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
