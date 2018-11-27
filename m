Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B88266B449E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 19:12:33 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id w6so9450766otb.6
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 16:12:33 -0800 (PST)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id 6si808061otb.214.2018.11.26.16.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 16:12:32 -0800 (PST)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
 initialization within each node
Date: Tue, 27 Nov 2018 00:12:28 +0000
Message-ID: <AT5PR8401MB1169AA00F542BA2E3204FC24ABD00@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-12-daniel.m.jordan@oracle.com>
 <AT5PR8401MB1169798EBEF1EE5EBA3ABFFFABC70@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <20181112165412.vizeiv6oimsuxkbk@ca-dmjordan1.us.oracle.com>
 <AT5PR8401MB1169B05F889BCF8EF113E053ABC10@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <20181119160137.72zha7dbsr3adkfs@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20181119160137.72zha7dbsr3adkfs@ca-dmjordan1.us.oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Daniel Jordan' <daniel.m.jordan@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jgg@mellanox.com" <jgg@mellanox.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>



> -----Original Message-----
> From: Daniel Jordan [mailto:daniel.m.jordan@oracle.com]
> Sent: Monday, November 19, 2018 10:02 AM
> On Mon, Nov 12, 2018 at 10:15:46PM +0000, Elliott, Robert (Persistent Mem=
ory) wrote:
> >
> > > -----Original Message-----
> > > From: Daniel Jordan <daniel.m.jordan@oracle.com>
> > > Sent: Monday, November 12, 2018 11:54 AM
> > >
> > > On Sat, Nov 10, 2018 at 03:48:14AM +0000, Elliott, Robert (Persistent
> > > Memory) wrote:
> > > > > -----Original Message-----
> > > > > From: linux-kernel-owner@vger.kernel.org <linux-kernel-
> > > > > owner@vger.kernel.org> On Behalf Of Daniel Jordan
> > > > > Sent: Monday, November 05, 2018 10:56 AM
> > > > > Subject: [RFC PATCH v4 11/13] mm: parallelize deferred struct pag=
e
> > > > > initialization within each node
> > > > >
> > ...
> > > > > In testing, a reasonable value turned out to be about a quarter o=
f the
> > > > > CPUs on the node.
> > > > ...
> > > > > +	/*
> > > > > +	 * We'd like to know the memory bandwidth of the chip to
> > > > >         calculate the
> > > > > +	 * most efficient number of threads to start, but we can't.
> > > > > +	 * In testing, a good value for a variety of systems was a
> > > > >         quarter of the CPUs on the node.
> > > > > +	 */
> > > > > +	nr_node_cpus =3D DIV_ROUND_UP(cpumask_weight(cpumask), 4);
> > > >
> > > >
> > > > You might want to base that calculation on and limit the threads to
> > > > physical cores, not hyperthreaded cores.
> > >
> > > Why?  Hyperthreads can be beneficial when waiting on memory.  That sa=
id, I
> > > don't have data that shows that in this case.
> >
> > I think that's only if there are some register-based calculations to do=
 while
> > waiting. If both threads are just doing memory accesses, they'll both s=
tall, and
> > there doesn't seem to be any benefit in having two contexts generate th=
e IOs
> > rather than one (at least on the systems I've used). I think it takes l=
onger
> > to switch contexts than to just turnaround the next IO.
>=20
> (Sorry for the delay, Plumbers is over now...)
>=20
> I guess we're both just waving our hands without data.  I've only got x86=
, so
> using a quarter of the CPUs rules out HT on my end.  Do you have a system=
 that
> you can test this on, where using a quarter of the CPUs will involve HT?

I ran a short test with:
* HPE ProLiant DL360 Gen9 system
* Intel Xeon E5-2699 CPU with 18 physical cores (0-17) and=20
  18 hyperthreaded cores (36-53)
* DDR4 NVDIMM-Ns (which run at regular DRAM DIMM speeds)
* fio workload generator
* cores on one CPU socket talking to a pmem device on the same CPU
* large (1 MiB) random writes (to minimize the threads getting CPU cache
  hits from each other)

Results:
* 31.7 GB/s    four threads, four physical cores (0,1,2,3)
* 22.2 GB/s    four threads, two physical cores (0,1,36,37)
* 21.4 GB/s    two threads, two physical cores (0,1)
* 12.1 GB/s    two threads, one physical core (0,36)
* 11.2 GB/s    one thread, one physical core (0)

So, I think it's important that the initialization threads run on
separate physical cores.

For the number of cores to use, one approach is:
    memory bandwidth (number of interleaved channels * speed)
divided by=20
    CPU core max sustained write bandwidth

For example, this 2133 MT/s system is roughly:
    68 GB/s    (4 * 17 GB/s nominal)
divided by
    11.2 GB/s  (one core's performance)
which is=20
    6 cores

ACPI HMAT will report that 68 GB/s number.  I'm not sure of
a good way to discover the 11.2 GB/s number.


fio job file:
[global]
direct=3D1
ioengine=3Dsync
norandommap
randrepeat=3D0
bs=3D1M
runtime=3D20
time_based=3D1
group_reporting
thread
gtod_reduce=3D1
zero_buffers
cpus_allowed_policy=3Dsplit
# pick the desired number of threads
numjobs=3D4
numjobs=3D2
numjobs=3D1

# CPU0: cores 0-17, hyperthreaded cores 36-53
[pmem0]
filename=3D/dev/pmem0
# pick the desired cpus_allowed list
cpus_allowed=3D0,1,2,3
cpus_allowed=3D0,1,36,37
cpus_allowed=3D0,36
cpus_allowed=3D0,1
cpus_allowed=3D0
rw=3Drandwrite

Although most CPU time is in movnti instructions (non-temporal stores),
there is overhead in clearing the page cache and in the pmem block
driver; those won't be present in your initialization function.=20
perf top shows:
  82.00%  [kernel]                [k] memcpy_flushcache
   5.23%  [kernel]                [k] gup_pgd_range
   3.41%  [kernel]                [k] __blkdev_direct_IO_simple
   2.38%  [kernel]                [k] pmem_make_request
   1.46%  [kernel]                [k] write_pmem
   1.29%  [kernel]                [k] pmem_do_bvec


---
Robert Elliott, HPE Persistent Memory
