Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3AE6B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 11:54:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r18so2821541wmd.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 08:54:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p92si2398426wrc.192.2017.02.22.08.54.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 08:54:26 -0800 (PST)
Date: Wed, 22 Feb 2017 17:54:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170222165424.GA26472@dhcp22.suse.cz>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
 <20170222092921.GF5753@dhcp22.suse.cz>
 <20170222145915.GA4852@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222145915.GA4852@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Wed 22-02-17 09:59:15, Jerome Glisse wrote:
> On Wed, Feb 22, 2017 at 10:29:21AM +0100, Michal Hocko wrote:
> > On Tue 21-02-17 18:39:17, Anshuman Khandual wrote:
> > > On 02/17/2017 07:02 PM, Mel Gorman wrote:
> 
> [...]
> 
> > [...]
> > > These are the reasons which prohibit the use of HMM for coherent
> > > addressable device memory purpose.
> > > 
> > [...]
> > > (3) Application cannot directly allocate into device memory from user
> > > space using existing memory related system calls like mmap() and mbind()
> > > as the device memory hides away in ZONE_DEVICE.
> > 
> > Why cannot the application simply use mmap on the device file?
> 
> This has been said before but we want to share the address space this do
> imply that you can not rely on special allocator. For instance you can
> have an application that use a library and the library use the GPU but
> the application is un-aware and those any data provided by the application
> to the library will come from generic malloc (mmap anonymous or from
> regular file).
> 
> Currently what happens is that the library reallocate memory through
> special allocator and copy thing. Not only does this waste memory (the
> new memory is often regular memory too) but you also have to paid the
> cost of copying GB of data.
> 
> Last bullet to this, is complex data structure (list, tree, ...) having
> to go through special allocator means you have re-build the whole structure
> with the duplicated memory.
> 
> 
> Allowing to directly use memory allocated from malloc (mmap anonymous
> private or from a regular file) avoid the copy operation and the complex
> duplication of data structure. Moving the dataset to the GPU is then a
> simple memory migration from kernel point of view.
> 
> This is share address space without special allocator is mandatory in new
> or future standard such as OpenCL, Cuda, C++, OpenMP, ... some other OS
> already have this and the industry want it. So the questions is do we
> want to support any of this, do we care about GPGPU ?
> 
> 
> I believe we want to support all this new standard but maybe i am the
> only one.
> 
> In HMM case i have the extra painfull fact that the device memory is
> not accessible by the CPU. For CDM on contrary, CPU can access in a
> cache coherent way the device memory and all operation behave as regular
> memory (thing like atomic operation for instance).
> 
> 
> I hope this clearly explain why we can no longer rely on dedicated/
> specialized memory allocator.

Yes this clarifies this point. Thanks for the information which would be
really helpful in the initial description. Maybe I've just missed it,
though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
