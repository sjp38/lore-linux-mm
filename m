Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 405C86B2A06
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:21:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c8-v6so3124102pfn.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:21:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b129-v6si4580888pfa.12.2018.08.23.05.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 05:21:13 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:21:11 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180823122111.GG29735@dhcp22.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On Thu 23-08-18 14:10:28, Vlastimil Babka wrote:
> On 08/22/2018 10:02 PM, Marinko Catovic wrote:
> >> It might be also interesting to do in the problematic state, instead of
> >> dropping caches:
> >>
> >> - save snapshot of /proc/vmstat and /proc/pagetypeinfo
> >> - echo 1 > /proc/sys/vm/compact_memory
> >> - save new snapshot of /proc/vmstat and /proc/pagetypeinfo
> > 
> > There was just a worstcase in progress, about 100MB/10GB were used,
> > super-low perfomance, but could not see any improvement there after echo 1,
> > I watches this for about 3 minutes, the cache usage did not change.
> > 
> > pagetypeinfo before echo https://pastebin.com/MjSgiMRL
> > pagetypeinfo 3min after echo https://pastebin.com/uWM6xGDd
> > 
> > vmstat before echo https://pastebin.com/TjYSKNdE
> > vmstat 3min after echo https://pastebin.com/MqTibEKi
> 
> OK, that confirms compaction is useless here. Thanks.
> 
> It also shows that all orders except order-9 are in fact plentiful.
> Michal's earlier summary of the trace shows that most allocations are up
> to order-3 and should be fine, the exception is THP:
> 
>     277 9 GFP_TRANSHUGE|__GFP_THISNODE

But please note that this is not from the time when the page cache
dropped to the observed values. So we do not know what happened at the
time.

Anyway 277 THP pages paging out such a large page cache amount would be
more than unexpected even for explicitly costly THP fault in methods.
-- 
Michal Hocko
SUSE Labs
