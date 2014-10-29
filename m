Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7B616900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 11:08:12 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id z11so665803lbi.19
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 08:08:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m7si7574180lah.97.2014.10.29.08.08.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 08:08:09 -0700 (PDT)
Message-ID: <545102D1.6080908@suse.cz>
Date: Wed, 29 Oct 2014 16:08:01 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block(): very high intermittent overhead
References: <20141027204003.GB348@x4> <544EC0C5.7050808@suse.cz> <20141028085916.GA337@x4>
In-Reply-To: <20141028085916.GA337@x4>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-mm@kvack.org

On 10/28/2014 09:59 AM, Markus Trippelsdorf wrote:
> On 2014.10.27 at 23:01 +0100, Vlastimil Babka wrote:
>> On 10/27/2014 09:40 PM, Markus Trippelsdorf wrote:
>>> On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
>>> high (>20%) in perf top during the configuration phase of software
>>> builds. It increases build time considerably.
>>>
>>> Unfortunately the issue is not 100% reproducible, because it appears
>>> only intermittently. And the symptoms vanish after a few minutes.
>>
>> Does it happen for long enough so you can capture it by perf record -g ?
>
> It only happens when I use the "Lockless Allocator":
> http://locklessinc.com/downloads/lockless_allocator_src.tgz
>
> I use: LD_PRELOAD=/usr/lib/libllalloc.so.1.3 when building software,
> because it gives me a ~8% speed boost over glibc's malloc.

Hm I see. I'll try to test that.

> Unfortunately, I don't have time to debug this further and have disabled
> "Transparent Hugepage Support" for now.

That's unfortunate indeed. Commit 
e14c720efdd73c6d69cd8d07fa894bcd11fe1973 "mm, compaction: remember 
position within pageblock in free pages scanner" would be the most 
suspicious one here I guess, so testing at least a kernel with this 
patch reverted would be very useful. Simple git revert seems to apply 
cleanly here.

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
