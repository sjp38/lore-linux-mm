Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5186B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:39:24 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n6UJdDUP021160
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 12:39:15 -0700
Received: from ywh41 (ywh41.prod.google.com [10.192.8.41])
	by spaceape23.eur.corp.google.com with ESMTP id n6UJd9Kf016002
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 12:39:11 -0700
Received: by ywh41 with SMTP id 41so1372753ywh.23
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 12:39:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090729181205.23716.25002.sendpatchset@localhost.localdomain>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
	 <20090729181205.23716.25002.sendpatchset@localhost.localdomain>
Date: Thu, 30 Jul 2009 12:39:09 -0700
Message-ID: <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
From: David Rientjes <rientjes@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 11:12 AM, Lee
Schermerhorn<lee.schermerhorn@hp.com> wrote:
> PATCH/RFC 4/4 hugetlb: =C2=A0register per node hugepages attributes
>
> Against: 2.6.31-rc3-mmotm-090716-1432
> atop the previously posted alloc_bootmem_hugepages fix.
> [http://marc.info/?l=3Dlinux-mm&m=3D124775468226290&w=3D4]
>
> This patch adds the per huge page size control/query attributes
> to the per node sysdevs:
>
> /sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_hugepages =C2=A0 =C2=A0 =C2=A0 - r/w
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_huge_pages =C2=A0 =C2=A0- r/o
> =C2=A0 =C2=A0 =C2=A0 =C2=A0surplus_huge_pages - r/o
>
> The patch attempts to re-use/share as much of the existing
> global hstate attribute initialization and handling as possible.
> Throughout, a node id < 0 indicates global hstate parameters.
>
> Note: =C2=A0computation of "min_count" in set_max_huge_pages() for a
> specified node needs careful review.
>
> Issue: =C2=A0dependency of base driver [node] dependency on hugetlbfs mod=
ule.
> We want to keep all of the hstate attribute registration and handling
> in the hugetlb module. =C2=A0However, we need to call into this code to
> register the per node hstate attributes on node hot plug.
>
> With this patch:
>
> (me):ls /sys/devices/system/node/node0/hugepages/hugepages-2048kB
> ./ =C2=A0../ =C2=A0free_hugepages =C2=A0nr_hugepages =C2=A0surplus_hugepa=
ges
>
> Starting from:
> Node 0 HugePages_Total: =C2=A0 =C2=A0 0
> Node 0 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 0 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 1 HugePages_Total: =C2=A0 =C2=A0 0
> Node 1 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 1 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 2 HugePages_Total: =C2=A0 =C2=A0 0
> Node 2 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 2 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 3 HugePages_Total: =C2=A0 =C2=A0 0
> Node 3 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 3 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> vm.nr_hugepages =3D 0
>
> Allocate 16 persistent huge pages on node 2:
> (me):echo 16 >/sys/devices/system/node/node2/hugepages/hugepages-2048kB/n=
r_hugepages
>
> Yields:
> Node 0 HugePages_Total: =C2=A0 =C2=A0 0
> Node 0 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 0 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 1 HugePages_Total: =C2=A0 =C2=A0 0
> Node 1 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 1 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 2 HugePages_Total: =C2=A0 =C2=A016
> Node 2 HugePages_Free: =C2=A0 =C2=A0 16
> Node 2 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 3 HugePages_Total: =C2=A0 =C2=A0 0
> Node 3 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 3 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> vm.nr_hugepages =3D 16
>
> Global controls work as expected--reduce pool to 8 persistent huge pages:
> (me):echo 8 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
>
> Node 0 HugePages_Total: =C2=A0 =C2=A0 0
> Node 0 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 0 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 1 HugePages_Total: =C2=A0 =C2=A0 0
> Node 1 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 1 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 2 HugePages_Total: =C2=A0 =C2=A0 8
> Node 2 HugePages_Free: =C2=A0 =C2=A0 =C2=A08
> Node 2 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
> Node 3 HugePages_Total: =C2=A0 =C2=A0 0
> Node 3 HugePages_Free: =C2=A0 =C2=A0 =C2=A00
> Node 3 HugePages_Surp: =C2=A0 =C2=A0 =C2=A00
>
>
>
>
>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
>

Thank you very much for doing this.

Google is going to need this support regardless of what finally gets
merged into mainline, so I'm thrilled you've implemented this version.

I hugely (get it? hugely :) favor this approach because it's much
simpler to reserve hugepages from this interface than a mempolicy
based approach once hugepages have already been allocated before.  For
cpusets users in particular, jobs typically get allocated on a subset
of nodes that are required for that application and they don't last
for the duration of the machine's uptime.  When a job exits and the
nodes need to be reallocated to a new cpuset, it may be a very
different set of mems based on the memory requirements or interleave
optimizations for the new job.  Allocating resources such as hugepages
are possible in this scenario via mempolicies, but it would require a
temporary mempolicy to then allocate additional hugepages from which
seems like an unnecessary requirement, especially if the job scheduler
that is governing hugepage allocations already has a mempolicy of its
own.

So it's my opinion that the mempolicy based approach is very
appropriate for tasks that allocate hugepages itself.  Other users,
particularly cpusets users, however, would require preallocation of
hugepages prior to a job being scheduled in which case a temporary
mempolicy would be required for that job scheduler.  That seems like
an inconvenience when the entire state of the system's hugepages could
easily be governed with the per-node hstate attributes and a slightly
modified user library.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
