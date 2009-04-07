Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FD025F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 20:18:07 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n370I9UB030911
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Apr 2009 09:18:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ACDF745DE53
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 09:18:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8714B45DE51
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 09:18:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D1361DB8037
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 09:18:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EB2F71DB8040
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 09:18:08 +0900 (JST)
Date: Tue, 7 Apr 2009 09:16:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/9] memcg soft limit v2 (new design)
Message-Id: <20090407091642.8a838f45.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090406090800.GH7082@balbir.in.ibm.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
	<20090406090800.GH7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Apr 2009 14:38:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-03 17:08:35]:
> 
> > Hi,
> > 
> > Memory cgroup's soft limit feature is a feature to tell global LRU 
> > "please reclaim from this memcg at memory shortage".
> > 
> > This is v2. Fixed some troubles under hierarchy. and increase soft limit
> > update hooks to proper places.
> > 
> > This patch is on to
> >   mmotom-Mar23 + memcg-cleanup-cache_charge.patch
> >   + vmscan-fix-it-to-take-care-of-nodemask.patch
> > 
> > So, not for wide use ;)
> > 
> > This patch tries to avoid to use existing memcg's reclaim routine and
> > just tell "Hints" to global LRU. This patch is briefly tested and shows
> > good result to me. (But may not to you. plz brame me.)
> > 
> > Major characteristic is.
> >  - memcg will be inserted to softlimit-queue at charge() if usage excess
> >    soft limit.
> >  - softlimit-queue is a queue with priority. priority is detemined by size
> >    of excessing usage.
> 
> This is critical and good that you have this now. In my patchset, it
> helps me achieve a lot of the expected functionality.
> 
> >  - memcg's soft limit hooks is called by shrink_xxx_list() to show hints.
> 
> I am not too happy with moving pages in global LRU based on soft
> limits based on my comments earlier. My objection is not too strong,
> since reclaiming from the memcg also exhibits functionally similar
> behaviour.
Yes, not so much difference from memcg' reclaim routine other than this is
called under scanning_global_lru()==ture.

> 
> >  - Behavior is affected by vm.swappiness and LRU scan rate is determined by
> >    global LRU's status.
> > 
> 
> I also have concerns about not sorting the list of memcg's. I need to
> write some scalabilityt tests and check.

Ah yes, I admit scalability is my concern, too. 

About sorting, this priority list uses exponet as parameter. Then,
  When excess is small, priority control is done under close observation.
  When excess is big, priority control is done under rough observation.

I'm wondering how ->ticket can be big, now.


> 
> > In this v2.
> >  - problems under use_hierarchy=1 case are fixed.
> >  - more hooks are added.
> >  - codes are cleaned up.
> > 
> > Shows good results on my private box test under several work loads.
> > 
> > But in special artificial case, when victim memcg's Active/Inactive ratio of
> > ANON is very different from global LRU, the result seems not very good.
> > i.e.
> >   under vicitm memcg, ACTIVE_ANON=100%, INACTIVE=0% (access memory in busy loop)
> >   under global, ACTIVE_ANON=10%, INACTIVE=90% (almost all processes are sleeping.)
> > memory can be swapped out from global LRU, not from vicitm.
> > (If there are file cache in victims, file cacahes will be out.)
> > 
> > But, in this case, even if we successfully swap out anon pages under victime memcg,
> > they will come back to memory soon and can show heavy slashing.
> 
> heavy slashing? Not sure I understand what you mean.
> 
Heavy swapin <-> swapout and user applicatons can't make progress.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
