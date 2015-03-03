Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A6EF96B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 15:20:54 -0500 (EST)
Received: by wevm14 with SMTP id m14so42165731wev.13
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 12:20:54 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1si4743418wik.65.2015.03.03.12.20.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 12:20:53 -0800 (PST)
Message-ID: <54F617A2.8040405@suse.cz>
Date: Tue, 03 Mar 2015 21:20:50 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Resurrecting the VM_PINNED discussion
References: <20150303174105.GA3295@akamai.com> <54F5FEE0.2090104@suse.cz> <20150303184520.GA4996@akamai.com>
In-Reply-To: <20150303184520.GA4996@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On 03/03/2015 07:45 PM, Eric B Munson wrote:
> On Tue, 03 Mar 2015, Vlastimil Babka wrote:
> 
>> On 03/03/2015 06:41 PM, Eric B Munson wrote:> All,
>> >
>> > After LSF/MM last year Peter revived a patch set that would create
>> > infrastructure for pinning pages as opposed to simply locking them.
>> > AFAICT, there was no objection to the set, it just needed some help
>> > from the IB folks.
>> >
>> > Am I missing something about why it was never merged?  I ask because
>> > Akamai has bumped into the disconnect between the mlock manpage,
>> > Documentation/vm/unevictable-lru.txt, and reality WRT compaction and
>> > locking.  A group working in userspace read those sources and wrote a
>> > tool that mmaps many files read only and locked, munmapping them when
>> > they are no longer needed.  Locking is used because they cannot afford a
>> > major fault, but they are fine with minor faults.  This tends to
>> > fragment memory badly so when they started looking into using hugetlbfs
>> > (or anything requiring order > 0 allocations) they found they were not
>> > able to allocate the memory.  They were confused based on the referenced
>> > documentation as to why compaction would continually fail to yield
>> > appropriately sized contiguous areas when there was more than enough
>> > free memory.
>> 
>> So you are saying that mlocking (VM_LOCKED) prevents migration and thus
>> compaction to do its job? If that's true, I think it's a bug as it is AFAIK
>> supposed to work just fine.
> 
> Agreed.  But as has been discussed in the threads around the VM_PINNED
> work, there are people that are relying on the fact that VM_LOCKED
> promises no minor faults.  Which is why the behavoir has remained.

At least in the VM_PINNED thread after last lsf/mm, I don't see this mentioned.
I found no references to mlocking in compaction.c, and in migrate.c there's just
mlock_migrate_page() with comment:

/*
 * mlock_migrate_page - called only from migrate_page_copy() to
 * migrate the Mlocked page flag; update statistics.
 */

It also passes TTU_IGNORE_MLOCK to try_to_unmap(). So what am I missing? Where
is this restriction?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
