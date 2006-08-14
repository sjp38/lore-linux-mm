Date: Sun, 13 Aug 2006 22:22:08 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Message-Id: <20060813222208.7e8583ac.akpm@osdl.org>
In-Reply-To: <1155531835.5696.103.camel@twins>
References: <20060808211731.GR14627@postel.suug.ch>
	<44DBED4C.6040604@redhat.com>
	<44DFA225.1020508@google.com>
	<20060813.165540.56347790.davem@davemloft.net>
	<44DFD262.5060106@google.com>
	<20060813185309.928472f9.akpm@osdl.org>
	<1155530453.5696.98.camel@twins>
	<20060813215853.0ed0e973.akpm@osdl.org>
	<1155531835.5696.103.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Daniel Phillips <phillips@google.com>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Aug 2006 07:03:55 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Sun, 2006-08-13 at 21:58 -0700, Andrew Morton wrote:
> > On Mon, 14 Aug 2006 06:40:53 +0200
> > Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > Testcase:
> > > 
> > > Mount an NBD device as sole swap device and mmap > physical RAM, then
> > > loop through touching pages only once.
> > 
> > Fix: don't try to swap over the network.  Yes, there may be some scenarios
> > where people have no local storage, but it's reasonable to expect anyone
> > who is using Linux as an "enterprise storage platform" to stick a local
> > disk on the thing for swap.
> 
> I wish you were right, however there seems to be a large demand to go
> diskless and swap over iSCSI because disks seem to be the nr. 1 failing
> piece of hardware in systems these days.

We could track dirty anonymous memory and throttle.

Also, there must be some value of /proc/sys/vm/min_free_kbytes at which a
machine is no longer deadlockable with any of these tricks.  Do we know
what level that is?

> > That leaves MAP_SHARED, but mm-tracking-shared-dirty-pages.patch will fix
> > that, will it not?
> 
> Will makes it less likely. One can still have memory pressure, the
> remaining bits of memory can still get stuck in socket queues for
> blocked processes.

But there's lots of reclaimable pagecache around and kswapd will free it
up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
