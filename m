Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id D46056B0031
	for <linux-mm@kvack.org>; Sun, 28 Jul 2013 02:00:55 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id wd6so3988729obb.33
        for <linux-mm@kvack.org>; Sat, 27 Jul 2013 23:00:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374848845-1429-3-git-send-email-davidlohr.bueso@hp.com>
References: <1374848845-1429-1-git-send-email-davidlohr.bueso@hp.com>
	<1374848845-1429-3-git-send-email-davidlohr.bueso@hp.com>
Date: Sun, 28 Jul 2013 14:00:54 +0800
Message-ID: <CAJd=RBCakVQ_-xxF8poU9FDjuF0k+VGSpu_aHC1A9cW8TDYr_Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] hugepage: allow parallelization of the hugepage fault path
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Gibson <david@gibson.dropbear.id.au>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 26, 2013 at 10:27 PM, Davidlohr Bueso
<davidlohr.bueso@hp.com> wrote:
> From: David Gibson <david@gibson.dropbear.id.au>
>
> At present, the page fault path for hugepages is serialized by a
> single mutex.  This is used to avoid spurious out-of-memory conditions
> when the hugepage pool is fully utilized (two processes or threads can
> race to instantiate the same mapping with the last hugepage from the
> pool, the race loser returning VM_FAULT_OOM).  This problem is
> specific to hugepages, because it is normal to want to use every
> single hugepage in the system - with normal pages we simply assume
> there will always be a few spare pages which can be used temporarily
> until the race is resolved.
>
> Unfortunately this serialization also means that clearing of hugepages
> cannot be parallelized across multiple CPUs, which can lead to very
> long process startup times when using large numbers of hugepages.
>
> This patch improves the situation by replacing the single mutex with a
> table of mutexes, selected based on a hash, which allows us to know
> which page in the file we're instantiating. For shared mappings, the
> hash key is selected based on the address space and file offset being faulted.
> Similarly, for private mappings, the mm and virtual address are used.
>
> From: Anton Blanchard <anton@samba.org>
> [https://lkml.org/lkml/2011/7/15/31]
> Forward ported and made a few changes:
>
> - Use the Jenkins hash to scatter the hash, better than using just the
>   low bits.
>
> - Always round num_fault_mutexes to a power of two to avoid an
>   expensive modulus in the hash calculation.
>
> I also tested this patch on a large POWER7 box using a simple parallel
> fault testcase:
>
> http://ozlabs.org/~anton/junkcode/parallel_fault.c
>
> Command line options:
>
> parallel_fault <nr_threads> <size in kB> <skip in kB>
>
> First the time taken to fault 128GB of 16MB hugepages:
>
> 40.68 seconds
>
> Now the same test with 64 concurrent threads:
> 39.34 seconds
>
> Hardly any speedup. Finally the 64 concurrent threads test with
> this patch applied:
> 0.85 seconds
>
> We go from 40.68 seconds to 0.85 seconds, an improvement of 47.9x
>
> This was tested with the libhugetlbfs test suite, and the PASS/FAIL
> count was the same before and after this patch.
>
> From: Davidlohr Bueso <davidlohr.bueso@hp.com>
> - Cleaned up and forward ported to Linus' latest.
> - Cache aligned mutexes.
> - Keep non SMP systems using a single mutex.
>
> It was found that this mutex can become quite contended
> during the early phases of large databases which make use of huge pages - for instance
> startup and initial runs. One clear example is a 1.5Gb Oracle database, where lockstat
> reports that this mutex can be one of the top 5 most contended locks in the kernel during
> the first few minutes:
>
>              hugetlb_instantiation_mutex:   10678     10678
>              ---------------------------
>              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
>              ---------------------------
>              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
>
> contentions:          10678
> acquisitions:         99476
> waittime-total: 76888911.01 us
>
> With this patch we see a much less contention and wait time:
>
>               &htlb_fault_mutex_table[i]:   383
>               --------------------------
>               &htlb_fault_mutex_table[i]    383   [<ffffffff8115e27b>] hugetlb_fault+0x1eb/0x440
>               --------------------------
>               &htlb_fault_mutex_table[i]    383   [<ffffffff8115e27b>] hugetlb_fault+0x1eb/0x440
>
> contentions:        383
> acquisitions:    120546
> waittime-total: 1381.72 us
>
I see same figures in the message of Jul 18,
contentions:          10678
acquisitions:         99476
waittime-total: 76888911.01 us
and
contentions:        383
acquisitions:    120546
waittime-total: 1381.72 us
if I copy and paste correctly.

Were they measured with the global semaphore introduced in 1/8 for
serializing changes in file regions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
