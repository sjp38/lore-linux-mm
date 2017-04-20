Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2B9B2806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:49:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 184so1854431wmy.18
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:49:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e21si8048057wrc.164.2017.04.20.01.49.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 01:49:38 -0700 (PDT)
Date: Thu, 20 Apr 2017 10:49:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170420084930.GC15781@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
 <20170420072820.GB15781@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170420072820.GB15781@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-04-17 09:28:20, Michal Hocko wrote:
> On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
[...]
> > Your patch try to add PageReserved() to __pageblock_pfn_to_page(). It
> > woule make that zone->contiguous usually returns false since memory
> > used by memblock API is marked as PageReserved() and your patch regard
> > it as a hole. It invalidates set_zone_contiguous() optimization and I
> > worry about it.
> 
> OK, fair enough. I did't consider memblock allocations. I will rethink
> this patch but there are essentially 3 options
> 	- use a different criterion for the offline holes dection. I
> 	  have just realized we might do it by storing the online
> 	  information into the mem sections
> 	- drop this patch
> 	- move the PageReferenced check down the chain into
> 	  isolate_freepages_block resp. isolate_migratepages_block
> 
> I would prefer 3 over 2 over 1. I definitely want to make this more
> robust so 1 is preferable long term but I do not want this to be a
> roadblock to the rest of the rework. Does that sound acceptable to you?

So I've played with all three options just to see how the outcome would
look like and it turned out that going with 1 will be easiest in the
end. What do you think about the following? It should be free of any 
false positives. I have only compile tested it yet.
---
