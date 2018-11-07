Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A28E36B0557
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:18:14 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id r14-v6so20539276ioc.7
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:18:14 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g123-v6si1369192itg.107.2018.11.07.12.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 12:18:13 -0800 (PST)
Date: Wed, 7 Nov 2018 12:17:47 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181107201746.luifrt3l2l7bkych@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105172931.GP4361@dhcp22.suse.cz>
 <20181106012955.br5swua3ykvolyjq@ca-dmjordan1.us.oracle.com>
 <20181106092145.GF27423@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181106092145.GF27423@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz, peterz@infradead.org

On Tue, Nov 06, 2018 at 10:21:45AM +0100, Michal Hocko wrote:
> On Mon 05-11-18 17:29:55, Daniel Jordan wrote:
> > On Mon, Nov 05, 2018 at 06:29:31PM +0100, Michal Hocko wrote:
> > > On Mon 05-11-18 11:55:45, Daniel Jordan wrote:
> > > > Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> > > > ktask threads now run at the lowest priority on the system to avoid disturbing
> > > > busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> > > > The plan to address your other comments is explained below.
> > > 
> > > I have only glanced through the documentation patch and it looks like it
> > > will be much less disruptive than the previous attempts. Now the obvious
> > > question is how does this behave on a moderately or even busy system
> > > when you compare that to a single threaded execution. Some numbers about
> > > best/worst case execution would be really helpful.
> > 
> > Patches 4 and 5 have some numbers where a ktask and non-ktask workload compete
> > against each other.  Those show either 8 ktask threads on 8 CPUs (worst case) or no ktask threads (best case).
> > 
> > By single threaded execution, I guess you mean 1 ktask thread.  I'll run the
> > experiments that way too and post the numbers.
> 
> I mean a comparision of how much time it gets to accomplish the same
> amount of work if it was done singlethreaded to ktask based distribution
> on a idle system (best case for both) and fully contended system (the
> worst case). It would be also great to get some numbers on partially
> contended system to see how much the priority handover etc. acts under
> different CPU contention.

Ok, thanks for clarifying.

Testing notes
 - The two workloads used were confined to run anywhere within an 8-CPU cpumask
 - The vfio workload started a 64G VM using THP
 - usemem was enlisted to create CPU load doing page clearing, just as the vfio
   case is doing, so the two compete for the same system resources.  usemem ran
   four times with each of its threads allocating and freeing 30G of memory each
   time.  Four usemem threads simulate Michal's partially contended system
 - ktask helpers always run at MAX_NICE
 - renice?=yes means run with patch 5, renice?=no means without
 - CPU:   2 nodes * 24 cores/node * 2 threads/core = 96 CPUs
          Intel(R) Xeon(R) Platinum 8160 CPU @ 2.10GHz
						
         vfio  usemem
          thr     thr  renice?          ktask sec        usemem sec
        -----  ------  -------   ----------------  ----------------
                    4      n/a                      24.0 ( +- 0.1% )
                    8      n/a                      25.3 ( +- 0.0% )
                                                             
            1       0      n/a   13.5 ( +-  0.0% )
            1       4      n/a   14.2 ( +-  0.4% )   24.1 ( +- 0.3% )
 ***        1       8      n/a   17.3 ( +- 10.4% )   29.7 ( +- 0.4% )
                                                             
            8       0       no    2.8 ( +-  1.5% )
            8       4       no    4.7 ( +-  0.8% )   24.1 ( +- 0.2% )
            8       8       no   13.7 ( +-  8.8% )   27.2 ( +- 1.2% )
        
            8       0      yes    2.8 ( +-  1.0% )
            8       4      yes    4.7 ( +-  1.4% )   24.1 ( +- 0.0% )
 ***        8       8      yes    9.2 ( +-  2.2% )   27.0 ( +- 0.4% )

Renicing under partial contention (usemem nthr=4) doesn't affect vfio, but
renicing under heavy contention (usemem nthr=8) does: the 8-thread vfio case is
slower when the ktask master thread doesn't will its priority to each helper at
a time.

Comparing the ***'d lines, using 8 vfio threads instead of 1 causes the threads
of both workloads to finish sooner under heavy contention.
