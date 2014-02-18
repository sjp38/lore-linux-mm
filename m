Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0B86B0038
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:16:46 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so17304733pab.32
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:16:45 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id sd3si19646975pbb.342.2014.02.18.14.16.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:16:45 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so17304708pab.32
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:16:44 -0800 (PST)
Date: Tue, 18 Feb 2014 14:16:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140218123013.GA20609@amt.cnet>
Message-ID: <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com> <1392339728-13487-5-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com> <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com> <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Feb 2014, Marcelo Tosatti wrote:

> > Lacking from your entire patchset is a specific example of what you want 
> > to do.  So I think we're all guessing what exactly your usecase is and we 
> > aren't getting any help.  Are you really suggesting that a customer wants 
> > to allocate 4 1GB hugepages on node 0, 12 2MB hugepages on node 0, 6 1GB 
> > hugepages on node 1, 24 2MB hugepages on node 1, 2 1GB hugepages on node 
> > 2, 100 2MB hugepages on node 3, etc?  Please.
> 
> Customer has 32GB machine. He wants 8 1GB pages for his performance
> critical application on node0 (KVM guest), and other guests and
> pagecache etc. using the remaining 26GB of memory.
> 

Wow, is that it?  (This still doesn't present a clear picture since we 
don't know how much memory is on node 0, though.)

So Luiz's example of setting up different size hugepages on three 
different nodes requiring nine kernel command line parameters doesn't even 
have a legitimate usecase today.

Back to the original comment on this patchset, forgetting all this 
parameter parsing stuff, if you had the ability to free 1GB pages at 
runtime then your problem is already solved, correct?  If that 32GB 
machine has two nodes, then doing "hugepagesz=1G hugepages=16" will boot 
just fine and then an init script frees the 8 1GB pages on node1.

It gets trickier if there are four nodes and each node is 8GB.  Then you'd 
be ooming the machine if you did "hugepagesz=1G hugepages=32".  You could 
actually do "hugepagesz=1G hugepages=29" and free the hugepages on 
everything except for node 0, but I feel like movablecore= would be a 
better option.

So why not just work on making 1GB pages dynamically allocatable and 
freeable at runtime?  It feels like it would be a much more heavily used 
feature than a special command line parameter for a single customer.

> > If that's actually the usecase then I'll renew my objection to the 
> > entire patchset and say you want to add the ability to dynamically 
> > allocate 1GB pages and free them at runtime early in initscripts.  If 
> > something is going to be added to init code in the kernel then it 
> > better be trivial since all this can be duplicated in userspace if you 
> > really want to be fussy about it.
> 
> Not sure what is the point here. The command line interface addition
> being proposed is simple, is it not?
> 

You can't specify an interleave behavior with Luiz's command line 
interface so now we'd have two different interfaces for allocating 
hugepage sizes depending on whether you're specifying a node or not.  
It's "hugepagesz=1G hugepages=16" vs "hugepage_node=1:16:1G" (and I'd have 
to look at previous messages in this thread to see if that means 16 1GB 
pages on node 1 or 1 1GB pages on node 16.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
