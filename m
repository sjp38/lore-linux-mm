Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7BF36B03A2
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 07:59:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l44so2193606wrc.11
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 04:59:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si3733322wmx.83.2017.04.19.04.59.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 04:59:42 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: consider zone which is not fully populated to
 have holes
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170415121734.6692-2-mhocko@kernel.org>
 <97a658cd-e656-6efa-7725-150063d276f1@suse.cz>
 <20170418092757.GM22360@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <12814e7e-5ed7-de1f-3e7c-9501eec1682a@suse.cz>
Date: Wed, 19 Apr 2017 13:59:40 +0200
MIME-Version: 1.0
In-Reply-To: <20170418092757.GM22360@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 04/18/2017 11:27 AM, Michal Hocko wrote:
> On Tue 18-04-17 10:45:23, Vlastimil Babka wrote:
>> On 04/15/2017 02:17 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>
>> My issue with this is that PageReserved can be also set for other
>> reasons than offlined block, e.g. by a random driver. So there are two
>> suboptimal scenarios:
>>
>> - PageReserved is set on some page in the middle of pageblock. It won't
>> be detected by this patch. This violates the "it would be safer" argument.
>> - PageReserved is set on just the first (few) page(s) and because of
>> this patch, we skip it completely and won't compact the rest of it.
> 
> Why would that be a big problem? PageReserved is used only very seldom
> and few page blocks skipped would seem like a minor issue to me.

Yes it's not critical, just suboptimal. Can be improved later.

>> So if we decide we really need to check PageReserved to ensure safety,
>> then we have to check it on each page. But I hope the existing criteria
>> in compaction scanners are sufficient. Unless the semantic is that if
>> somebody sets PageReserved, he's free to repurpose the rest of flags at
>> his will (IMHO that's not the case).
> 
> I am not aware of any such user. PageReserved has always been about "the
> core mm should touch these pages and modify their state" AFAIR.
> But I believe that touching those holes just asks for problems so I
> would rather have them covered.

OK. I guess it's OK to use PageReserved of first pageblock page to
determine if we can trust page_zone(), because the memory offline
scenario should have sufficient granularity and not make holes inside
pageblock?

>> The pageblock-level check them becomes a performance optimization so
>> when there's an "offline hole", compaction won't iterate it page by
>> page. But the downside is the false positive resulting in skipping whole
>> pageblock due to single page.
>> I guess it's uncommon for a longlived offline holes to exist, so we
>> could simply just drop this?
> 
> This is hard to tell but I can imagine that some memory hotplug
> balloning drivers might want to offline hole into existing zones.

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
