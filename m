Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE7AE6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 13:49:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id l7-v6so23645088qkd.5
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 10:49:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d23-v6sor47348295qve.3.2018.11.05.10.49.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 10:49:17 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Date: Mon, 05 Nov 2018 13:49:14 -0500
Message-ID: <FC2EB02D-3D05-4A13-A92E-4171B37B15BA@cs.rutgers.edu>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_188073F8-AE4B-4D51-8A2B-26000093248E_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_188073F8-AE4B-4D51-8A2B-26000093248E_=
Content-Type: text/plain

Hi Daniel,

On 5 Nov 2018, at 11:55, Daniel Jordan wrote:

> Hi,
>
> This version addresses some of the feedback from Andrew and Michal last year
> and describes the plan for tackling the rest.  I'm posting now since I'll be
> presenting ktask at Plumbers next week.
>
> Andrew, you asked about parallelizing in more places[0].  This version adds
> multithreading for VFIO page pinning, and there are more planned users listed
> below.
>
> Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> ktask threads now run at the lowest priority on the system to avoid disturbing
> busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> The plan to address your other comments is explained below.
>
> Alex, any thoughts about the VFIO changes in patches 6-9?
>
> Tejun and Lai, what do you think of patch 5?
>
> And for everyone, questions and comments welcome.  Any suggestions for more
> users?
>
>          Thanks,
>             Daniel
>
> P.S.  This series is big to address the above feedback, but I can send patches
> 7 and 8 separately.
>
>
> TODO
> ----
>
>  - Implement cgroup-aware unbound workqueues in a separate series, picking up
>    Bandan Das's effort from two years ago[2].  This should hopefully address
>    Michal's comment about running ktask threads within the limits of the calling
>    context[1].
>
>  - Make ktask aware of power management.  A starting point is to disable the
>    framework when energy-conscious cpufreq settings are enabled (e.g.
>    powersave, conservative scaling governors).  This should address another
>    comment from Michal about keeping CPUs under power constraints idle[1].
>
>  - Add more users.  On my list:
>     - __ib_umem_release in IB core, which Jason Gunthorpe mentioned[3]
>     - XFS quotacheck and online repair, as suggested by Darrick Wong
>     - vfs object teardown at umount time, as Andrew mentioned[0]
>     - page freeing in munmap/exit, as Aaron Lu posted[4]
>     - page freeing in shmem
>    The last three will benefit from scaling zone->lock and lru_lock.
>
>  - CPU hotplug support for ktask to adjust its per-CPU data and resource
>    limits.
>
>  - Check with IOMMU folks that iommu_map is safe for all IOMMU backend
>    implementations (it is for x86).
>
>
> Summary
> -------
>
> A single CPU can spend an excessive amount of time in the kernel operating
> on large amounts of data.  Often these situations arise during initialization-
> and destruction-related tasks, where the data involved scales with system size.
> These long-running jobs can slow startup and shutdown of applications and the
> system itself while extra CPUs sit idle.
>
> To ensure that applications and the kernel continue to perform well as core
> counts and memory sizes increase, harness these idle CPUs to complete such jobs
> more quickly.
>
> ktask is a generic framework for parallelizing CPU-intensive work in the
> kernel.  The API is generic enough to add concurrency to many different kinds
> of tasks--for example, zeroing a range of pages or evicting a list of
> inodes--and aims to save its clients the trouble of splitting up the work,
> choosing the number of threads to use, maintaining an efficient concurrency
> level, starting these threads, and load balancing the work between them.
>
> The first patch has more documentation, and the second patch has the interface.
>
> Current users:
>  1) VFIO page pinning before kvm guest startup (others hitting slowness too[5])
>  2) deferred struct page initialization at boot time
>  3) clearing gigantic pages
>  4) fallocate for HugeTLB pages

Do you think if it makes sense to use ktask for huge page migration (the data
copy part)?

I did some experiments back in 2016[1], which showed that migrating one 2MB page
with 8 threads could achieve 2.8x throughput of the existing single-threaded method.
The problem with my parallel page migration patchset at that time was that it
has no CPU-utilization awareness, which is solved by your patches now.

Thanks.

[1]https://lkml.org/lkml/2016/11/22/457

--
Best Regards
Yan Zi

--=_MailMate_188073F8-AE4B-4D51-8A2B-26000093248E_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvgkKoWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzCsoB/9adWQHhxopT/in3MJ3dD2fmL8L
ppWt8KzylmT+ch6RC1TZXbS4me6qH7GiRfUE25huE/mFDmsm2FrjwzUuniGjfWV6
qTdp0N5hxMj73mZ37yMqthoFA1dZDfPsOMPEjqjXgVRaMZ1Fi/7Dpig3k4Y2zVOA
DZHaP01RORABNSuUYAVf2I56tl93s8uQfEzL9nmGjNuAi1waQa2DhSpX739hutym
SXcq3GzHzsQbSj7aB6r7GNfKqdNh64Py7XZ2AB2g6ksCARf5PihrYuUPae56Jthr
WHzV3wBgINWZJSP1z6cgEGrBN9WKXd1Sexe21JmCjjR+GeLbvj11DCBOkuko
=dwE+
-----END PGP SIGNATURE-----

--=_MailMate_188073F8-AE4B-4D51-8A2B-26000093248E_=--
