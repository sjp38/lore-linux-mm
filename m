Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6908E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:58:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so12556781edb.22
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:58:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h88si1747735edc.299.2018.12.18.05.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 05:58:34 -0800 (PST)
Subject: Re: [PATCH 09/14] mm, compaction: Ignore the fragmentation avoidance
 boost for isolation and compaction
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-10-mgorman@techsingularity.net>
 <f8aeec16-65de-b873-3362-3c7cb30c4ac6@suse.cz>
 <20181218135156.GK29005@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <adae728e-0e62-abb3-901e-0696930bb7dd@suse.cz>
Date: Tue, 18 Dec 2018 14:58:33 +0100
MIME-Version: 1.0
In-Reply-To: <20181218135156.GK29005@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/18/18 2:51 PM, Mel Gorman wrote:
> On Tue, Dec 18, 2018 at 01:36:42PM +0100, Vlastimil Babka wrote:
>> On 12/15/18 12:03 AM, Mel Gorman wrote:
>>> When pageblocks get fragmented, watermarks are artifically boosted to pages
>>> are reclaimed to avoid further fragmentation events. However, compaction
>>> is often either fragmentation-neutral or moving movable pages away from
>>> unmovable/reclaimable pages. As the actual watermarks are preserved,
>>> allow compaction to ignore the boost factor.
>>
>> Right, I should have realized that when reviewing the boost patch. I
>> think it would be useful to do the same change in
>> __compaction_suitable() as well. Compaction has its own "gap".
>>
> 
> That gap is somewhat static though so I'm a bit more wary of it. However,

Well, watermark boost is dynamic, but based on allocations stealing from
other migratetypes, not reflecting compaction chances of success.

> the check in __isolate_free_page looks too agressive. We isolate in
> units of COMPACT_CLUSTER_MAX yet the watermark check there is based on
> the allocation request. That means for THP that we check if 512 pages
> can be allocated when only somewhere between 1 and 32 is needed for that
> compaction cycle to complete. Adjusting that might be more appropriate?

AFAIU the code in __isolate_free_page() reflects that if there's less
than 512 free pages gap, we might form a high-order page for THP but
won't be able to allocate it afterwards due to watermark.
