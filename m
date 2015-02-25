Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E85016B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 07:42:39 -0500 (EST)
Received: by wghn12 with SMTP id n12so3415369wgh.1
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 04:42:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hc4si72855224wjc.99.2015.02.25.04.42.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 04:42:38 -0800 (PST)
Message-ID: <54EDC33A.2050102@suse.cz>
Date: Wed, 25 Feb 2015 13:42:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz> <1424731603.6539.51.camel@stgolabs.net> <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org> <54EC533E.8040805@suse.cz> <20150224112412.GG5542@redhat.com>
In-Reply-To: <20150224112412.GG5542@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 02/24/2015 12:24 PM, Andrea Arcangeli wrote:
> Hi everyone,

Hi,

> On Tue, Feb 24, 2015 at 11:32:30AM +0100, Vlastimil Babka wrote:
>> I would suspect mmap_sem being held during whole THP page fault
>> (including the needed reclaim and compaction), which I forgot to mention
>> in the first e-mail - it's not just the problem page fault latency, but
>> also potentially holding back other processes, why we should allow
>> shifting from THP page faults to deferred collapsing.
>> Although the attempts for opportunistic page faults without mmap_sem
>> would also help in this particular case.
>>
>> Khugepaged also used to hold mmap_sem (for read) during the allocation
>> attempt, but that was fixed since then. It could be also zone lru_lock
>> pressure.
>
> I'm traveling and I didn't have much time to read the code yet but if
> I understood well the proposal, I've some doubt boosting khugepaged
> CPU utilization is going to provide a better universal trade off. I
> think the low overhead background scan is safer default.

Making the background scanning more efficient should be win in any case.

> If we want to do more async background work and less "synchronous work
> at fault time", what may be more interesting is to generate
> transparent hugepages in the background and possibly not to invoke
> compaction (or much compaction) in the page faults.

Steps in that direction are in fact part of the patchset :)

> I'd rather move compaction to a background kernel thread, and to
> invoke compaction synchronously only in khugepaged. I like it more if
> nothing else because it is a kind of background load that can come to
> a full stop, once enough THP have been created.

Yes, we agree here.

> Unlike khugepaged that
> can never stop to scan and it better be lightweight kind of background
> load, as it'd be running all the time.

IMHO it doesn't hurt if the scanning can focus on mm's where it's more 
likely to succeed, and tune its activity according to how successful it 
is. Then you don't need to achieve the "lightweightness" by setting the 
existing tunables to very long sleeps and very short scans, which 
increases the delay until the good collapse candidates are actually 
found by khugepaged.

> Creating THP through khugepaged is much more expensive than creating
> them on page faults. khugepaged will need to halt the userland access
> on the range once more and it'll have to copy the 2MB.

Well, Mel also suggested another thing that I didn't mention yet - 
in-place collapsing, where the base pages would be allocated on page 
faults with such layout to allow later collapse without the copying. I 
think that Kiryl's refcounting changes could potentially allow this by 
allocating a hugepage, but mapping it using pte's so it could still be 
tracked which pages are actually accessed, and from which nodes. If 
after some time it looks like a good candidate, just switch it to pmd, 
otherwise break the hugepage and free the unused base pages.

> Overall I agree with Andi we need more data collected for various
> workloads before embarking into big changes, at least so we can proof
> the changes to be beneficial to those workloads.

OK. I mainly wanted to stir some discussion at this point.

> I would advise not to make changes for app that are already the
> biggest users ever of hugetlbfs (like Oracle). Those already are
> optimized by other means. THP target are apps that have several
> benefit in not ever using hugetlbfs, so apps that are more dynamic
> workloads that don't fit well with NUMA hard pinning with numactl or
> other static placements of memory and CPU.
>
> There are also other corner cases to optimize, that have nothing to do
> with khugepaged nor compaction: for example redis has issues in the
> way it forks() and then uses the child memory as a snapshot while the
> parent keeps running and writing to the memory. If THP is enabled, the
> parent that writes to the memory will allocate and copy 2MB objects
> instead of 4k objects. That means more memory utilization but
> especially the problem are those copy_user of 2MB instead of 4k hurting
> the parent runtime.
>
> For redis we need a more finegrined thing than MADV_NOHUGEPAGE. It
> needs a MADV_COW_NOHUGEPAGE (please think at a better name) that will
> only prevent THP creation during COW faults but still maximize THP
> utilization for every other case. Once such a madvise will become
> available, redis will run faster with THP enabled (currently redis
> recommends THP disabled because of the higher latencies in the 2MB COW
> faults while the child process is snapshotting). When the snapshot is
> finished and the child quits, khugepaged will recreate THP for those
> fragmented cows.

Hm sounds like Kiryl's patchset could also help here? In parent, split 
only the pmd and do cow on 4k pages, while child keeps the whole THP.
Later khugepaged can recreate THP for the parent, as you say. That 
should be better default behavior than the current 2MB copies, not just 
for redis? And no new madvise needed. Or maybe with MADV_HUGEPAGE you 
can assume that the caller does want the 2MB COW behavior?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
