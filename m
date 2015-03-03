Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 36AA26B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 13:35:18 -0500 (EST)
Received: by wiwh11 with SMTP id h11so25104031wiw.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 10:35:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si25413522wif.64.2015.03.03.10.35.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 10:35:16 -0800 (PST)
Message-ID: <54F5FEE0.2090104@suse.cz>
Date: Tue, 03 Mar 2015 19:35:12 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Resurrecting the VM_PINNED discussion
References: <20150303174105.GA3295@akamai.com>
In-Reply-To: <20150303174105.GA3295@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On 03/03/2015 06:41 PM, Eric B Munson wrote:> All,
>
> After LSF/MM last year Peter revived a patch set that would create
> infrastructure for pinning pages as opposed to simply locking them.
> AFAICT, there was no objection to the set, it just needed some help
> from the IB folks.
>
> Am I missing something about why it was never merged?  I ask because
> Akamai has bumped into the disconnect between the mlock manpage,
> Documentation/vm/unevictable-lru.txt, and reality WRT compaction and
> locking.  A group working in userspace read those sources and wrote a
> tool that mmaps many files read only and locked, munmapping them when
> they are no longer needed.  Locking is used because they cannot afford a
> major fault, but they are fine with minor faults.  This tends to
> fragment memory badly so when they started looking into using hugetlbfs
> (or anything requiring order > 0 allocations) they found they were not
> able to allocate the memory.  They were confused based on the referenced
> documentation as to why compaction would continually fail to yield
> appropriately sized contiguous areas when there was more than enough
> free memory.

So you are saying that mlocking (VM_LOCKED) prevents migration and thus
compaction to do its job? If that's true, I think it's a bug as it is AFAIK
supposed to work just fine.

> I would like to see the situation with VM_LOCKED cleared up, ideally the
> documentation would remain and reality adjusted to match and I think
> Peter's VM_PINNED set goes in the right direction for this goal.  What
> is missing and how can I help?

I don't think VM_PINNED would help you. In fact it is VM_PINNED that improves
accounting for the kind of locking (pinning) that *does* prevent page migration
(unlike mlocking)... quoting the patchset cover letter:

"These patches introduce VM_PINNED infrastructure, vma tracking of persistent
'pinned' page ranges. Pinned is anything that has a fixed phys address (as
required for say IO DMA engines) and thus cannot use the weaker VM_LOCKED. One
popular way to pin pages is through get_user_pages() but that not nessecarily
the only way."

> Thanks,
> Eric
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
