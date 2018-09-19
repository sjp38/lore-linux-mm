Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9B18E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 21:18:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e15-v6so1892787pfi.5
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 18:18:28 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 29-v6si20644314pgv.292.2018.09.18.18.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 18:18:27 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 19 Sep 2018 06:48:25 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [RFC] memory_hotplug: Free pages as pageblock_order
In-Reply-To: <20180914091053.GJ20287@dhcp22.suse.cz>
References: <1536744405-16752-1-git-send-email-arunks@codeaurora.org>
 <20180912103853.GC10951@dhcp22.suse.cz> <20180912125743.GB8537@350D>
 <20180912131724.GH10951@dhcp22.suse.cz>
 <9d8dfd50046036a7b4e730738940014d@codeaurora.org>
 <20180914091053.GJ20287@dhcp22.suse.cz>
Message-ID: <28e613e9a092a434cfa9b38f7b0f8eea@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, gregkh@linuxfoundation.org, yasu.isimatu@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, arunks.linux@gmail.com, vinmenon@codeaurora.org

On 2018-09-14 14:40, Michal Hocko wrote:
> On Wed 12-09-18 20:12:30, Arun KS wrote:
>> On 2018-09-12 18:47, Michal Hocko wrote:
>> > On Wed 12-09-18 22:57:43, Balbir Singh wrote:
>> > > On Wed, Sep 12, 2018 at 12:38:53PM +0200, Michal Hocko wrote:
>> > > > On Wed 12-09-18 14:56:45, Arun KS wrote:
>> > > > > When free pages are done with pageblock_order, time spend on
>> > > > > coalescing pages by buddy allocator can be reduced. With
>> > > > > section size of 256MB, hot add latency of a single section
>> > > > > shows improvement from 50-60 ms to less than 1 ms, hence
>> > > > > improving the hot add latency by 60%.
>> > > >
>> > > > Where does the improvement come from? You are still doing the same
>> > > > amount of work except that the number of callbacks is lower. Is this the
>> > > > real source of 60% improvement?
>> > > >
>> > >
>> > > It looks like only the first page of the pageblock is initialized, is
>> > > some of the cost amortized in terms of doing one initialization for
>> > > the page with order (order) and then relying on split_page and helpers
>> > > to do the rest? Of course the number of callbacks reduce by a
>> > > significant
>> > > number as well.
>> >
>> > Ohh, I have missed that part. Now when re-reading I can see the reason
>> > for the perf improvement. It is most likely the higher order free which
>> > ends up being much cheaper. This part makes some sense.
>> >
>> > How much is this feasible is another question. Do not forget we have
>> > those external providers of the online callback and those would need to
>> > be updated as well.
>> Sure Michal, I ll look into this.
>> 
>> >
>> > Btw. the normal memmap init code path does the same per-page free as
>> > well. If we really want to speed the hotplug path then I guess the init
>> > one would see a bigger improvement and those two should be in sync.
>> Thanks for pointers, Will look further.
> 
> I haven't looked closer and I will be travelling next week so just 
> hint.
> Have a look at the nobootmem and how it frees pages to the page
> allocator in __free_pages_boot_core. Seems exactly what you want and it
> also answers your question about reference counting.

Thanks Michal. Will send a new version after testing.

Regards,
Arun
