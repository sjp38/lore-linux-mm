Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 047E56B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:02:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so52890361lfi.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:02:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n24si3693230wmi.20.2016.07.21.07.02.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 07:02:07 -0700 (PDT)
Subject: Re: [Bug 64121] New: [BISECTED] "mm" performance regression updating
 from 3.2 to 3.3
References: <bug-64121-27@https.bugzilla.kernel.org/>
 <20131031134610.30d4c0e98e58fb0484e988c1@linux-foundation.org>
 <20131101184332.GF707@cmpxchg.org>
 <b4aff3a2-cc22-c68c-cafc-96db332f86c3@intra2net.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b3219832-110d-2b74-5ba9-694ab30589f0@suse.cz>
Date: Thu, 21 Jul 2016 16:02:06 +0200
MIME-Version: 1.0
In-Reply-To: <b4aff3a2-cc22-c68c-cafc-96db332f86c3@intra2net.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 07/19/2016 12:23 AM, Thomas Jarosch wrote:
> Hi Johannes,
>
> referring to an old kernel bugzilla issue:
> https://bugzilla.kernel.org/show_bug.cgi?id=64121
>
> Am 01.11.2013 um 19:43 wrote Johannes Weiner:
>> It is a combination of two separate things on these setups.
>>
>> Traditionally, only lowmem is considered dirtyable so that dirty pages
>> don't scale with highmem and the kernel doesn't overburden itself with
>> lowmem pressure from buffers etc.  This is purely about accounting.
>>
>> My patches on the other hand were about dirty page placement and
>> avoiding writeback from page reclaim: by subtracting the watermark and
>> the lowmem reserve (memory not available for user memory / cache) from
>> each zone's dirtyable memory, we make sure that the zone can always be
>> rebalanced without writeback.
>>
>> The problem now is that the lowmem reserves scale with highmem and
>> there is a point where they entirely overshadow the Normal zone.  This
>> means that no page cache at all is allowed in lowmem.  Combine this
>> with how dirtyable memory excludes highmem, and the sum of all
>> dirtyable memory is nil.  This effectively disables the writeback
>> cache.
>>
>> I figure if anything should be fixed it should be the full exclusion
>> of highmem from dirtyable memory and find a better way to calculate a
>> minimum.
>
> recently we've updated our production mail server from 3.14.69
> to 3.14.73 and it worked fine for a few days. When the box is really
> busy (=incoming malware via email), the I/O speed drops to crawl,
> write speed is about 5 MB/s on Intel SSDs. Yikes.
>
> The box has 16GB RAM, so it should be a safe HIGHMEM configuration.
>
> Downgrading to 3.14.69 or booting with "mem=15000M" works. I've tested
> both approaches and the box was stable. Booting 3.14.73 again triggered
> the problem within minutes.
>
> Clearly something with the automatic calculation of the lowmem reserve
> crossed a tipping point again, even with the previously considered safe
> amount of 16GB RAM for HIGHMEM configs. I don't see anything obvious in
> the changelogs from 3.14.69 to 3.14.73, but I might have missed it.

I don't see anything either, might be some change e.g. under fs/ though. 
How about git bisect?

>> HOWEVER,
>>
>> the lowmem reserve is highmem/32 per default.  With a Normal zone of
>> around 900M, this requires 28G+ worth of HighMem to eclipse lowmem
>> entirely.  This is almost double of what you consider still okay...
>
> is there a way to read out the calculated lowmem reserve via /proc?

Probably not, but might be possible with live crash session.

> It might be interesting the see the lowmem reserve
> when booted with mem=15000M or kernel 3.14.69 for comparison.
>
> Do you think it might be worth tinkering with "lowmem_reserve_ratio"?
>
>
> /proc/meminfo from the box using "mem=15000M" + kernel 3.14.73:
>
> MemTotal:       15001512 kB
> HighTotal:      14219160 kB
> HighFree:        9468936 kB
> LowTotal:         782352 kB
> LowFree:          117696 kB
> Slab:             430612 kB
> SReclaimable:     416752 kB
> SUnreclaim:        13860 kB
>
>
> /proc/meminfo from a similar machine with 16GB RAM + kernel 3.14.73:
> (though that machine is just a firewall, so no real disk I/O)
>
> MemTotal:       16407652 kB
> HighTotal:      15636376 kB
> HighFree:       14415472 kB
> LowTotal:         771276 kB
> LowFree:          562852 kB
> Slab:              34712 kB
> SReclaimable:      20888 kB
> SUnreclaim:        13824 kB
>
>
> Any help is appreciated,
> Thomas
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
