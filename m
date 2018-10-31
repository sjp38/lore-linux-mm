Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72D8D6B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:15:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k17-v6so10796436edr.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:15:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2-v6si1048362edj.197.2018.10.31.06.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:15:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: Caching/buffers become useless after some time
References: <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz>
 <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
Message-ID: <0a7f039d-0077-9559-cd12-64559b2e43ab@suse.cz>
Date: Wed, 31 Oct 2018 14:12:24 +0100
MIME-Version: 1.0
In-Reply-To: <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

Resending for lists which dropped my mail due to attachments. Sorry.
plots: https://nofile.io/f/ogwbrwhwBU7/plots.tar.bz2
R script:


files <- Sys.glob("vmstat.1*")

results <- read.table(files[1], row.names=1)

for (file in files[-1]) {
	tmp2 <- read.table(file)$V2
	results <- cbind(results, tmp2)
}

for (row in row.names(results)) {
	png(paste("plots/", row, ".png", sep=""), width=1900, height=1150)
	plot(t(as.vector(results[row,])), main=row)
	dev.off()
}

On 10/22/18 3:19 AM, Marinko Catovic wrote:
> Am Mi., 29. Aug. 2018 um 18:44 Uhr schrieb Marinko Catovic
> <marinko.catovic@gmail.com>:
>>
>>
>>>> one host is at a healthy state right now, I'd run that over there immediately.
>>>
>>> Let's see what we can get from here.
>>
>>
>> oh well, that went fast. actually with having low values for buffers (around 100MB) with caches
>> around 20G or so, the performance was nevertheless super-low, I really had to drop
>> the caches right now. This is the first time I see it with caches >10G happening, but hopefully
>> this also provides a clue for you.
>>
>> Just after starting the stats I reset from previously defer to madvise - I suspect that this somehow
>> caused the rapid reaction, since a few minutes later I saw that the free RAM jumped from 5GB to 10GB,
>> after that I went afk, returning to the pc since my monitoring systems went crazy telling me about downtime.
>>
>> If you think changing /sys/kernel/mm/transparent_hugepage/defrag back to its default, while it was
>> on defer now for days, was a mistake, then please tell me.
>>
>> here you go: https://nofile.io/f/VqRg644AT01/vmstat.tar.gz
>> trace_pipe: https://nofile.io/f/wFShvZScpvn/trace_pipe.gz
>>
> 
> There we go again.
> 
> First of all, I have set up this monitoring on 1 host, as a matter of
> fact it did not occur on that single
> one for days and weeks now, so I set this up again on all the hosts
> and it just happened again on another one.
> 
> This issue is far from over, even when upgrading to the latest 4.18.12
> 
> https://nofile.io/f/z2KeNwJSMDj/vmstat-2.zip
> https://nofile.io/f/5ezPUkFWtnx/trace_pipe-2.gz

I have plot the vmstat using the attached script, and got the attached
plots. X axis are the vmstat snapshots, almost 14k of them, each for 5
seconds, so almost 19 hours. I can see the following phases:

0 - 2000:
- free memory (nr_free_pages) dropping from 48GB to the minimum allowed
by watermarks
- page cache (nr_file_pages) grows correspondingly

2000 - 6000:
- reclaimable slab (nr_slab_reclaimable) grows up to 40GB, unreclaimable
slab has same trend but much less
- page cache is shrinked correspondingly
- free memory remains at miminum

6000 - 12000:
- slab usage is slowly declining
- page cache slowly growing but there are hiccups
- free pages at minimum, growing after 9000, oscillating between 10000
and 12000

12000 - end:
- free pages growing sharply
- page cache declining sharply
- slab still slowly declining

I guess the original problem is manifested in the last phase. There
might be secondary issue with the slab usage, between 2000 and 6000 but
it doesn't seem immeidately connected (?).

I can see compaction activity (but not success) increased a lot in the
last phase, while direct reclaim is steady from 2000 onwards. This would
again suggest high-order allocations. THP doesn't seem to be the cause.

Vlastimil
