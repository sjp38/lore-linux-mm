Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA2C6B7C78
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:46:59 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 92so1656349qkx.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:46:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 68si975574qkg.121.2018.12.06.13.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:46:57 -0800 (PST)
Date: Thu, 6 Dec 2018 16:46:47 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181206214647.GE3544@redhat.com>
References: <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
 <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
 <20181205021334.GB3045@redhat.com>
 <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
 <20181205175357.GG3536@redhat.com>
 <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
 <20181206192050.GC3544@redhat.com>
 <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
 <20181206202706.GD3544@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181206202706.GD3544@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Thu, Dec 06, 2018 at 03:27:06PM -0500, Jerome Glisse wrote:
> On Thu, Dec 06, 2018 at 11:31:21AM -0800, Dave Hansen wrote:
> > On 12/6/18 11:20 AM, Jerome Glisse wrote:
> > >>> For case 1 you can pre-parse stuff but this can be done by helper library
> > >> How would that work?  Would each user/container/whatever do this once?
> > >> Where would they keep the pre-parsed stuff?  How do they manage their
> > >> cache if the topology changes?
> > > Short answer i don't expect a cache, i expect that each program will have
> > > a init function that query the topology and update the application codes
> > > accordingly.
> > 
> > My concern with having folks do per-program parsing, *and* having a huge
> > amount of data to parse makes it unusable.  The largest systems will
> > literally have hundreds of thousands of objects in /sysfs, even in a
> > single directory.  That makes readdir() basically impossible, and makes
> > even open() (if you already know the path you want somehow) hard to do fast.
> > 
> > I just don't think sysfs (or any filesystem, really) can scale to
> > express large, complicated topologies in a way that any normal program
> > can practically parse it.
> > 
> > My suspicion is that we're going to need to have the kernel parse and
> > cache these things.  We *might* have the data available in sysfs, but we
> > can't reasonably expect anyone to go parsing it.
> 
> What i am failing to explain is that kernel can not parse because kernel
> does not know what the application cares about and every single applications
> will make different choices and thus select differents devices and memory.
> 
> It is not even gonna a thing like class A of application will do X and
> class B will do Y. Every single application in class A might do something
> different because somes care about the little details.
> 
> So any kind of pre-parsing in the kernel is defeated by the fact that the
> kernel does not know what the application is looking for.
> 
> I do not see anyway to express the application logic in something that
> can be some kind of automaton or regular expression. The application can
> litteraly intro-inspect itself and the topology to partition its workload.
> The topology and device selection is expected to be thousands of line of
> code in the most advance application.
> 
> Even worse inside one same application, they might be different device
> partition and memory selection for different function in the application.
> 
> 
> I am not scare about the anount of data to parse really, even on big node
> it is gonna be few dozens of links and bridges, and few dozens of devices.
> So we are talking hundred directories to parse and read.
> 
> 
> Maybe an example will help. Let say we have an application with the
> following pipeline:
> 
>     inA -> functionA -> outA -> functionB -> outB -> functionC -> result
> 
>     - inA 8 gigabytes
>     - outA 8 gigabytes
>     - outB one dword
>     - result something small
>     - functionA is doing heavy computation on inA (several thousands of
>       instructions for each dword in inA).
>     - functionB is doing heavy computation for each dword in outA (again
>       thousand of instruction for each dword) and it is looking for a
>       specific result that it knows will be unique among all the dword
>       computation ie it is output only one dword in outB
>     - functionC is something well suited for CPU that take outB and turns
>       it into the final result
> 
> Now let see few different system and their topologies:
>     [T2] 1 GPU with 16GB of memory and a handfull of CPU cores
>     [T1] 1 GPU with 8GB of memory and a handfull of CPU cores
>     [T3] 2 GPU with 8GB of memory and a handfull of CPU core
>     [T4] 2 GPU with 8GB of memory and a handfull of CPU core
>          the 2 GPU have a very fast link between each others
>          (400GBytes/s)
> 
> Now let see how the program will partition itself for each topology:
>     [T1] Application partition its computation in 3 phases:
>             P1: - migrate inA to GPU memory
>             P2: - execute functionA on inA producing outA
>             P3  - execute functionB on outA producing outB
>                 - run functionC and see if functionB have found the
>                   thing and written it to outB if so then kill all
>                   GPU threads and return the result we are done
> 
>     [T2] Application partition its computation in 5 phases:
>             P1: - migrate first 4GB of inA to GPU memory
>             P2: - execute functionA for the 4GB and write the 4GB
>                   outA result to the GPU memory
>             P3: - execute functionB for the first 4GB of outA
>                 - while functionB is running DMA in the background
>                   the the second 4GB of inA to the GPU memory
>                 - once one of the millions of thread running functionB
>                   find the result it is looking for it writes it to
>                   outB which is in main memory
>                 - run functionC and see if functionB have found the
>                   thing and written it to outB if so then kill all
>                   GPU thread and DMA and return the result we are
>                   done
>             P4: - run functionA on the second half of inA ie we did
>                   not find the result in the first half so we no
>                   process the second half that have been migrated to
>                   the GPU memory in the background (see above)
>             P5: - run functionB on the second 4GB of outA like
>                   above
>                 - run functionC on CPU and kill everything as soon
>                   as one of the thread running functionB has found
>                   the result
>                 - return the result
> 
>     [T3] Application partition its computation in 3 phases:
>             P1: - migrate first 4GB of inA to GPU1 memory
>                 - migrate last 4GB of inA to GPU2 memory
>             P2: - execute functionA on GPU1 on the first 4GB -> outA
>                 - execute functionA on GPU2 on the last 4GB -> outA
>             P3: - execute functionB on GPU1 on the first 4GB of outA
>                 - execute functionB on GPU2 on the last 4GB of outA
>                 - run functionC and see if functionB running on GPU1
>                   and GPU2 have found the thing and written it to outB
>                   if so then kill all GPU threads and return the result
>                   we are done
> 
>     [T4] Application partition its computation in 2 phases:
>             P1: - migrate 8GB of inA to GPU1 memory
>                 - allocate 8GB for outA in GPU2 memory
>             P2: - execute functionA on GPU1 on the inA 8GB and write
>                   out result to GPU2 through the fast link
>                 - execute functionB on GPU2 and look over each
>                   thread on functionB on outA (busy running even
>                   if outA is not valid for each thread running
>                   functionB)
>                 - run functionC and see if functionB running on GPU2
>                   have found the thing and written it to outB if so
>                   then kill all GPU threads and return the result
>                   we are done
> 
> 
> So this is widely different partition that all depends on the topology
> and how accelerator are inter-connected and how much memory they have.
> This is a relatively simple example, they are people out there spending
> month on designing adaptive partitioning algorithm for their application.
> 

And since i am writting example, another funny one let say you have
a system with 2 nodes and on each node 2 GPU and one network. On each
node the local network adapter can only access one of the 2 GPU memory.
All the GPU are conntected to each other through a fully symmetrical
mesh inter-connect.

Now let say your program has 4 functions back to back, each functions
consuming the output of the previous one. Finaly you get your input
from the network and stream out the final function output to the network

So what you can do is:
    Node0 Net0 -> write to Node0 GPU0 memory
    Node0 GPU0 -> run first function and write result to Node0 GPU1
    Node0 GPU1 -> run second function and write result to Node1 GPU3
    Node1 GPU3 -> run third function and write result to Node1 GPU2
    Node1 Net1 -> read result from Node1 GPU2 and stream it out


Yes this kind of thing can be decided at application startup during
initialization. Idea is that you model your program computation graph
each node is a function (or group of functions) and each arrow is
data flow (input and output).

So you have a graph, now what you do is try to find a sub-graph of
your system topology that match this graph and for the system topology
you also have to check that each of your program node can run on
the specific accelerator node of your system (does the accelerator
have the feature X and Y ?)

If you are not lucky and that there is no 1 to 1 match the you can
can re-arrange/simplify your application computation graph. For
instance group multiple of your application function node into just
one node to shrink your computation graph. Rinse and repeat.


Moreover each application will have multiple separate computation
graph and the application will want to spread as evenly as possible
its workload and select the most powerfull accelerator for the most
intensive computation ...


I do not see how to have graph matching API with complex testing
where you need to query back userspace library. Like querying if
the userspace penCL driver for GPU A support feature X ? Which
might not only depend on the device generation or kernel device
driver version but also on the version of the userspace driver.

I feel it would be a lot easier to provide a graph to userspace
and have userspace do this complex matching and adaption of its
computation graph and load balance its computation at the same
time.


Of course not all application will be that complex and like i said
i believe average app (especialy desktop app design to run on
laptop) will just use a dumb down thing ie they will only use
one or two devices at the most.


Yes all this is hard but easy problems are not interesting to
solve.

Cheers,
J�r�me
