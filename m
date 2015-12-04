Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id BF4CD6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 07:34:14 -0500 (EST)
Received: by lbbed20 with SMTP id ed20so5247164lbb.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 04:34:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si8334610lfc.218.2015.12.04.04.34.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 04:34:13 -0800 (PST)
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
 <20151203092525.GA20945@aaronlu.sh.intel.com> <56600DAA.4050208@suse.cz>
 <20151203113508.GA23780@aaronlu.sh.intel.com>
 <20151203115255.GA24773@aaronlu.sh.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56618841.2080808@suse.cz>
Date: Fri, 4 Dec 2015 13:34:09 +0100
MIME-Version: 1.0
In-Reply-To: <20151203115255.GA24773@aaronlu.sh.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On 12/03/2015 12:52 PM, Aaron Lu wrote:
> On Thu, Dec 03, 2015 at 07:35:08PM +0800, Aaron Lu wrote:
>> On Thu, Dec 03, 2015 at 10:38:50AM +0100, Vlastimil Babka wrote:
>>> On 12/03/2015 10:25 AM, Aaron Lu wrote:
>>>> On Thu, Dec 03, 2015 at 09:10:44AM +0100, Vlastimil Babka wrote:
>>
>> My bad, I uploaded the wrong data :-/
>> I uploaded again:
>> https://drive.google.com/file/d/0B49uX3igf4K4UFI4TEQ3THYta0E
>>
>> And I just run the base tree with trace-cmd and found that its
>> performace drops significantly(from 1000MB/s to 6xxMB/s), is it that
>> trace-cmd will impact performace a lot?

Yeah it has some overhead depending on how many events it has to 
process. Your workload is quite sensitive to that.

>> Any suggestions on how to run
>> the test regarding trace-cmd? i.e. should I aways run usemem under
>> trace-cmd or only when necessary?

I'd run it with tracing only when the goal is to collect traces, but not 
for any performance comparisons. Also it's not useful to collect perf 
data while also tracing.

> I just run the test with the base tree and with this patch series
> applied(head), I didn't use trace-cmd this time.
>
> The throughput for base tree is 963MB/s while the head is 815MB/s, I
> have attached pagetypeinfo/proc-vmstat/perf-profile for them.

The compact stats improvements look fine, perhaps better than in my tests:

base: compact_migrate_scanned 3476360
head: compact_migrate_scanned 1020827

- that's the eager skipping of patch 2

base: compact_free_scanned 5924928
head: compact_free_scanned 0
       compact_free_direct 918813
       compact_free_direct_miss 500308

As your workload does exclusively async direct compaction through THP 
faults, the traditional free scanner isn't used at all. Direct 
allocations should be much cheaper, although the "miss" ratio (the 
allocations that were from the same pageblock as the one we are 
compacting) is quite high. I should probably look into making migration 
release pages to the tails of the freelists - could be that it's 
grabbing the very pages that were just freed in the previous 
COMPACT_CLUSTER_MAX cycle (modulo pcplist buffering).

I however find it strange that your original stats (4.3?) differ from 
the base so much:

compact_migrate_scanned 1982396
compact_free_scanned 40576943

That was order of magnitude more free scanned on 4.3, and half the 
migrate scanned. But your throughput figures in the other mail suggested 
a regression from 4.3 to 4.4, which would be the opposite of what the 
stats say. And anyway, compaction code didn't change between 4.3 and 4.4 
except changes to tracepoint format...

moving on...
base:
compact_isolated 731304
compact_stall 10561
compact_fail 9459
compact_success 1102

head:
compact_isolated 921087
compact_stall 14451
compact_fail 12550
compact_success 1901

More success in both isolation and compaction results.

base:
thp_fault_alloc 45337
thp_fault_fallback 2349

head:
thp_fault_alloc 45564
thp_fault_fallback 2120

Somehow the extra compact success didn't fully translate to thp alloc 
success... But given how many of the alloc's didn't even involve a 
compact_stall (two thirds of them), that interpretation could also be 
easily misleading. So, hard to say.

Looking at the perf profiles...
base:
     54.55%    54.55%            :1550  [kernel.kallsyms]   [k] 
pageblock_pfn_to_page

head:
     40.13%    40.13%            :1551  [kernel.kallsyms]   [k] 
pageblock_pfn_to_page

Since the freepage allocation doesn't hit this code anymore, it shows 
that the bulk was actually from the migration scanner, although the perf 
callgraph and vmstats suggested otherwise. However, vmstats count only 
when the scanner actually enters the pageblock, and there are numerous 
reasons why it wouldn't... For example the pageblock_skip bitmap. Could 
it make sense to look at the bitmap before doing the pfn_to_page 
translation?

I don't see much else in the profiles. I guess the remaining problem of 
compaction here is that deferring compaction doesn't trigger for async 
compaction, and this testcase doesn't hit sync compaction at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
