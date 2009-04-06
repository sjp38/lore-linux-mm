Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 300506B003D
	for <linux-mm@kvack.org>; Sun,  5 Apr 2009 23:56:47 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n363vcUj013604
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Apr 2009 12:57:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9372B45DE54
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:57:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 73A6D45DE4E
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:57:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 548AC1DB805F
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:57:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E0051DB8043
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 12:57:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: + mm-align-vmstat_works-timer.patch added to -mm tree
In-Reply-To: <20090406120533.450B.A69D9226@jp.fujitsu.com>
References: <200904011945.n31JjWqG028114@imap1.linux-foundation.org> <20090406120533.450B.A69D9226@jp.fujitsu.com>
Message-Id: <20090406125627.4514.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Apr 2009 12:57:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, anton@samba.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> (swich to lkml and linux-mm)
> 
> Hi Anton,
> 
> Do you have any mesurement data?
> 
> Honestly, I made the same patch few week ago.
> but I found two problems.
> 
> 1)
> work queue tracer (in -tip) reported it isn't proper rounded.

Ah, sorry ignore this sentence.
I used my local patch queue's feature for mesurement, not -tip.


> 
> The fact is, schedule_delayed_work(work, round_jiffies_relative()) is
> a bit ill.
> 
> it mean
>   - round_jiffies_relative() calculate rounded-time - jiffies
>   - schedule_delayed_work() calculate argument + jiffies
> 
> it assume no jiffies change at above two place. IOW it assume
> non preempt kernel.
> 
> 
> 2)
> > -	schedule_delayed_work_on(cpu, vmstat_work, HZ + cpu);
> > +	schedule_delayed_work_on(cpu, vmstat_work,
> > +				 __round_jiffies_relative(HZ, cpu));
> 
> isn't same meaning.
> 
> vmstat_work mean to move per-cpu stastics to global stastics.
> Then, (HZ + cpu) mean to avoid to touch the same global variable at the same time.
> 
> Oh well, this patch have performance regression risk on _very_ big server.
> (perhaps, only sgi?)
> 
> but I agree vmstat_work is one of most work queue heavy user.
> For power consumption view, it isn't proper behavior.
> 
> I still think improving another way.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
