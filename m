Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D63976B004D
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 21:48:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAR2m9ap028652
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Nov 2009 11:48:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D92445DE7F
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 11:48:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4898645DE4D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 11:48:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A941E1800C
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 11:48:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7A1BE18007
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 11:48:07 +0900 (JST)
Date: Fri, 27 Nov 2009 11:45:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC v0 2/3] res_counter: implement thresholds
Message-Id: <20091127114511.bbb43d5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091127092035.bbf2efdc.nishimura@mxp.nes.nec.co.jp>
References: <cover.1259255307.git.kirill@shutemov.name>
	<bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259255307.git.kirill@shutemov.name>
	<8524ba285f6dd59cda939c28da523f344cdab3da.1259255307.git.kirill@shutemov.name>
	<20091127092035.bbf2efdc.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Nov 2009 09:20:35 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> >  
> > @@ -73,6 +76,7 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> >  		val = counter->usage;
> >  
> >  	counter->usage -= val;
> > +	res_counter_threshold_notify_locked(counter);
> >  }
> >  
> hmm.. this adds new checks to hot-path of process life cycle.
> 
> Do you have any number on performance impact of these patches(w/o setting any threshold)?
> IMHO, it might be small enough to be ignored because KAMEZAWA-san's coalesce charge/uncharge
> patches have decreased charge/uncharge for res_counter itself, but I want to know just to make sure.
> 
Another concern is to support root cgroup, you need another notifier hook in
memcg because root cgroup doesn't use res_counter now.

Can't this be implemented in a way like softlimit check ? 
Filter by the number of event will be good for notifier behavior, for avoiding
too much wake up, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
