Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 967BE6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:15:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so2063313edi.20
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 04:15:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13-v6si1482035edk.422.2018.07.27.04.15.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 04:15:34 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz>
 <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz>
 <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz>
 <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
Date: Fri, 27 Jul 2018 13:15:33 +0200
MIME-Version: 1.0
In-Reply-To: <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>, linux-mm@kvack.org

On 07/21/2018 12:03 AM, Marinko Catovic wrote:
> I let this run for 3 days now, so it is quite a lot, there you go:
> https://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz

The stats show that compaction has very bad results. Between first and
last snapshot, compact_fail grew by 80k and compact_success by 1300.
High-order allocations will thus cycle between (failing) compaction and
reclaim that removes the buffer/caches from memory.

Since dropping slab caches helps, I suspect it's either the slab pages
(which cannot be migrated for compaction) being spread over all memory,
making it impossible to assemble high-order pages, or some slab objects
are pinning file pages making them also impossible to be migrated.

> There is one thing I forgot to mention: the hosts perform find and du (I
> mean the commands, finding files and disk usage)
> on the HDDs every night, starting from 00:20 AM up until in the morning
> 07:45 AM, for maintenance and stats.
> 
> During this period the buffers/caches raise again as you may see from
> the logs, so find/du do fill them.
> Nevertheless as the day passes both decrease again until low values are
> reached.
> I disabled find/du for the night on 19->20th July to compare.
> 
> I have to say that this really low usage (300MB/xGB) occured just once
> after I upgraded from 4.16 to 4.17, not sure
> why, where one can still see from the logs that the buffers/cache is not
> using up the entire available RAM.
> 
> This low usage occured the last time on that one host when I mentioned
> that I had to 2>drop_caches again in my
> previous message, so this is still an issue even on the latest kernel.
> 
> The other host (the one that was not measured with the vmstat logs) has
> currently 600MB/14GB, 34GB of free RAM.
> Both were reset with drop_caches at the same time. From the looks of
> this the really low usage will occur again
> somewhat shortly, it just did not come up during measurement. However,
> the RAM should be full anyway, true?

Can you provide (a single snapshot) /proc/pagetypeinfo and
/proc/slabinfo from a system that's currently experiencing the issue,
also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.
