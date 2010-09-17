Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5547A6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 10:09:21 -0400 (EDT)
Date: Sat, 18 Sep 2010 00:09:16 +1000
From: Bron Gondwana <brong@fastmail.fm>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
Message-ID: <20100917140916.GA8474@brong.net>
References: <1284349152.15254.1394658481@webmail.messagingengine.com>
 <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1009161153210.22849@router.home>
 <1284684653.10161.1395434085@webmail.messagingengine.com>
 <1284703264.3408.1.camel@sli10-conroe.sh.intel.com>
 <1284708756.2702.1395472601@webmail.messagingengine.com>
 <alpine.DEB.2.00.1009170851200.11900@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009170851200.11900@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Robert Mueller <robm@fastmail.fm>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 17, 2010 at 08:56:06AM -0500, Christoph Lameter wrote:
> On Fri, 17 Sep 2010, Robert Mueller wrote:
> 
> > > > I don't think this is any fault of how the software works. It's a
> > > > *very* standard "pre-fork child processes, allocate incoming
> > > > connections to a child process, open and mmap one or more files to
> > > > read data from them". That's not exactly a weird programming model,
> > > > and it's bad that the kernel is handling that case very badly with
> > > > everything default.
> > >
> > > maybe you incoming connection always happen on one CPU and you do the
> > > page allocation in that cpu, so some nodes use out of memory but
> > > others have a lot free. Try bind the child process to different nodes
> > > might help.
> >
> > There's are 5000+ child processes (it's a cyrus IMAP server). Neither
> > the parent of any of the children are bound to any particular CPU. It
> > uses a standard fcntl lock to make sure only one spare child at a time
> > calls accept(). I don't think that's the problem.
> 
> From the first look that seems to be the problem. You do not need to be
> bound to a particular cpu, the scheduler will just leave a single process
> on the same cpu by default. If you then allocate all memory only from this
> process then you get the scenario that you described.

Huh?  Which bit of forking server makes you think one process is allocating
lots of memory?  They're opening and reading from files.  Unless you're
calling the kernel a "single process".
 
> There should be multiple processes allocating memory from all processors
> to take full advantage of fast local memory. If you cannot do that then
> the only choice is to reduce performance by some sort of interleaving
> either at the Bios or OS level. OS level interleaving only for this
> particular application would be best because then the OS can at least
> allocate its own data in memory local to the processors.

In actual fact we're running 20 different Cyrus instances on this
machine, each with its own config file and own master file.  The only
"parentage" they share is they were most likely started from a single
bash shell at one point, because we start them up after the server is
already running from a management script.

So we're talking 20 Cyrus master processes, each of which forks off
hundreds of imapd processes, each of which listens, opens mailboxes
as required, reads and writes files.

You can't seriously tell me that the scheduler is putting ALL THESE
PROCESSES on a single CPU.

Bron.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
