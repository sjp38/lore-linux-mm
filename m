Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id DBD236B0071
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 13:07:39 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so1138578qcv.33
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 10:07:39 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id z2si1497330qad.81.2014.02.28.10.07.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 10:07:39 -0800 (PST)
Message-ID: <5310D060.1090504@surriel.com>
Date: Fri, 28 Feb 2014 13:07:28 -0500
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm:prototype for the updated swapoff implementation
References: <20140219003522.GA8887@kelleynnn-virtual-machine> <alpine.LSU.2.11.1402271054390.7000@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1402271054390.7000@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Kelley Nielsen <kelleynnn@gmail.com>
Cc: akpm@linux-foundation.org, gnomes@lxorguk.ukuu.org.uk, josh@joshtriplett.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, opw-kernel@googlegroups.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com

On 02/27/2014 07:33 PM, Hugh Dickins wrote:
> On Tue, 18 Feb 2014, Kelley Nielsen wrote:
> 
>> The function try_to_unuse() is of quadratic complexity, with a lot of
>> wasted effort. It unuses swap entries one by one, potentially iterating
>> over all the page tables for all the processes in the system for each
>> one.
> 
> You've chosen a good target, and I like the look of what you've done.
> But I'm afraid it will have to get uglier before it's ready, and I'm
> unsure whether your approach will prove to be a clear win or not.

I am more optimistic than you, because I have seen swapoff
on my Nehalem system proceed at under 1MB/s for several hours,
to clear maybe 3-4GB of stuff out of swap :)

>> This new proposed implementation of try_to_unuse simplifies its
>> complexity to linear. It iterates over the system's mms once, unusing
>> all the affected entries as it walks each set of page tables. It also
>> makes similar changes to shmem_unuse.
>>
>> Improvement
>>
>> swapoff was called on a swap partition containing about 50M of data,
>> and calls to the function unuse_pte_range were counted.
>>
>> Present implementation....about 22.5M calls.
>> Prototype.................about  7.0K   calls.
> 
> That's nice, but mostly it's the time spent that matters.
> 
> I should explain why we've left the try_to_unuse() implementation as is
> for so many years: it's a matter of tradeoff between fast cpu and slow
> seeking disk.

> I'll be surprised if your approach does not improve swapoff from SSD
> (and brd and zram and zswap) very significantly; but the case to worry
> about is swapoff from hard disk.  You are changing swapoff to use the
> cpu much more efficiently; but now that you no longer move linearly up
> the swap_map, you are making the disk head seek around very much more.

I suspect proper read-around of the swap area should take care of
IO patterns well enough. The quadratic nature of the current
try_to_unuse search can easily slow things down to comically low
speeds...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
