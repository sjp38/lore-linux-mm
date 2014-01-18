Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id B44B56B0031
	for <linux-mm@kvack.org>; Sat, 18 Jan 2014 17:06:05 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wn1so206673obc.20
        for <linux-mm@kvack.org>; Sat, 18 Jan 2014 14:06:05 -0800 (PST)
Received: from g4t0014.houston.hp.com (g4t0014.houston.hp.com. [15.201.24.17])
        by mx.google.com with ESMTPS id ds9si14092174obc.60.2014.01.18.14.06.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 18 Jan 2014 14:06:04 -0800 (PST)
Message-ID: <52DAFAC7.7080307@hp.com>
Date: Sat, 18 Jan 2014 14:05:59 -0800
From: Chegu Vinod <chegu_vinod@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/7] pseudo-interleaving for automatic NUMA balancing
References: <1389993129-28180-1-git-send-email-riel@redhat.com>
In-Reply-To: <1389993129-28180-1-git-send-email-riel@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com

On 1/17/2014 1:12 PM, riel@redhat.com wrote:
> The current automatic NUMA balancing code base has issues with
> workloads that do not fit on one NUMA load. Page migration is
> slowed down, but memory distribution between the nodes where
> the workload runs is essentially random, often resulting in a
> suboptimal amount of memory bandwidth being available to the
> workload.
>
> In order to maximize performance of workloads that do not fit in one NUMA
> node, we want to satisfy the following criteria:
> 1) keep private memory local to each thread
> 2) avoid excessive NUMA migration of pages
> 3) distribute shared memory across the active nodes, to
>     maximize memory bandwidth available to the workload
>
> This patch series identifies the NUMA nodes on which the workload
> is actively running, and balances (somewhat lazily) the memory
> between those nodes, satisfying the criteria above.
>
> As usual, the series has had some performance testing, but it
> could always benefit from more testing, on other systems.
>
> Changes since v1:
>   - fix divide by zero found by Chegu Vinod
>   - improve comment, as suggested by Peter Zijlstra
>   - do stats calculations in task_numa_placement in local variables
>
>
> Some performance numbers, with two 40-warehouse specjbb instances
> on an 8 node system with 10 CPU cores per node, using a pre-cleanup
> version of these patches, courtesy of Chegu Vinod:
>
> numactl manual pinning
> spec1.txt:           throughput =     755900.20 SPECjbb2005 bops
> spec2.txt:           throughput =     754914.40 SPECjbb2005 bops
>
> NO-pinning results (Automatic NUMA balancing, with patches)
> spec1.txt:           throughput =     706439.84 SPECjbb2005 bops
> spec2.txt:           throughput =     729347.75 SPECjbb2005 bops
>
> NO-pinning results (Automatic NUMA balancing, without patches)
> spec1.txt:           throughput =     667988.47 SPECjbb2005 bops
> spec2.txt:           throughput =     638220.45 SPECjbb2005 bops
>
> No Automatic NUMA and NO-pinning results
> spec1.txt:           throughput =     544120.97 SPECjbb2005 bops
> spec2.txt:           throughput =     453553.41 SPECjbb2005 bops
>
>
> My own performance numbers are not as relevant, since I have been
> running with a more hostile workload on purpose, and I have run
> into a scheduler issue that caused the workload to run on only
> two of the four NUMA nodes on my test system...
>
> .
>


Acked-by:  Chegu Vinod <chegu_vinod@hp.com>

----

Here are some results using the v2 version of the patches
on an 8 socket box using SPECjbb2005 as a workload :

I) Eight 1-socket wide instances(10 warehouse threads each) :

                                                              Without 
patches    With patches
--------------------    ----------------
a) numactl pinning results
spec1.txt:           throughput =                     270620.04 273675.10
spec2.txt:           throughput =                     274115.33 272845.17
spec3.txt:           throughput =                     277830.09 272057.33
spec4.txt:           throughput =                     270898.52 270670.54
spec5.txt:           throughput =                     270397.30 270906.82
spec6.txt:           throughput =                     270451.93 268217.55
spec7.txt:           throughput =                     269511.07 269354.46
spec8.txt:           throughput =                     269386.06 270540.00

b)Automatic NUMA balancing results
spec1.txt:           throughput =                     244333.41 248072.72
spec2.txt:           throughput =                     252166.99 251818.30
spec3.txt:           throughput =                     251365.58 258266.24
spec4.txt:           throughput =                     245247.91 256873.51
spec5.txt:           throughput =                     245579.68 247743.18
spec6.txt:           throughput =                     249767.38 256285.86
spec7.txt:           throughput =                     244570.64 255343.99
spec8.txt:           throughput =                     245703.60 254434.36

c)NO Automatic NUMA balancing and NO-pinning results
spec1.txt:           throughput =                     132959.73 136957.12
spec2.txt:           throughput =                     127937.11 129326.23
spec3.txt:           throughput =                     130697.10 125772.11
spec4.txt:           throughput =                     134978.49 141607.58
spec5.txt:           throughput =                     127574.34 126748.18
spec6.txt:           throughput =                     138699.99 128597.95
spec7.txt:           throughput =                     133247.25 137344.57
spec8.txt:           throughput =                     124548.00 139040.98

------

II) Four 2-socket wide instances(20 warehouse threads each) :

                                                              Without 
patches    With patches
--------------------    ----------------
a) numactl pinning results
spec1.txt:           throughput =                     479931.16 472467.58
spec2.txt:           throughput =                     466652.15 466237.10
spec3.txt:           throughput =                     473591.51 466891.98
spec4.txt:           throughput =                     462346.62 466891.98

b)Automatic NUMA balancing results
spec1.txt:           throughput =                     383758.29 437489.99
spec2.txt:           throughput =                     370926.06 435692.97
spec3.txt:           throughput =                     368872.72 444615.08
spec4.txt:           throughput =                     404422.82 435236.20

c)NO Automatic NUMA balancing and NO-pinning results
spec1.txt:           throughput =                     252752.12 231762.30
spec2.txt:           throughput =                     255391.51 253250.95
spec3.txt:           throughput =                     264764.00 263721.03
spec4.txt:           throughput =                     254833.39 242892.72

------

III) Two 4-socket wide instances(40 warehouse threads each)

                                                              Without 
patches    With patches
--------------------    ----------------
a) numactl pinning results
spec1.txt:           throughput =                     771340.84 769039.53
spec2.txt:           throughput =                     762184.48 760745.65

b)Automatic NUMA balancing results
spec1.txt:           throughput =                     667182.98 720197.01
spec2.txt:           throughput =                     692564.11 739872.51

c)NO Automatic NUMA balancing and NO-pinning results
spec1.txt:           throughput = 457079.28      467199.30
spec2.txt:           throughput = 479790.47      456279.07

-----

IV) One 8-socket wide instance(80 warehouse threads)

                                                              Without 
patches    With patches
--------------------    ----------------
a) numactl pinning results
spec1.txt:           throughput =                     982113.03 985836.96

b)Automatic NUMA balancing results
spec1.txt:           throughput =                     755615.94 843632.09

c)NO Automatic NUMA balancing and NO-pinning results
spec1.txt:           throughput =                     671583.26 661768.54

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
