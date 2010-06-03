Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C6ED46B01D5
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:29:08 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o536T5wf027080
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:29:06 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by hpaq3.eem.corp.google.com with ESMTP id o536T3ga030953
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:29:04 -0700
Received: by pzk6 with SMTP id 6so1533556pzk.1
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:29:03 -0700 (PDT)
Date: Wed, 2 Jun 2010 23:29:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: remove PF_EXITING check completely
In-Reply-To: <20100603120814.7242.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006022326190.22441@chino.kir.corp.google.com>
References: <20100602155455.GB9622@redhat.com> <alpine.DEB.2.00.1006021359430.32666@chino.kir.corp.google.com> <20100603120814.7242.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, KOSAKI Motohiro wrote:

> > On Wed, 2 Jun 2010, Oleg Nesterov wrote:
> > 
> > > > Today, I've thought to make some bandaid patches for this issue. but
> > > > yes, I've reached the same conclusion.
> > > >
> > > > If we think multithread and core dump situation, all fixes are just
> > > > bandaid. We can't remove deadlock chance completely.
> > > >
> > > > The deadlock is certenaly worst result, then, minor PF_EXITING optimization
> > > > doesn't have so much worth.
> > > 
> > > Agreed! I was always wondering if it really helps in practice.
> > > 
> > 
> > Nack, this certainly does help in practice, it prevents needlessly killing 
> > additional tasks when one is exiting and may free memory.  It's much 
> > better to defer killing something temporarily if an eligible task (i.e. 
> > one that has a high probability of memory allocations on current's nodes 
> > or contributing to its memcg) is exiting.
> > 
> > We depend on this check specifically for our use of cpusets, so please 
> > don't remove it.
> 
> Your claim violate our development process. Oleg pointed this check
> doesn't only work well, but also can makes deadlock. So, We certinally
> need anything fix. then, I'll remove this check completely at 2.6.35
> timeframe.
> 

Show me your deadlock.  I want to see it.  In practice.

We've been using this check specifically for three years and it prevents 
needlessly killing additional tasks when one is already exiting and will 
free its memory.  That's a crucial aspect of using cpusets that run out of 
memory constantly.

Unless you actually have real world experience with using the oom killer 
to affect a memory containment strategy, I don't buy into your overly 
exaggerated claims that these are all bugfixes and these races that you 
have no practical evidence to support actually even matter but speculate 
based on pure code inspection are important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
