Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A0EE66B007E
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 19:13:24 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F0DLTY008859
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Feb 2010 09:13:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DA2EE45DE52
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:13:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF38945DE50
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:13:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 83FB8E08007
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:13:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C76BE08003
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:13:20 +0900 (JST)
Date: Mon, 15 Feb 2010 09:09:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 6/7 -mm] oom: avoid oom killer for lowmem allocations
Message-Id: <20100215090949.169f2819.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002120200050.22883@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com>
	<20100212102841.fa148baf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002120200050.22883@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 02:06:49 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Fri, 12 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > From viewpoint of panic-on-oom lover, this patch seems to cause regression.
> > please do this check after sysctl_panic_on_oom == 2 test.
> > I think it's easy. So, temporary Nack to this patch itself.
> > 
> > 
> > And I think calling notifier is not very bad in the situation.
> > ==
> > void out_of_memory()
> >  ..snip..
> >   blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> > 
> > 
> > So,
> > 
> >         if (sysctl_panic_on_oom == 2) {
> >                 dump_header(NULL, gfp_mask, order, NULL);
> >                 panic("out of memory. Compulsory panic_on_oom is selected.\n");
> >         }
> > 
> > 	if (gfp_zone(gfp_mask) < ZONE_NORMAL) /* oom-kill is useless if lowmem is exhausted. */
> > 		return;
> > 
> > is better. I think.
> > 
> 
> I can't agree with that assessment, I don't think it's a desired result to 
> ever panic the machine regardless of what /proc/sys/vm/panic_on_oom is set 
> to because a lowmem page allocation fails especially considering, as 
> mentioned in the changelog, these allocations are never __GFP_NOFAIL and 
> returning NULL is acceptable.
> 
please add
  WARN_ON((high_zoneidx < ZONE_NORMAL) && (gfp_mask & __GFP_NOFAIL))
somewhere. Then, it seems your patch makes sense.

I don't like the "possibility" of inifinte loops.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
