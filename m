Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 16F046B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:02:35 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o52L2VAF030399
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:02:32 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by wpaz29.hot.corp.google.com with ESMTP id o52L2UrL018010
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:02:30 -0700
Received: by pvg16 with SMTP id 16so475070pvg.5
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:02:29 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:02:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: remove PF_EXITING check completely
In-Reply-To: <20100602155455.GB9622@redhat.com>
Message-ID: <alpine.DEB.2.00.1006021359430.32666@chino.kir.corp.google.com>
References: <20100601093951.2430.A69D9226@jp.fujitsu.com> <20100601201843.GA20732@redhat.com> <20100602200732.F518.A69D9226@jp.fujitsu.com> <20100602155455.GB9622@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, Oleg Nesterov wrote:

> > Today, I've thought to make some bandaid patches for this issue. but
> > yes, I've reached the same conclusion.
> >
> > If we think multithread and core dump situation, all fixes are just
> > bandaid. We can't remove deadlock chance completely.
> >
> > The deadlock is certenaly worst result, then, minor PF_EXITING optimization
> > doesn't have so much worth.
> 
> Agreed! I was always wondering if it really helps in practice.
> 

Nack, this certainly does help in practice, it prevents needlessly killing 
additional tasks when one is exiting and may free memory.  It's much 
better to defer killing something temporarily if an eligible task (i.e. 
one that has a high probability of memory allocations on current's nodes 
or contributing to its memcg) is exiting.

We depend on this check specifically for our use of cpusets, so please 
don't remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
