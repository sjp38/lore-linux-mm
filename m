Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 381356B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 08:50:58 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id wo10so1392316obc.27
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 05:50:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130725022543.GR3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
	<1373594635-131067-5-git-send-email-holt@sgi.com>
	<CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
	<20130725022543.GR3421@sgi.com>
Date: Thu, 25 Jul 2013 05:50:57 -0700
Message-ID: <CAE9FiQV7Va8iAESoXsPCFJo8-jeA=-7SW2b9BmKnUrVonLV1=g@mail.gmail.com>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Wed, Jul 24, 2013 at 7:25 PM, Robin Holt <holt@sgi.com> wrote:
>>
>> How about holes that is not in memblock.reserved?
>>
>> before this patch:
>> free_area_init_node/free_area_init_core/memmap_init_zone
>> will mark all page in node range to Reserved in struct page, at first.
>>
>> but those holes is not mapped via kernel low mapping.
>> so it should be ok not touch "struct page" for them.
>>
>> Now you only mark reserved for memblock.reserved at first, and later
>> mark {memblock.memory} - { memblock.reserved} to be available.
>> And that is ok.
>>
>> but should split that change to another patch and add some comment
>> and change log for the change.
>> in case there is some user like UEFI etc do weird thing.
>
> Nate and I talked this over today.  Sorry for the delay, but it was the
> first time we were both free.  Neither of us quite understands what you
> are asking for here.  My interpretation is that you would like us to
> change the use of the PageReserved flag such that during boot, we do not
> set the flag at all from memmap_init_zone, and then only set it on pages
> which, at the time of free_all_bootmem, have been allocated/reserved in
> the memblock allocator.  Is that correct?  I will start to work that up
> on the assumption that is what you are asking for.

Not exactly.

your change should be right, but there is some subtle change about
holes handling.

before mem holes between memory ranges in memblock.memory, get struct page,
and initialized with to Reserved in memmap_init_zone.
Those holes is not in memory.reserved, with your patches, those hole's
struct page
will still have all 0.

Please separate change about set page to reserved according to memory.reserved
to another patch.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
