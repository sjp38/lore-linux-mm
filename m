Message-ID: <3B728C20.99A41239@dirksteinberg.de>
Date: Thu, 09 Aug 2001 14:12:00 +0100
From: "Dirk W. Steinberg" <dws@dirksteinberg.de>
MIME-Version: 1.0
Subject: Re: Swapping for diskless nodes
References: <no.id> <E15Ulnx-0006zZ-00@the-village.bc.nu> <20010809125033.E1200@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

I'd like to second that example where you have weak diskless nodes and
a big server with a lot of memory. The important point here is that the
remote paging does not need to really write to the remote disk, especially
not synchronously. The page could eventually be migrated to the remote
disk asynchronously, or maybe not at all if there is no memory pressure
at the remote system.

In such a scenario I would disagree with Alan that network paging is 
high latency as compared to disk access. I have a fully switched 100 Mpbs
full-duplex ethernet network, and sending a page across the net into
the memory of a fast server could have much less latency that writing 
that page out to a local old, slow IDE disk. Clusters could even have
special high-bandwidth, low latency networks that could be used for
remote paging.

In a perfect world, all nodes in a cluster would be able to dynamically 
share a pool of "cluster swap" space, so any locally available swap that
is not used could be utilized by other nodes in the cluster.

/ Dirk

Ingo Oeser wrote:
> On Thu, Aug 09, 2001 at 10:08:37AM +0100, Alan Cox wrote:
> > > what is the best/recommended way to do remote swapping via the network
> > > for diskless workstations or compute nodes in clusters in Linux 2.4?=20
> > > Last time i checked was linux 2.2, and there were some races related=20
> > > to network swapping back then. Has this been fixed for 2.4?
> >
> > The best answer probably is "don't". Networks are high latency things for
> > paging and paging is latency sensitive. If performance is not an issue then
> > the nbd driver ought to work. You may need to check it uses the right
> > GFP_ levels to avoid deadlocks and you might need to up the amount of atomic
> > pool memory. Hopefully other hacks arent needed
> 
> While we are on it: I have an old machine with 64MB of RAM and a
> new, fast machine with 1GB of RAM.
> 
> Sometimes I need more RAM on the old one and asked myself,
> whether I could first swap over network to the other one, into
> its tmpfs, before digging into real swap on a hard disk.
> 
> I have only three machines attached to this small internal
> 100Mbit LAN.
> 
> Both machines use Kernel 2.4.x.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
