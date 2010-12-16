Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 923036B0095
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:15:53 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBGEx5qY029187
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 09:59:06 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5FAFA4DE8056
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:13:41 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBGFFnAT264482
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:15:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBGFFTLM018317
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:15:49 -0500
Date: Thu, 16 Dec 2010 07:11:22 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: linux-next early user mode crash (Was: Re: Transparent
 Hugepage Support #33)
Message-ID: <20101216151122.GA2203@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20101215051540.GP5638@random.random>
 <20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
 <20101215171809.0e0bc3d5.akpm@linux-foundation.org>
 <20101216130251.12dbe8d8.sfr@canb.auug.org.au>
 <20101216052958.GA2161@linux.vnet.ibm.com>
 <20101216170814.6a874692.sfr@canb.auug.org.au>
 <20101216180047.4bb69b80.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101216180047.4bb69b80.sfr@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 06:00:47PM +1100, Stephen Rothwell wrote:
> Hi Paul,
> 
> On Thu, 16 Dec 2010 17:08:14 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > On Wed, 15 Dec 2010 21:29:58 -0800 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > >
> > > RCU problems would normally take longer to run the system out of memory,
> > > but who knows?
> > > 
> > > I did a push into -rcu in the suspect time frame, so have pulled it.  I am
> > > sure that kernel.org will push this change to its mirrors at some point.
> > > Just in case tree-by-tree bisecting is faster than commit-by-commit
> > > bisecting.
> > 
> > I have bisected it down to the rcu tree, so the three commits that were
> > added yesterday are the suspects.  I am still bisecting.  If will just
> > revert those three commits from linux-next today in the hope that Andrew
> > will end up with a working tree.
> 
> Bisect finished:
> 
> 4e40200dab0e673b019979b5b8f5e5d1b25885c2 is first bad commit
> commit 4e40200dab0e673b019979b5b8f5e5d1b25885c2
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Fri Dec 10 15:02:47 2010 -0800
> 
>     rcu: fine-tune grace-period begin/end checks
>     
>     Use the CPU's bit in rnp->qsmask to determine whether or not the CPU
>     should try to report a quiescent state.  Handle overflow in the check
>     for rdp->gpnum having fallen behind.
>     
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> So far 4 of my 6 boot tests that failed yesterday have succeeded today
> (with those last three rcu commits reverted) - the others are still
> building.

So I blew it not once,  but twice -- once in the patch itself, and once
in messing up my -next process.  :-/

Please accept my apologies!!!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
