Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA26B6B2E3D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:34:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q29-v6so3243735edd.0
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 23:34:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c15-v6si60868edf.218.2018.08.23.23.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 23:34:45 -0700 (PDT)
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
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
Date: Fri, 24 Aug 2018 08:34:44 +0200
MIME-Version: 1.0
In-Reply-To: <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>, Michal Hocko <mhocko@suse.com>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On 08/24/2018 02:11 AM, Marinko Catovic wrote:
>> Hmm it's actually interesting to see GFP_TRANSHUGE there and not
>> GFP_TRANSHUGE_LIGHT. What's your thp defrag setting? (cat
>> /sys/kernel/mm/transparent_hugepage/enabled). Maybe it's set to
>> "always", or there's a heavily faulting process that's using
>> madvise(MADV_HUGEPAGE). If that's the case, setting it to "defer" or
>> even "never" could be a workaround.
> 
> cat /sys/kernel/mm/transparent_hugepage/enabled
> always [madvise] never

Hmm my mistake. I was actually interested in
/sys/kernel/mm/transparent_hugepage/defrag

> according to the docs this is the default
>> "madvise" will enter direct reclaim like "always" but only for regions
>> that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.

Yeah but that's about 'defrag'. For 'enabled', the default should be
always. But it's a kernel config option I think? Let's see what you have
for 'defrag'...

> would any change there kick in immediately, even when in the 100M/10G case?

If it's indeed preventing the cache from growing back, changing that
should result in gradual increase. Note that it doesn't look probable
that THP is the cause, but the trace didn't contain any other
allocations that could be responsible for high-order direct reclaim.

>> or there's a heavily faulting process that's using madvise(MADV_HUGEPAGE)
> 
> are you suggesting that a/one process can cause this?
> how would one be able to identify it..? should killing it allow the
> cache to be
> populated again instantly? if yes, then I could start killing all
> processes on the
> host until there is improvement to observe.

It's not the process' fault, and killing it might disrupt the
observation in unexpected ways. It's simpler to change the global
setting to "never" to confirm or rule out this.

Ah, checked the trace and it seems to be "php-cgi". Interesting that
they use madvise(MADV_HUGEPAGE). Anyway the above still applies.

> so far I can tell that it is not the database server, since restarting
> it did not help at all.
> 
> Please remember that, suggesting this, I can see how buffers (the 100MB
> value)
> are `oscillating`. When in the cache-useless state it jumps around
> literally every second
> from e.g. 100 to 102, then 99, 104, 85, 101, 105, 98, .. and so on,
> where it always gets
> closer from well-populated several GB in the beginning to those 100MB
> over the days.
> so doing anything that should cause an effect would be easily measurable
> instantly,
> which is to date only achieved by dropping caches.
> 
> Please tell me if you need any measurements again, when or at what
> state, with code
> snippets perhaps to fit your needs.

1. Send the current value of /sys/kernel/mm/transparent_hugepage/defrag
2. Unless it's 'defer' or 'never' already, try changing it to 'defer'.

Thanks.
