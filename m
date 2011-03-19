Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59D9A8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 23:59:05 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p2J3wuEA022888
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 20:58:58 -0700
Received: from iyf40 (iyf40.prod.google.com [10.241.50.104])
	by hpaq6.eem.corp.google.com with ESMTP id p2J3woKf008614
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 20:58:55 -0700
Received: by iyf40 with SMTP id 40so7250220iyf.22
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 20:58:50 -0700 (PDT)
Date: Fri, 18 Mar 2011 20:58:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
In-Reply-To: <alpine.DEB.2.00.1103171006270.12540@router.home>
Message-ID: <alpine.LSU.2.00.1103182037340.18458@sister.anvils>
References: <4D6CA852.3060303@cn.fujitsu.com> <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com> <alpine.DEB.2.00.1103010909320.6253@router.home> <AANLkTim0Zjc7c9-7LCnEaYpV5PVN=5fNQpjMYqtZe-fk@mail.gmail.com> <alpine.DEB.2.00.1103020625290.10180@router.home>
 <AANLkTikk02f6kLiPFqqAGroJErQkHbJFfHzpHy4Y5P8Y@mail.gmail.com> <alpine.DEB.2.00.1103171006270.12540@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Thu, 17 Mar 2011, Christoph Lameter wrote:
> On Sun, 6 Mar 2011, Hugh Dickins wrote:
> 
> > >> That was so for a long time, but I stopped it just over a year ago
> > >> with commit a70caa8ba48f21f46d3b4e71b6b8d14080bbd57a, stop ptlock
> > >> enlarging struct page.
> > >
> > > Strange. I just played around with in in January and the page struct size
> > > changes when I build kernels with full debugging. I have some
> > > cmpxchg_double patches here that depend on certain alignment in the page
> > > struct. Debugging causes all that stuff to get out of whack so that I had
> > > to do some special patches to make sure fields following the spinlock are
> > > properly aligned when the sizes change.
> >
> > That puzzles me, it's not my experience and I don't have an
> > explanation: do you have time to investigate?
> >
> > Uh oh, you're going to tell me you're working on an out-of-tree
> > architecture with a million cpus ;)  In that case, yes, I'm afraid
> > I'll have to update the SPLIT_PTLOCK_CPUS defaulting (for a million -
> > 1 even).
> 
> No I am not working on any out of tree structure. Just regular dual socket
> server boxes with 24 processors (which is a normal business machine
> configuration these days).
> 
> But then there is also CONFIG_GENERIC_LOCKBREAK. That does not affect
> things?

CONFIG_GENERIC_LOCKBREAK adds an unsigned int break_lock after the
int-sized arch_spinlock_t: which would make no difference on 64-bit
anyway (the two ints fitting into one long), and makes no difference
on 32-bit because we have put
	struct {
		unsigned long private;
		struct address_space *mapping;
	};
into the union with spinlock_t ptl - the arch_spinlock_t then
overlays private and the break_lock overlays mapping.

I'd much rather have had simple elements in that union, but it's
precisely because of 32-bit CONFIG_GENERIC_LOCKBREAK that we need
that structure in there.

(It is important to the KSM assumption about page->mapping that
what goes into break_lock is either 0 or 1: in neither case could
page->mapping look like a kmem address + 3.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
