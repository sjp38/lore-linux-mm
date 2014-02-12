Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 59BF06B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 15:23:35 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so16246028qcx.16
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 12:23:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y3si6459516qas.12.2014.02.12.12.23.33
        for <linux-mm@kvack.org>;
        Wed, 12 Feb 2014 12:23:34 -0800 (PST)
Date: Wed, 12 Feb 2014 15:09:12 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140212150912.14ef65be@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1402111951490.31912@chino.kir.corp.google.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
 <20140211103624.7edf1423@redhat.com>
 <alpine.DEB.2.02.1402111951490.31912@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Tue, 11 Feb 2014 19:59:40 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 11 Feb 2014, Luiz Capitulino wrote:
> 
> > > > HugeTLB command-line option hugepages= allows the user to specify how many
> > > > huge pages should be allocated at boot. On NUMA systems, this argument
> > > > automatically distributes huge pages allocation among nodes, which can
> > > > be undesirable.
> > > > 
> > > 
> > > And when hugepages can no longer be allocated on a node because it is too 
> > > small, the remaining hugepages are distributed over nodes with memory 
> > > available, correct?
> > 
> > No. hugepagesnid= tries to obey what was specified by the uses as much as
> > possible.
> 
> I'm referring to what I quoted above, the hugepages= parameter. 

Oh, OK.

> I'm 
> saying that using existing functionality you can reserve an excess of 
> hugepages and then free unneeded hugepages at runtime to get the desired 
> amount allocated only on a specific node.

I got that part. I only think this is not a good solution as I explained
bellow.

> > > Strange, it would seem better to just reserve as many hugepages as you 
> > > want so that you get the desired number on each node and then free the 
> > > ones you don't need at runtime.
> > 
> > You mean, for example, if I have a 2 node system and want 2 1G huge pages
> > from node 1, then I have to allocate 4 1G huge pages and then free 2 pages
> > on node 0 after boot? That seems very cumbersome to me. Besides, what if
> > node0 needs this memory during boot?
> > 
> 
> All of this functionality, including the current hugepages= reservation at 
> boot, needs to show that it can't be done as late as when you could run an 
> initscript to do the reservation at runtime and fragmentation is at its 
> lowest level when userspace first becomes available.

It's not that it can't. The point is that for 1G huge pages it's more
reliable to allocate them as early as possible during the kernel boot
process. I'm all for having/improving 1G allocation support at run-time,
and volunteer to help with that effort, but that's something that can
(and IMO should) be done on top of this series.

> I don't see any justification given in the patchset that suggests you 
> can't simply do this in an initscript if it is possible to allocate 1GB 
> pages at runtime.  If it's too late because of oom, then your userspace is 
> going to oom anyway if you reserve the hugepages at boot; if it's too late 
> because of fragmentation, let's work on that issue (and justification why 
> things like movablecore= don't work for you).
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
