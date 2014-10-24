Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3266B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:16:36 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so2496909ier.40
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 08:16:35 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id v102si6287378iov.103.2014.10.24.08.16.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 08:16:34 -0700 (PDT)
Date: Fri, 24 Oct 2014 10:16:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
In-Reply-To: <20141021080740.GJ23531@worktop.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.11.1410241003430.29419@gentwo.org>
References: <20141020215633.717315139@infradead.org> <20141020222841.419869904@infradead.org> <CA+55aFwd04q+O5ejbmDL-H7_GB6DEBMiiHkn+2R1u4uWxfDO9w@mail.gmail.com> <20141021080740.GJ23531@worktop.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Jiangshan <laijs@cn.fujitsu.com>, Davidlohr Bueso <dave@stgolabs.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 21 Oct 2014, Peter Zijlstra wrote:

> On Mon, Oct 20, 2014 at 04:41:45PM -0700, Linus Torvalds wrote:
> > On Mon, Oct 20, 2014 at 2:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > Manage the VMAs with SRCU such that we can do a lockless VMA lookup.
> >
> > Can you explain why srcu, and not plain regular rcu?
> >
> > Especially as you then *note* some of the problems srcu can have.
> > Making it regular rcu would also seem to make it possible to make the
> > seqlock be just a seqcount, no?
>
> Because we need to hold onto the RCU read side lock across the entire
> fault, which can involve IO and all kinds of other blocking ops.

Hmmm... One optimization to do before we get into these changes is to work
on allowing the dropping of mmap_sem before we get to sleeping and I/O and
then reevaluate when I/O etc is complete? This is probably the longest
hold on mmap_sem that is also frequent. Then it may be easier to use
standard RCU later.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
