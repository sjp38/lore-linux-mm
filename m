Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE00F6B2EB5
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:36:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d47-v6so3358830edb.3
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:36:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42-v6si340522edb.410.2018.08.24.01.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 01:36:34 -0700 (PDT)
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
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
Date: Fri, 24 Aug 2018 10:36:33 +0200
MIME-Version: 1.0
In-Reply-To: <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On 08/24/2018 10:11 AM, Marinko Catovic wrote:
>     1. Send the current value of /sys/kernel/mm/transparent_hugepage/defrag
>     2. Unless it's 'defer' or 'never' already, try changing it to 'defer'.
> 
> 
> A /sys/kernel/mm/transparent_hugepage/defrag is
> always defer defer+madvise [madvise] never

Yeah that's the default.

> I *think* I already played around with these values, as far as I
> remember `never`
> almost caused the system to hang, or at least while I switched back to
> madvise.

That would be unexpected for the 'defrag' file, but maybe possible for
'enabled' file where mm structs are put on/removed from a list
system-wide, AFAIK.

> shall I switch it to defer and observe (all hosts are running fine by
> just now) or
> switch to defer while it is in the bad state?

You could do it immediately and see if no problems appear for long
enough, OTOH...

> and when doing this, should improvement be measurable immediately?

I would expect that. It would be a more direct proof that that was the
cause.

> I need to know how long to hold this, before dropping caches becomes
> necessary.

If it keeps oscillating and doesn't start growing, it means it didn't
help. Few minutes should be enough.

>> Ah, checked the trace and it seems to be "php-cgi". Interesting that
>> they use madvise(MADV_HUGEPAGE). Anyway the above still applies.
> 
> you know, that's at least an interesting hint. look at this:
> https://ckon.wordpress.com/2015/09/18/php7-opcache-performance/
> 
> this was experimental there, but a more recent version seems to have it on
> by default, since I need to disable it on request (implies to me that it
> is on by default).
> it is however *disabled* in the runtime configuration (and not in
> effect, I just confirmed that)
> 
> It would be interesting to know whether madvise(MADV_HUGEPAGE) is then
> active
> somewhere else, since it is in the dump as you observed.

The trace points to php-cgi so either disabling it doesn't work, or they
started using the madvise also for other stuff than opcache. But that
doesn't matter, it would be kernel's fault if a program using the
madvise would effectively kill the system like this. Let's just stick
with the global 'defrag'='defer' change and not tweak several things at
once.

> Please note that `killing` php-cgi would not make any difference then,
> since these processes
> are started by request for every user and killed after whatever script
> is finished. this may
> invoke about 10-50 forks, depending on load, (with different system
> users) every second.

Yep.
