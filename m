Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC626B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 02:18:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u21so40027937pgn.5
        for <linux-mm@kvack.org>; Thu, 11 May 2017 23:18:12 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id d1si2500271pli.110.2017.05.11.23.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 23:18:11 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id u28so25549380pgn.1
        for <linux-mm@kvack.org>; Thu, 11 May 2017 23:18:11 -0700 (PDT)
Message-ID: <1494569882.21563.8.camel@gmail.com>
Subject: [RFC summary] Enable Coherent Device Memory
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 12 May 2017 16:18:02 +1000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Here is a summary of the RFC I posted for coherent device memory
(see https://lwn.net/Articles/720380/)

I did an FAQ in one of the emails, I am extending that to summary form
so that we can move ahead towards decision making

What is coherent device memory?
 - Please see the RFC (https://lwn.net/Articles/720380/) and
   https://lwn.net/Articles/717601/
Why do we need to isolate memory?
 - CDM memory is not meant for normal usage, applications can request for it
   explictly. Oflload their compute to the device where the memory is
   (the offload is via a user space API like CUDA/openCL/...)
How do we isolate the memory - NUMA or HMM-CDM?
 - Since the memory is coherent, NUMA provides the mechanism to isolate to
   a large extent via mempolicy. With NUMA we also get autonuma/kswapd/etc
   running. Something we would like to avoid. NUMA gives the application
   a transparent view of memory, in the sense that all mm features work,
   like direct page cache allocation in coherent device memory, limiting
   memory via cgroups if required, etc. With CPUSets, its
   possible for us to isolate allocation. One challenge is that the
   admin on the system may use them differently and applications need to
   be aware of running in the right cpuset to allocate memory from the
   CDM node. Putting all applications in the cpuset with the CDM node is
   not the right thing to do, which means the application needs to move itself
   to the right cpuset before requesting for CDM memory. It's not impossible
   to use CPUsets, just hard to configure correctly.
  - With HMM, we would need a HMM variant HMM-CDM, so that we are not marking
   the pages as unavailable, page cache cannot do directly to coherent memory.
   Audit of mm paths is required. Most of the other things should work.
   User access to HMM-CDM memory behind ZONE_DEVICE is via a device driver.
Do we need to isolate node attributes independent of coherent device memory?
 - Christoph Lameter thought it would be useful to isolate node attributes,
   specifically ksm/autonuma for low latency suff.
Why do we need migration?
 - Depending on where the memory is being accessed from, we would like to
   migrate pages between system and coherent device memory. HMM provides
   DMA offload capability that is useful in both cases.
What is the larger picture - end to end?
 - Applications can allocate memory on the device or in system memory,
   offload the compute via user space API. Migration can be used for performance
   if required since it helps to keep the memory local to the compute.

Comments from the thread

1. If we go down the NUMA path, we need to live with the limitations of
   what comes with the cpuless NUMA node
2. The changes made to cpusets and mempolicies, make the code more complex
3. We need a good end to end story

The comments from the thread were responded to

How do we go about implementing CDM then?

The recommendation from John Hubbard/Mel Gorman and Michal Hocko is to
use HMM-CDM to solve the problem. Jerome/Balbir and Ben H prefer NUMA-CDM.
There were suggestions that NUMA might not be ready or is the best approach
in the long term, but we are yet to identify what changes to NUMA would
enable it to support NUMA-CDM.

The trade-offs and limitations/advantages of both approaches are in the
RFC thread and in the summary above. It seems like the from the discussions
with Michal/Mel/John the direction is to use HMM-CDM for now (both from the
thread and from mm-summit). Can we build consensus on this and move forward?
Are there any objections? Did I miss or misrepresent anything from the threads?
It would be good to get feedback from Andrew Morton and Rik Van Riel as well.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
