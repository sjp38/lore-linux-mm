Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 724FB6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:02:02 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so80250923pab.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:02:02 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id qe4si6181770pab.195.2016.04.27.10.02.01
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 10:02:01 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: mm: pages are not freed from lru_add_pvecs after process termination
Date: Wed, 27 Apr 2016 17:01:57 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

Hi,
I encounter a problem which I'd like to discuss here (tested on 3.10 and 4.=
5).
While running some workloads we noticed that in case of "improper" applicat=
ion
exit (like SIGTERM) quite a bit (a few GBs) of memory is not being reclaime=
d
after process termination.

Executing  echo 1 > /proc/sys/vm/compact_memory makes the memory available =
again.

This memory is not reclaimed so OOM will kill process trying to allocate me=
mory
which technically should be available.=20
Such behavior is present only when THP are [always] enabled.
Disabling it makes the issue not visible to the naked eye.

An important information is that it is visible mostly due to large amount o=
f CPUs
in the system (>200) and amount of missing memory varies with the number of=
 CPUs.

This memory seems to not be accounted anywhere, but I was able to found it =
on
per cpu lru_add_pvec lists thanks to Dave Hansen's suggestion.

Knowing that I am able to reproduce this problem with much simpler code:
//compile with: gcc repro.c -o repro -fopenmp
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include "omp.h"
int main() {
#pragma omp parallel
{
        size_t size =3D 55*1000*1000; // tweaked for 288cpus, "leaks" ~3.5G=
B
        unsigned long nodemask =3D 1;
        void *p =3D mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | =
MAP_ANONYMOUS , -1, 0);
        if(p)
                memset(p, 0, size);
       =20
        //munmap(p, size); // uncomment to make the problem go away
}
        return 0;
}


Exemplary execution:
$ numactl -H | grep "node 1" | grep MB
node 1 size: 16122 MB
node 1 free: 16026 MB
$ ./repro
$ numactl -H | grep "node 1" | grep MB
node 1 size: 16122 MB
node 1 free: 13527 MB

After a couple of minutes on idle system some of this memory is reclaimed, =
but never all
unless I run tasks on every CPU:
node 1 size: 16122 MB
node 1 free: 14823 MB

Pieces of the puzzle:
A) after process termination memory is not getting freed nor accounted as f=
ree
B) memory cannot be allocated by other processes (unless it is allocated by=
 all CPUs)

I am not sure whether it is expected behavior or a side effect of something=
 else not
going as it should. Temporarily I added lru_add_drain_all() to try_to_free_=
pages()
which sort of hammers B case, but A is still present.

I am not familiar with this code, but I feel like draining lru_add work sho=
uld be split
into smaller pieces and done by kswapd to fix A and drain only as much page=
s as
needed in try_to_free_pages to fix B.

Any comments/ideas/patches for a proper fix are welcome.

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
