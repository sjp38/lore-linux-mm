Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E66E86B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 04:19:58 -0500 (EST)
Date: Tue, 10 Nov 2009 10:19:53 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu
	counter instead
Message-ID: <20091110091953.GA2373@basil.fritz.box>
References: <20091106174439.GB819@basil.fritz.box> <alpine.DEB.1.10.0911061249170.5187@V090114053VZO-1> <20091110151145.3615.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091110151145.3615.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 10, 2009 at 03:21:11PM +0900, KOSAKI Motohiro wrote:
> > On Fri, 6 Nov 2009, Andi Kleen wrote:
> > 
> > > On Fri, Nov 06, 2009 at 12:08:54PM -0500, Christoph Lameter wrote:
> > > > On Fri, 6 Nov 2009, Andi Kleen wrote:
> > > >
> > > > > Yes but all the major calls still take mmap_sem, which is not ranged.
> > > >
> > > > But exactly that issue is addressed by this patch!
> > >
> > > Major calls = mmap, brk, etc.
> > 
> > Those are rare. More frequently are for faults, get_user_pages and
> > the like operations that are frequent.
> > 
> > brk depends on process wide settings and has to be
> > serialized using a processor wide locks.
> > 
> > mmap and other address space local modification may be able to avoid
> > taking mmap write lock by taking the read lock and then locking the
> > ptls in the page struct relevant to the address space being modified.
> > 
> > This is also enabled by this patchset.
> 
> Andi, Why do you ignore fork? fork() hold mmap_sem write-side lock and
> it is one of critical path.

I have not seen profile logs where fork was critical. But that's not saying
that it can't be.  But fork is so intrusive that locking it fine grained
is probably very hard.

> Plus, most critical mmap_sem issue is not locking cost itself. In stree workload,
> the procss grabbing mmap_sem frequently sleep. and fair rw-semaphoe logic
> frequently prevent reader side locking.
> At least, this improvement doesn't help google like workload.

Not helping is not too bad, the problem I had was just that it makes
writers even slower. 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
