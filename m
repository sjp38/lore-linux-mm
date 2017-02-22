Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 223FB6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 04:29:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s27so1651163wrb.5
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 01:29:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z64si973742wrc.201.2017.02.22.01.29.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 01:29:25 -0800 (PST)
Date: Wed, 22 Feb 2017 10:29:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170222092921.GF5753@dhcp22.suse.cz>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue 21-02-17 18:39:17, Anshuman Khandual wrote:
> On 02/17/2017 07:02 PM, Mel Gorman wrote:
[...]
> > Why can this not be expressed with cpusets and memory policies
> > controlled by a combination of administrative steps for a privileged
> > application and an application that is CDM aware?
> 
> Hmm, that can be done but having an in kernel infrastructure has the
> following benefits.
> 
> * Administrator does not have to listen to node add notifications
>   and keep the isolation/allowed cpusets upto date all the time.
>   This can be a significant overhead on the admin/userspace which
>   have a number of separate device memory nodes.

But the application has to communicate with the device so why it cannot
use a device specific allocation as well? I really fail to see why
something this special should hide behind a generic API to spread all
the special casing into the kernel instead.
 
> * With cpuset solution, tasks which are part of CDM allowed cpuset
>   can have all it's VMAs allocate from CDM memory which may not be
>   something the user want. For example user may not want to have
>   the text segments, libraries allocate from CDM. To achieve this
>   the user will have to explicitly block allocation access from CDM
>   through mbind(MPOL_BIND) memory policy setups. This negative setup
>   is a big overhead. But with in kernel CDM framework, isolation is
>   enabled by default. For CDM allocations the application just has
>   to setup memory policy with CDM node in the allowed nodemask.

Which makes cpusets vs. mempolicies even bigger mess, doesn't it? So say
that you have an application which wants to benefit from CDM and use
mbind to have an access to this memory for particular buffer. Now you
try to run this application in a cpuset which doesn't include this node
and now what? Cpuset will override the application policy so the buffer
will never reach the requested node. At least not without even more
hacks to cpuset handling. I really do not like that!

[...]
> These are the reasons which prohibit the use of HMM for coherent
> addressable device memory purpose.
> 
[...]
> (3) Application cannot directly allocate into device memory from user
> space using existing memory related system calls like mmap() and mbind()
> as the device memory hides away in ZONE_DEVICE.

Why cannot the application simply use mmap on the device file?

> Apart from that, CDM framework provides a different approach to device
> memory representation which does not require special device memory kind
> of handling and associated call backs as implemented by HMM. It provides
> NUMA node based visibility to the user space which can be extended to
> support new features.

What do you mean by new features and how users will use/request those
features (aka what is the API)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
