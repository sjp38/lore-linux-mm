Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B46C26B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 06:28:05 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so130937944lfw.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 03:28:05 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id p200si3298051wme.0.2016.08.04.03.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 03:28:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id A3E0998A6D
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 10:28:03 +0000 (UTC)
Date: Thu, 4 Aug 2016 11:28:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
Message-ID: <20160804102801.GJ2799@techsingularity.net>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
 <1470201642.5034.3.camel@gmail.com>
 <20160803063538.GH6310@linux.vnet.ibm.com>
 <57A248A1.40807@intel.com>
 <20160804051035.GA11268@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160804051035.GA11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, mahesh@linux.vnet.ibm.com

On Thu, Aug 04, 2016 at 10:40:35AM +0530, Srikar Dronamraju wrote:
> * Dave Hansen <dave.hansen@intel.com> [2016-08-03 12:40:17]:
> 
> > On 08/02/2016 11:35 PM, Srikar Dronamraju wrote:
> > > On a regular kernel with CONFIG_FADUMP and fadump configured, 5% of the
> > > total memory is reserved for booting the kernel on crash.  On crash,
> > > fadump kernel reserves the 95% memory and boots into the 5% memory that
> > > was reserved for it. It then parses the reserved 95% memory to collect
> > > the dump.
> > > 
> > > The problem is not about the amount of memory thats reserved for fadump
> > > kernel. Even if we increase/decrease, we will still end up with the same
> > > issue.
> > 
> > Oh, and the dentry/inode caches are sized based on 100% of memory, not
> > the 5% that's left after the fadump reservation?
> 
> Yes, the dentry/inode caches are sized based on the 100% memory.
> 

By and large, I'm not a major fan of introducing an API to disable it for
a single feature that is arch-specific because it's very heavy handed.
There is no guarantee that the existence of fadump will cause a failure

If fadump is reserving memory and alloc_large_system_hash(HASH_EARLY)
does not know about then then would an arch-specific callback for
arch_reserved_kernel_pages() be more appropriate? fadump would need to
return how many pages it reserved there. That would shrink the size of
the inode and dentry hash tables when booting with 95% of memory
reserved.

That approach would limit the impact to ppc64 and would be less costly than
doing a memblock walk instead of using nr_kernel_pages for everyone else.

> > Is the deferred initialization kicked in progress at the time we do the
> > dentry/inode allocations?  Can waiting a bit let the allocation succeed?
> > 
> 
> Right now deferred initialisation kicks in after dentry/inode
> allocations.
> 
> Can we defer the cache allocations till deferred
> initialisation? I dont know.

Only by backing it with vmalloc memory.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
