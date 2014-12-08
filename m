Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CCC426B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 03:32:22 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so3978871wiw.1
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 00:32:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si8848669wie.4.2014.12.08.00.32.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 00:32:21 -0800 (PST)
Message-ID: <54856213.9070909@suse.cz>
Date: Mon, 08 Dec 2014 09:32:19 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V2 0/4] Reducing parameters of alloc_pages* family
 of functions
References: <1417809545-4540-1-git-send-email-vbabka@suse.cz> <CA+55aFwvWk6twgBaevPrF5z_0Faetnh0L19ZokWLidiaAaUmQg@mail.gmail.com>
In-Reply-To: <CA+55aFwvWk6twgBaevPrF5z_0Faetnh0L19ZokWLidiaAaUmQg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On 12/06/2014 02:07 AM, Linus Torvalds wrote:
> On Fri, Dec 5, 2014 at 11:59 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> Hey all,
>>
>> this is a V2 of attempting something that has been discussed when Minchan
>> proposed to expand the x86 kernel stack [1], namely the reduction of huge
>> number of parameters that the alloc_pages* family and get_page_from_freelist()
>> functions have.
>
> So I generally like this, but looking at that "struct alloc_context",
> one member kind of stands out: the "order" parameter doesn't fit in
> with all the other members.
>
> Most everything else is describing where or what kind of pages to work
> with. The "order" in contrast, really is separate.
>
> So conceptually, my reaction is that it looks like a good cleanup even
> aside from the code/stack size reduction, but that the alloc_context
> definition is a bit odd.
>
> Quite frankly, I think the :"order" really fits much more closely with
> "alloc_flags", not with the alloc_context. Because like alloc_flags,.
> it really describes how we need to allocate things within the context,
> I'd argue.
>
> In fact, I think that the order could actually be packed with the
> alloc_flags in a single register, even on 32-bit (using a single-word
> structure, perhaps). If we really care about number of parameters.
>
> I'd rather go for "makes conceptual sense" over "packs order in
> because it kind of works" and we don't modify it".
>
> Hmm?

Thanks for the suggestions, order indeed stands out. I'll check if it 
makes more sense to have it separately, or pack as you suggest. Packing
could perhaps bring more complexity than the benefit of less parameters. 
But the suggestion made me realize that migratetype could be also packed 
into alloc_flags and it would be more straightforward for that than order.

With order and migratetype out, everything left in alloc_context would 
be about nodes and zones, which is also good I guess. Maybe a different 
name for the structure then?

Vlastimil

>
>                         Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
