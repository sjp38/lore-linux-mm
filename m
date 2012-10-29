Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id EDBD76B0072
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:41:06 -0400 (EDT)
Date: Mon, 29 Oct 2012 11:41:04 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable implementation
Message-ID: <20121029154104.GA18542@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-9-git-send-email-levinsasha928@gmail.com> <20121029124229.GC11733@Krystal> <CA+55aFzO8DJJP3HBfgqXFac9r3=bYK+_nYe4cuXiNFg-623s6w@mail.gmail.com> <20121029151343.GA17722@Krystal> <20121029151653.GC9502@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029151653.GC9502@fieldses.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <levinsasha928@gmail.com>, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* J. Bruce Fields (bfields@fieldses.org) wrote:
> On Mon, Oct 29, 2012 at 11:13:43AM -0400, Mathieu Desnoyers wrote:
> > * Linus Torvalds (torvalds@linux-foundation.org) wrote:
> > > On Mon, Oct 29, 2012 at 5:42 AM, Mathieu Desnoyers
> > > <mathieu.desnoyers@efficios.com> wrote:
> > > >
> > > > So defining e.g.:
> > > >
> > > > #include <linux/log2.h>
> > > >
> > > > #define DFR_HASH_BITS  (PAGE_SHIFT - ilog2(BITS_PER_LONG))
> > > >
> > > > would keep the intended behavior in all cases: use one page for the hash
> > > > array.
> > > 
> > > Well, since that wasn't true before either because of the long-time
> > > bug you point out, clearly the page size isn't all that important. I
> > > think it's more important to have small and simple code, and "9" is
> > > certainly that, compared to playing ilog2 games with not-so-obvious
> > > things.
> > > 
> > > Because there's no reason to believe that '9' is in any way a worse
> > > random number than something page-shift-related, is there? And getting
> > > away from *previous* overly-complicated size calculations that had
> > > been broken because they were too complicated and random, sounds like
> > > a good idea.
> > 
> > Good point. I agree that unless we really care about the precise number
> > of TLB entries and cache lines used by this hash table, we might want to
> > stay away from page-size and pointer-size based calculation.
> >
> > It might not hurt to explain this in the patch changelog though.
> 
> I'd also be happy to take that as a separate patch now.

FYIW: I've made a nice boo-boo above. It should have been:

#define DFR_HASH_BITS   (PAGE_SHIFT - ilog2(sizeof(struct hlist_head)))

Because we happen to have a memory indexed in bytes, not in bits. I
guess this goes a long way proving Linus' point about virtues of trivial
code. ;-)

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
