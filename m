Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9206B0172
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 20:19:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 04C5F3EE0C0
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:19:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D589145DE86
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:19:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCFF645DE85
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:19:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD2AC1DB803A
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:19:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 763F11DB803E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:19:53 +0900 (JST)
Date: Thu, 8 Sep 2011 09:19:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: drain all stocks for the cgroup before read
 usage
Message-Id: <20110908091914.6daeab1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110907213340.GA7690@shutemov.name>
References: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
	<20110905085913.8f84278e.kamezawa.hiroyu@jp.fujitsu.com>
	<20110905101607.cd946a46.nishimura@mxp.nes.nec.co.jp>
	<20110907213340.GA7690@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Sep 2011 00:33:40 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Sep 05, 2011 at 10:16:07AM +0900, Daisuke Nishimura wrote:
> > On Mon, 5 Sep 2011 08:59:13 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Sun,  4 Sep 2011 04:15:33 +0300
> > > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > > 
> > > > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> > > > 
> > > > Currently, mem_cgroup_usage() for non-root cgroup returns usage
> > > > including stocks.
> > > > 
> > > > Let's drain all socks before read resource counter value. It makes
> > > > memory{,.memcg}.usage_in_bytes and memory.stat consistent.
> > > > 
> > > > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > > 
> > > Hmm. This seems costly to me. 
> > > 
> > > If a user chesk usage_in_bytes in a memcg once per 1sec, 
> > > the kernel will call schedule_work on cpus once per 1sec.
> > > So, IMHO, I don't like this.
> > > 
> > I agree.
> > 
> > We discussed a similar topic on the thread https://lkml.org/lkml/2011/3/18/212.
> > And, we added the memory.txt:
> > ---
> > 5.5 usage_in_bytes
> > 
> > For efficiency, as other kernel components, memory cgroup uses some optimization
> > to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
> > method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
> > value for efficient access. (Of course, when necessary, it's synchronized.)
> > If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
> > value in memory.stat(see 5.2).
> > ---
> 
> Agree, thanks.
> 
> Should we have field 'ram' (or 'memory') for rss+cache in memory.stat?
> 

Why do you think so ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
