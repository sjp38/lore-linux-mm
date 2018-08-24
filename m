Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C342B6B2E33
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:24:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g11-v6so3097741edi.8
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 23:24:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25-v6si1642583edf.84.2018.08.23.23.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 23:24:43 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz>
 <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz>
 <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz>
 <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
 <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz>
 <20180823122111.GG29735@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3675b21b-8d67-3a67-fd1e-fc0b92a81ce8@suse.cz>
Date: Fri, 24 Aug 2018 08:24:41 +0200
MIME-Version: 1.0
In-Reply-To: <20180823122111.GG29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On 08/23/2018 02:21 PM, Michal Hocko wrote:
> On Thu 23-08-18 14:10:28, Vlastimil Babka wrote:
>> It also shows that all orders except order-9 are in fact plentiful.
>> Michal's earlier summary of the trace shows that most allocations are up
>> to order-3 and should be fine, the exception is THP:
>>
>>     277 9 GFP_TRANSHUGE|__GFP_THISNODE
> 
> But please note that this is not from the time when the page cache
> dropped to the observed values. So we do not know what happened at the
> time.

Okay, we didn't observe it drop, but there must still be something going
on that keeps it from growing back?

> Anyway 277 THP pages paging out such a large page cache amount would be
> more than unexpected even for explicitly costly THP fault in methods.

It's 277 in 90 seconds. But it seems no reclaim should happen there
anyway, because shrink_zones() should evaluate compaction_ready() as
true and skip the zones. Unless there is some kind of bug, maybe e.g.
ZONE_DMA returns compaction_ready() as false, causing the whole node to
be reclaimed? Hmm.
