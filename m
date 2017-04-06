Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B84ED6B03F0
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 02:39:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n5so27074719pgd.19
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 23:39:24 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p16si852032pfi.88.2017.04.05.23.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 23:39:23 -0700 (PDT)
Subject: Re: [PATCH 4/4] mtd: nand: nandsim: convert to memalloc_noreclaim_*()
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-5-vbabka@suse.cz>
 <20170405113157.GM6035@dhcp22.suse.cz>
 <ee6649ed-b0e8-1c59-c193-d1688fdfe7f5@nod.at>
 <9b9d5bca-e125-e07b-b700-196cc800bbd7@suse.cz>
From: Adrian Hunter <adrian.hunter@intel.com>
Message-ID: <fe1c21a4-0bc6-529c-5446-382b01d4c99e@intel.com>
Date: Thu, 6 Apr 2017 09:33:44 +0300
MIME-Version: 1.0
In-Reply-To: <9b9d5bca-e125-e07b-b700-196cc800bbd7@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Richard Weinberger <richard@nod.at>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>

On 05/04/17 14:39, Vlastimil Babka wrote:
> On 04/05/2017 01:36 PM, Richard Weinberger wrote:
>> Michal,
>>
>> Am 05.04.2017 um 13:31 schrieb Michal Hocko:
>>> On Wed 05-04-17 09:47:00, Vlastimil Babka wrote:
>>>> Nandsim has own functions set_memalloc() and clear_memalloc() for robust
>>>> setting and clearing of PF_MEMALLOC. Replace them by the new generic helpers.
>>>> No functional change.
>>>
>>> This one smells like an abuser. Why the hell should read/write path
>>> touch memory reserves at all!
>>
>> Could be. Let's ask Adrian, AFAIK he wrote that code.
>> Adrian, can you please clarify why nandsim needs to play with PF_MEMALLOC?
> 
> I was thinking about it and concluded that since the simulator can be
> used as a block device where reclaimed pages go to, writing the data out
> is a memalloc operation. Then reading can be called as part of r-m-w
> cycle, so reading as well.

IIRC it was to avoid getting stuck with nandsim waiting on memory reclaim
and memory reclaim waiting on nandsim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
