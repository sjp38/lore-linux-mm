Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9AA06B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:42:25 -0400 (EDT)
Message-Id: <1285677740.30176.1397281937@webmail.messagingengine.com>
From: "Bron Gondwana" <brong@fastmail.fm>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <alpine.DEB.2.00.1009280727370.4144@router.home>
References: <52C8765522A740A4A5C027E8FDFFDFE3@jem>
 <20100921090407.GA11439@csn.ul.ie>
 <20100927110049.6B31.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1009270828510.7000@router.home>
 <1285629420.10278.1397188599@webmail.messagingengine.com>
 <alpine.DEB.2.00.1009280727370.4144@router.home>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad
 forfile/email/web servers
Date: Tue, 28 Sep 2010 22:42:20 +1000
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, Robert Mueller <robm@fastmail.fm>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010 07:35 -0500, "Christoph Lameter" <cl@linux.com> wrote:
> > The problem we saw was purely with file caching. The application wasn't
> > actually allocating much memory itself, but it was reading lots of files
> > from disk (via mmap'ed memory mostly), and as most people would, we
> > expected that data would be cached in memory to reduce future reads from
> > disk. That was not happening.
> 
> Obviously and you have stated that numerous times. Problem that the use
> of
> a remote memory will reduced performance of reads so the OS (with
> zone_reclaim=1) defaults to the use of local memory and favors reclaim of
> local memory over the allocation from the remote node. This is fine if
> you have multiple applications running on both nodes because then each
> application will get memory local to it and therefore run faster. That
> does not work with a single app that only allocates from one node.

Is this what's happening, or is IO actually coming from disk in preference
to the remote node?  I can certainly see the logic behind preferring to
reclaim the local node if that's all that's happening - though the OS should
be allocating the different tasks more evenly across the nodes in that case.

> Control over memory allocations over the various nodes under NUMA
> for a process can occur via the numactl ctl or the libnuma C apis.
> 
> F.e.e
> 
> numactl --interleave ... command
> 
> will address that issue for a specific command that needs to go

Gosh what a pain.  While it won't kill us too much to add to our
startup, it does feel a lot like the tail is wagging the dog from here
still.  A task that doesn't ask for anything special should get sane
defaults, and the cost of data from the other node should be a lot
less than the cost of the same data from spinning rust.

Bron.
-- 
  Bron Gondwana
  brong@fastmail.fm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
