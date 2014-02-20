Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 18F946B0039
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 21:23:44 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so661927eek.3
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:23:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v5si4826085eel.118.2014.02.19.18.23.42
        for <linux-mm@kvack.org>;
        Wed, 19 Feb 2014 18:23:43 -0800 (PST)
Date: Wed, 19 Feb 2014 23:22:55 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140220022254.GA25898@amt.cnet>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
 <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
 <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
 <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
 <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 18, 2014 at 02:16:42PM -0800, David Rientjes wrote:
> On Tue, 18 Feb 2014, Marcelo Tosatti wrote:
> 
> > > Lacking from your entire patchset is a specific example of what you want 
> > > to do.  So I think we're all guessing what exactly your usecase is and we 
> > > aren't getting any help.  Are you really suggesting that a customer wants 
> > > to allocate 4 1GB hugepages on node 0, 12 2MB hugepages on node 0, 6 1GB 
> > > hugepages on node 1, 24 2MB hugepages on node 1, 2 1GB hugepages on node 
> > > 2, 100 2MB hugepages on node 3, etc?  Please.
> > 
> > Customer has 32GB machine. He wants 8 1GB pages for his performance
> > critical application on node0 (KVM guest), and other guests and
> > pagecache etc. using the remaining 26GB of memory.
> > 
> 
> Wow, is that it?  (This still doesn't present a clear picture since we 
> don't know how much memory is on node 0, though.)
>
> So Luiz's example of setting up different size hugepages on three 
> different nodes requiring nine kernel command line parameters doesn't even 
> have a legitimate usecase today.
> 
> Back to the original comment on this patchset, forgetting all this 
> parameter parsing stuff, if you had the ability to free 1GB pages at 
> runtime then your problem is already solved, correct?  If that 32GB 
> machine has two nodes, then doing "hugepagesz=1G hugepages=16" will boot 
> just fine and then an init script frees the 8 1GB pages on node1.
> 
> It gets trickier if there are four nodes and each node is 8GB.  Then you'd 
> be ooming the machine if you did "hugepagesz=1G hugepages=32".  You could 
> actually do "hugepagesz=1G hugepages=29" and free the hugepages on 
> everything except for node 0, but I feel like movablecore= would be a 
> better option.
> 
> So why not just work on making 1GB pages dynamically allocatable and 
> freeable at runtime?  It feels like it would be a much more heavily used 
> feature than a special command line parameter for a single customer.

David,

We agree that, in the future, we'd like to provide the ability to
dynamically allocate and free 1GB pages at runtime.

Extending the kernel command line interface is a first step.

Do you have a concrete objection to that first step ?

> > > If that's actually the usecase then I'll renew my objection to the 
> > > entire patchset and say you want to add the ability to dynamically 
> > > allocate 1GB pages and free them at runtime early in initscripts.  If 
> > > something is going to be added to init code in the kernel then it 
> > > better be trivial since all this can be duplicated in userspace if you 
> > > really want to be fussy about it.
> > 
> > Not sure what is the point here. The command line interface addition
> > being proposed is simple, is it not?
> > 
> 
> You can't specify an interleave behavior with Luiz's command line 
> interface so now we'd have two different interfaces for allocating 
> hugepage sizes depending on whether you're specifying a node or not.  
> It's "hugepagesz=1G hugepages=16" vs "hugepage_node=1:16:1G" (and I'd have 
> to look at previous messages in this thread to see if that means 16 1GB 
> pages on node 1 or 1 1GB pages on node 16.)

What syntax do you prefer and why ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
