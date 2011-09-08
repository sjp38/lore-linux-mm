Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 52E9D900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 05:19:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1CAB13EE0AE
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:19:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 02A6F45DE5A
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:19:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DEAC645DE56
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:19:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE08D1DB8032
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:19:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98E6C1DB804A
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:19:43 +0900 (JST)
Date: Thu, 8 Sep 2011 18:19:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: memcg: close race between charge and putback
Message-Id: <20110908181901.1d488d73.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110908085404.GA1316@redhat.com>
References: <1315467622-9520-1-git-send-email-jweiner@redhat.com>
	<20110908173042.4a6f8ac0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110908085404.GA1316@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Sep 2011 10:54:04 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Thu, Sep 08, 2011 at 05:30:42PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu,  8 Sep 2011 09:40:22 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> > 
> > > There is a potential race between a thread charging a page and another
> > > thread putting it back to the LRU list:
> > > 
> > > charge:                         putback:
> > > SetPageCgroupUsed               SetPageLRU
> > > PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU
> > > 
> > 
> > I assumed that all pages are charged before added to LRU.
> > (i.e. event happens in charge->lru_lock->putback order.)
> > 
> > But hmm, this assumption may be bad for maintainance.
> > Do you find a code which adds pages to LRU before charge ?
> > 
> > Hmm, if there are codes which recharge the page to other memcg,
> > it will cause bug and my assumption may be harmful.
> 
> Swap slots are read optimistically into swapcache and put to the LRU,
> then charged upon fault.  

Yes, then swap charge removes page from LRU before charge.
IIUC, it needed to do so because page->mem_cgroup may be replaced.

> Fuse apparently recharges uncharged LRU pages.
Yes and No. IIUC, it was like page migraion and remove old page 
and add new page to radix-tree.

> That's why we have the lrucare stuff in the first place, no?
You're right.

> Or did I misunderstand your question?
> 

I just wondered whether you find a new one or possible user.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
