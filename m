Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8926B4A56
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 15:24:19 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id y65so14989711ywy.3
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:24:19 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g4-v6si3227847ybq.491.2018.11.27.12.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 12:24:17 -0800 (PST)
Date: Tue, 27 Nov 2018 12:23:59 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
 initialization within each node
Message-ID: <20181127202359.biav42vbfchprmo5@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-12-daniel.m.jordan@oracle.com>
 <AT5PR8401MB1169798EBEF1EE5EBA3ABFFFABC70@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <20181112165412.vizeiv6oimsuxkbk@ca-dmjordan1.us.oracle.com>
 <AT5PR8401MB1169B05F889BCF8EF113E053ABC10@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <20181119160137.72zha7dbsr3adkfs@ca-dmjordan1.us.oracle.com>
 <AT5PR8401MB1169AA00F542BA2E3204FC24ABD00@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AT5PR8401MB1169AA00F542BA2E3204FC24ABD00@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: 'Daniel Jordan' <daniel.m.jordan@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jgg@mellanox.com" <jgg@mellanox.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, peterz@infradead.org, dhaval.giani@oracle.com

On Tue, Nov 27, 2018 at 12:12:28AM +0000, Elliott, Robert (Persistent Memory) wrote:
> I ran a short test with:
> * HPE ProLiant DL360 Gen9 system
> * Intel Xeon E5-2699 CPU with 18 physical cores (0-17) and 
>   18 hyperthreaded cores (36-53)
> * DDR4 NVDIMM-Ns (which run at regular DRAM DIMM speeds)
> * fio workload generator
> * cores on one CPU socket talking to a pmem device on the same CPU
> * large (1 MiB) random writes (to minimize the threads getting CPU cache
>   hits from each other)
> 
> Results:
> * 31.7 GB/s    four threads, four physical cores (0,1,2,3)
> * 22.2 GB/s    four threads, two physical cores (0,1,36,37)
> * 21.4 GB/s    two threads, two physical cores (0,1)
> * 12.1 GB/s    two threads, one physical core (0,36)
> * 11.2 GB/s    one thread, one physical core (0)
> 
> So, I think it's important that the initialization threads run on
> separate physical cores.

Thanks for running this.  And fair enough, in this test using both siblings
gives only a 4-8% speedup over one, so it makes sense to use only cores in the
calculation.

As for how to actually do this, some arches have smp_num_siblings, but there
should be a generic interface to provide that.

It's also possible to calculate this from the existing
topology_sibling_cpumask, but the first option is better IMHO.  Open to
suggestions.

> For the number of cores to use, one approach is:
>     memory bandwidth (number of interleaved channels * speed)
> divided by 
>     CPU core max sustained write bandwidth
> 
> For example, this 2133 MT/s system is roughly:
>     68 GB/s    (4 * 17 GB/s nominal)
> divided by
>     11.2 GB/s  (one core's performance)
> which is 
>     6 cores
> 
> ACPI HMAT will report that 68 GB/s number.  I'm not sure of
> a good way to discover the 11.2 GB/s number.

Yes, this would be nice to do if we could know the per-core number, with the
caveat that a single number like this would be most useful for the CPU-memory
pair it was calculated for, so the kernel could at least calculate it for jobs
operating on local memory.

Some BogoMIPS-like calibration may work, but I'll wait for ACPI HMAT support in
the kernel.
