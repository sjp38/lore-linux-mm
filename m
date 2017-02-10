Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E24A96B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 10:48:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v184so53753783pgv.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 07:48:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m29si2004150pgn.56.2017.02.10.07.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 07:48:01 -0800 (PST)
From: "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>
Subject: RE: [RFC] mm/hugetlb: use mem policy when allocating surplus huge
 pages
Date: Fri, 10 Feb 2017 15:47:57 +0000
Message-ID: <ED52C51D9B87F54892CE544909A13C6C1FFB07DC@IRSMSX101.ger.corp.intel.com>
References: <1486662620-18146-1-git-send-email-grzegorz.andrejczuk@intel.com>
 <c5eb34e8-91ff-13cb-3c51-873b9af62125@oracle.com>
In-Reply-To: <c5eb34e8-91ff-13cb-3c51-873b9af62125@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "vaishali.thakkar@oracle.com" <vaishali.thakkar@oracle.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mike Kravetz, February 9, 2017 8:32 PM wrote:
> I believe another way of stating the problem is as follows:
>
> At mmap(MAP_HUGETLB) time a reservation for the number of huge pages
> is made.  If surplus huge pages need to be (and can be) allocated to
> satisfy the reservation, they will be allocated at this time.  However,
> the memory policy of the task is not taken into account when these
> pages are allocated to satisfy the reservation.
>
> Later when the task actually faults on pages in the mapping, reserved
> huge pages should be instantiated in the mapping.  However, at fault time
> the task's memory policy is taken into account.  It is possible that the
> pages reserved at mmap() time, are located on nodes such that they can
> not satisfy the request with the task's memory policy.  In such a case,
> the allocation fails in the same way as if there was no reservation.
>
> Does that sound accurate?

Yes, thank you for taking time to rephrase it.
It's much cleaner now.

> Your problem statement (and solution) address the case where surplus huge
> pages need to be allocated at mmap() time to satisfy a reservation and
> later fault.  I 'think' there is a more general problem huge page reserva=
tions
> and memory policy.

Yes, I fixed very specific code path. This problem is probably one of many
problems in the crossing of the memory policy and huge pages reservations.

> - In both cases, there are enough free pages to satisfy the reservation
>   at mmap time.  However, at fault time it can not get both the pages is
>   requires from the specified node.

There is difference that interleaving in preallocated huge page is well kno=
wn
and expected, when in overcommit all the pages might or might not be assign=
ed
to the requested NUMA node. Also after setting nr_hugepages it is possible
to check number of the huge pages reserved for each node by:
cat /sys/devices/system/node/nodeX/hugepages/hugepages-2048kB/nr_hugepages
with nr_overcommit_hugepages it is impossible.

>  I'm thinking we may need to expand the reservation tracking to be
>  per-node like free_huge_pages_node and others.  Like the code below,
>  we need to take memory policy into account at reservation time.
> =20
>  Thoughts?

Are amounts of free, allocated and surplus huge pages tracked in sysfs ment=
ioned above?
My limited understanding of this problem is that obtaining all the memory p=
olicies
requires struct vm_area (for bind, preferred) and address (for interleave).
The first is lost in hugetlb_reserve_pages, the latter is lost when file->m=
map is called.
So reservation of the huge pages needs to be done in mmap_region function
before calling file->mmap and I think this requires some new hugetlb API.=20

Best Regards,
Grzegorz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
