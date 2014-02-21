Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 19D916B00AC
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 21:28:51 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id y10so2064418wgg.28
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 18:28:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id vv2si6906275wjc.8.2014.02.20.18.28.48
        for <linux-mm@kvack.org>;
        Thu, 20 Feb 2014 18:28:49 -0800 (PST)
Date: Thu, 20 Feb 2014 23:28:00 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140221022800.GA30230@amt.cnet>
References: <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
 <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
 <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140220213407.GA11048@amt.cnet>
 <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 20, 2014 at 03:15:46PM -0800, David Rientjes wrote:
> On Thu, 20 Feb 2014, Marcelo Tosatti wrote:
> 
> > Mel has clearly has no objection to the command line. You can also
> > allocate 2M pages at runtime, and that is no reason for "hugepages="
> > interface to not exist. 
> > 
> 
> The "hugepages=" interface does exist and for good reason, when 
> fragmentation is such that you cannot allocate that number of hugepages at 
> runtime easily.  That's lacking from your use case: why can't your 
> customer do it from an initscript?  So far, all you've said is that your 
> customer wants 8 1GB hugepages on node 0 for a 32GB machine.

See below about particular hugepages distribution.

> > There is a number of parameters that are modifiable via the kernel
> > command line, so following your reasoning, they should all be removed,
> > because it can be done at runtime.
> > 
> 
> 1GB is of such granularity that you'd typically either be (a) oom so that 
> your userspace couldn't even start, or (b) have enough memory such that 
> userspace would be able to start and allocate them dynamically through an 
> initscript.

There are a number of kernel command line parameters which can be
modified in runtime as well.

> > Yes, we'd like to maintain backwards compatibility.
> > 
> 
> Good, see below.
> 
> > > Thus, it seems, the easiest addition would have 
> > > been "hugepagesnode=" which I've mentioned several times, there's no 
> > > reason to implement yet another command line option purely as a shorthand 
> > > which hugepage_node=1:2:1G is and in a very cryptic way.
> > 
> > Can you state your suggestion clearly (or point to such messages), and
> > list the advantages of it versus the proposed patch ?
> > 
> 
> My suggestion was posted on the same day this patchset was posted: 
> http://marc.info/?l=linux-kernel&m=139241967514884 it would be helpful if 
> you read the thread before asking for something that has been repeated 
> over and over.

Please, repeat it. Compare your suggestion to the proposed interface.
Copy & paste if necessary. You have not given a single technical point 
so far.

There is not ONE technical point in this message:
http://marc.info/?l=linux-kernel&m=139241967514884

You are asking what is the use-case.

> There's no need to implement a shorthand that combines a few kernel 
> command line options.
> 
> That's not the issue, anymore, though, since there's no need for the 
> patchset to begin with if you can dynamically allocate 1GB hugepages at 
> runtime.  If your customer wanted 4096 2MB hugepages on node 0 instead of 
> 8 1GB hugepages on node 0, we'd not be having this conversation.

A particular distribution is irrelevant. What you want is a non default
distribution of 1GB hugepages.

Can you agree with that ? (forget about particular values, please).

> Do I really need to do your work for you and work on 1GB hugepages at 
> runtime, which many more people would be interested in?  

Our interest is satistified by this patch. The interest below is
satisfied by the patch.

> Or are we just 
> seeking the easiest way out here with something that shuts the customer up 
> and leaves a kernel command line option that we'll need to maintain to 
> avoid breaking backwards compatibility in the future?

We'd like to backport the minimal amount of code (minimal amount of
code = kernel command line interface). 

USE CASE FOR "hugetlb: add hugepages_node= command-line option" PATCH.

Requirement1) Assume N 1GB hugepages on node A. No other hugepages on any node 
are desired (because that memory must be free, for other uses).
Requirement2) Assume that failure to allocate N 1GB hugepages is not acceptable.

For this pair of requirements, THERE IS NO DIFFERENCE AT ALL whether
1GB pages are allocated in userspace or via kernel command line.
All it matters is that pages are allocated accordingly to Requirement1).

Feel free to replace page distribution on Requirement1) by your
imagination of how people can make use of computers.

Now, your suggestion is to allocate pages during runtime. OK, can you
explain what are the advantages of doing so (for use case above) ?

Or for any use case which _MUST ALLOCATE_ a given number of 1GB hugepages ?

"I object to a new kernel command line parameter because that
parameter can be specified during runtime" is not a valid objection to me.

It seems you are interested in writing code to allocate 1GB pages during 
runtime? Sure, go ahead, no one is stopping you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
