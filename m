Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A4FB96B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 22:59:43 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so8421516pdj.36
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:59:43 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id yg10si21145920pbc.92.2014.02.11.19.59.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 19:59:42 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so8621580pab.4
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:59:42 -0800 (PST)
Date: Tue, 11 Feb 2014 19:59:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
In-Reply-To: <20140211103624.7edf1423@redhat.com>
Message-ID: <alpine.DEB.2.02.1402111951490.31912@chino.kir.corp.google.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com> <20140211103624.7edf1423@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Tue, 11 Feb 2014, Luiz Capitulino wrote:

> > > HugeTLB command-line option hugepages= allows the user to specify how many
> > > huge pages should be allocated at boot. On NUMA systems, this argument
> > > automatically distributes huge pages allocation among nodes, which can
> > > be undesirable.
> > > 
> > 
> > And when hugepages can no longer be allocated on a node because it is too 
> > small, the remaining hugepages are distributed over nodes with memory 
> > available, correct?
> 
> No. hugepagesnid= tries to obey what was specified by the uses as much as
> possible.

I'm referring to what I quoted above, the hugepages= parameter.  I'm 
saying that using existing functionality you can reserve an excess of 
hugepages and then free unneeded hugepages at runtime to get the desired 
amount allocated only on a specific node.

> > Strange, it would seem better to just reserve as many hugepages as you 
> > want so that you get the desired number on each node and then free the 
> > ones you don't need at runtime.
> 
> You mean, for example, if I have a 2 node system and want 2 1G huge pages
> from node 1, then I have to allocate 4 1G huge pages and then free 2 pages
> on node 0 after boot? That seems very cumbersome to me. Besides, what if
> node0 needs this memory during boot?
> 

All of this functionality, including the current hugepages= reservation at 
boot, needs to show that it can't be done as late as when you could run an 
initscript to do the reservation at runtime and fragmentation is at its 
lowest level when userspace first becomes available.

I don't see any justification given in the patchset that suggests you 
can't simply do this in an initscript if it is possible to allocate 1GB 
pages at runtime.  If it's too late because of oom, then your userspace is 
going to oom anyway if you reserve the hugepages at boot; if it's too late 
because of fragmentation, let's work on that issue (and justification why 
things like movablecore= don't work for you).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
