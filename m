Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1976B0269
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 19:50:25 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so11789606pgt.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:50:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z14si9065207pga.349.2018.11.14.16.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 16:50:24 -0800 (PST)
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <20181114150742.GZ23419@dhcp22.suse.cz>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <9e8218eb-80bf-fc02-ae56-42ccfddb572e@linux.intel.com>
Date: Wed, 14 Nov 2018 16:50:23 -0800
MIME-Version: 1.0
In-Reply-To: <20181114150742.GZ23419@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com



On 11/14/2018 7:07 AM, Michal Hocko wrote:
> On Mon 05-11-18 13:19:25, Alexander Duyck wrote:
>> This patchset is essentially a refactor of the page initialization logic
>> that is meant to provide for better code reuse while providing a
>> significant improvement in deferred page initialization performance.
>>
>> In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
>> memory per node I have seen the following. In the case of regular memory
>> initialization the deferred init time was decreased from 3.75s to 1.06s on
>> average. For the persistent memory the initialization time dropped from
>> 24.17s to 19.12s on average. This amounts to a 253% improvement for the
>> deferred memory initialization performance, and a 26% improvement in the
>> persistent memory initialization performance.
>>
>> I have called out the improvement observed with each patch.
> 
> I have only glanced through the code (there is a lot of the code to look
> at here). And I do not like the code duplication and the way how you
> make the hotplug special. There shouldn't be any real reason for that
> IMHO (e.g. why do we init pfn-at-a-time in early init while we do
> pageblock-at-a-time for hotplug). I might be wrong here and the code
> reuse might be really hard to achieve though.

Actually it isn't so much that hotplug is special. The issue is more 
that the non-hotplug case is special in that you have to perform a 
number of extra checks for things that just aren't necessary for the 
hotplug case.

If anything I would probably need a new iterator that would be able to 
take into account all the checks for the non-hotplug case and then 
provide ranges of PFNs to initialize.

> I am also not impressed by new iterators because this api is quite
> complex already. But this is mostly a detail.

Yeah, the iterators were mostly an attempt at hiding some of the 
complexity. Being able to break a loop down to just an iterator provding 
the start of the range and the number of elements to initialize is 
pretty easy to visualize, or at least I thought so.

> Thing I do not like is that you keep microptimizing PageReserved part
> while there shouldn't be anything fundamental about it. We should just
> remove it rather than make the code more complex. I fell more and more
> guilty to add there actually.

I plan to remove it, but don't think I can get to it in this patch set.

I was planning to submit one more iteration of this patch set early next 
week, and then start focusing more on the removal of the PageReserved 
bit for hotplug. I figure it is probably going to be a full patch set 
onto itself and as you pointed out at the start of this email there is 
already enough code to review without adding that.
