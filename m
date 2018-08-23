Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 413146B29F7
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:10:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f8-v6so2224946eds.6
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:10:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20-v6si3726304ede.252.2018.08.23.05.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 05:10:29 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
 <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
 <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz>
 <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz>
 <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz>
 <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
 <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz>
Date: Thu, 23 Aug 2018 14:10:28 +0200
MIME-Version: 1.0
In-Reply-To: <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On 08/22/2018 10:02 PM, Marinko Catovic wrote:
>> It might be also interesting to do in the problematic state, instead of
>> dropping caches:
>>
>> - save snapshot of /proc/vmstat and /proc/pagetypeinfo
>> - echo 1 > /proc/sys/vm/compact_memory
>> - save new snapshot of /proc/vmstat and /proc/pagetypeinfo
> 
> There was just a worstcase in progress, about 100MB/10GB were used,
> super-low perfomance, but could not see any improvement there after echo 1,
> I watches this for about 3 minutes, the cache usage did not change.
> 
> pagetypeinfo before echo https://pastebin.com/MjSgiMRL
> pagetypeinfo 3min after echo https://pastebin.com/uWM6xGDd
> 
> vmstat before echo https://pastebin.com/TjYSKNdE
> vmstat 3min after echo https://pastebin.com/MqTibEKi

OK, that confirms compaction is useless here. Thanks.

It also shows that all orders except order-9 are in fact plentiful.
Michal's earlier summary of the trace shows that most allocations are up
to order-3 and should be fine, the exception is THP:

    277 9 GFP_TRANSHUGE|__GFP_THISNODE

Hmm it's actually interesting to see GFP_TRANSHUGE there and not
GFP_TRANSHUGE_LIGHT. What's your thp defrag setting? (cat
/sys/kernel/mm/transparent_hugepage/enabled). Maybe it's set to
"always", or there's a heavily faulting process that's using
madvise(MADV_HUGEPAGE). If that's the case, setting it to "defer" or
even "never" could be a workaround.
