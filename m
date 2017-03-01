Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1DA6B038A
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 04:55:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v77so14304766wmv.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 01:55:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si5940244wre.175.2017.03.01.01.55.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 01:55:50 -0800 (PST)
Date: Wed, 1 Mar 2017 09:55:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170301095546.GB4359@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
 <20170217093159.3t5kw7rmixrzvv7c@suse.de>
 <1487645879.10535.11.camel@gmail.com>
 <a0271d52-c60c-782a-5d0d-33c1d6d5508b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a0271d52-c60c-782a-5d0d-33c1d6d5508b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Wed, Mar 01, 2017 at 01:42:40PM +1100, Balbir Singh wrote:
> >>>The idea of this patchset was to introduce
> >>>the concept of memory that is not necessarily system memory, but is coherent
> >>>in terms of visibility/access with some restrictions
> >>>
> >>
> >>Which should be done without special casing the page allocator, cpusets and
> >>special casing how cpusets are handled. It's not necessary for any other
> >>mechanism used to restrict access to portions of memory such as cpusets,
> >>mempolicies or even memblock reservations.
> >
> >Agreed, I mentioned a limitation that we see a cpusets. I do agree that
> >we should reuse any infrastructure we have, but cpusets are more static
> >in nature and inheritence compared to the requirements of CDM.
> >
> 
> Mel, I went back and looked at cpusets and found some limitations that
> I mentioned earlier, isolating a particular node requires some amount
> of laborious work in terms of isolating all tasks away from the root cpuset
> and then creating a hierarchy where the root cpuset is empty and now
> belong to a child cpuset that has everything but the node we intend to
> ioslate. Even with hardwalling, it does not prevent allocations from
> the parent cpuset.
> 

That it is difficult does not in itself justify adding a third mechanism
specific to one type of device for controlling access to memory.

> I am trying to understand the concerns that you/Michal/Vlastimil have
> so that Anshuman/I/other stake holders can respond to the concerns
> in one place if that makes sense. Here are the concerns I have heard
> so far
> 
> 1. Lets not add any overhead to the page allocator path

Yes and that includes both runtime overhead and maintenance overhead.
Littering the allocator paths with special casing with runtime overhead
masked by static branches would still be a maintenance burden given that
most people will not have the hardware necessary to avoid regressions.

> 2. Lets try and keep the allocator changes easy to read/parse

No, simply do not add a new mechanism for controllin access to memory
when cpusets and memory policies already exist.

> 3. Why do we need a NUMA interface?
> 4. How does this compare with HMM?

Others discussed this topic in detail.

> 5. Why can't we use cpusets?
> 

That is your assertion. The concerns you have are that the work is
laborious and that designing the administrative interfaces may be
difficult. In itself that does not justify adding a third mechanism for
controlling memory acecss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
