Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B34686B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 17:05:53 -0500 (EST)
Received: by wggx13 with SMTP id x13so2720124wgg.4
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 14:05:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si5072840wiv.90.2015.03.03.14.05.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 14:05:52 -0800 (PST)
Message-ID: <54F6303C.5080806@suse.cz>
Date: Tue, 03 Mar 2015 23:05:48 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Resurrecting the VM_PINNED discussion
References: <20150303174105.GA3295@akamai.com> <54F5FEE0.2090104@suse.cz> <20150303184520.GA4996@akamai.com> <54F617A2.8040405@suse.cz> <20150303210150.GA6995@akamai.com> <20150303215258.GB6995@akamai.com>
In-Reply-To: <20150303215258.GB6995@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On 03/03/2015 10:52 PM, Eric B Munson wrote:
> On Tue, 03 Mar 2015, Eric B Munson wrote:
> 
>> On Tue, 03 Mar 2015, Vlastimil Babka wrote:
>> 
>> > On 03/03/2015 07:45 PM, Eric B Munson wrote:
>> > > On Tue, 03 Mar 2015, Vlastimil Babka wrote:
>> > > 
>> > > Agreed.  But as has been discussed in the threads around the VM_PINNED
>> > > work, there are people that are relying on the fact that VM_LOCKED
>> > > promises no minor faults.  Which is why the behavoir has remained.
>> > 
>> > At least in the VM_PINNED thread after last lsf/mm, I don't see this mentioned.
>> > I found no references to mlocking in compaction.c, and in migrate.c there's just
>> > mlock_migrate_page() with comment:
>> > 
>> > /*
>> >  * mlock_migrate_page - called only from migrate_page_copy() to
>> >  * migrate the Mlocked page flag; update statistics.
>> >  */
>> > 
>> > It also passes TTU_IGNORE_MLOCK to try_to_unmap(). So what am I missing? Where
>> > is this restriction?
>> > 
>> 
>> I spent quite some time looking for it as well, it is in vmscan.c
>> 
>> int __isolate_lru_page(struct page *page, isolate_mode_t mode)
>> {
>> ...
>>         /* Compaction should not handle unevictable pages but CMA can do so */
>>         if (PageUnevictable(page) && !(mode & ISOLATE_UNEVICTABLE))
>>                 return ret;
>> ...
>> 
>> 
> 
> And that demonstrates that I haven't spent enough time with this code,
> that isn't the restriction because when this is called from compaction.c
> the mode is set to ISOLATE_UNEVICTABLE.  So back to reading the code.

No, you were correct and thanks for the hint. It's only ISOLATE_UNEVICTABLE from
isolate_migratepages_range(), which is CMA, not regular compaction.
But I wonder, can we change this even after VM_PINNED is introduced, if existing
code depends on "no minor faults in mlocked areas", whatever the docs say? On
the other hand, compaction is not the only source of migrations. I wonder what
the NUMA balancing does (not) about mlocked areas...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
