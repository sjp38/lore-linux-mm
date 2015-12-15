Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 839636B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:31:42 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n186so82599656wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 00:31:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si2762403wma.115.2015.12.15.00.31.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Dec 2015 00:31:41 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/compaction: fix invalid free_pfn and
 compact_cached_free_pfn
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <566E94C6.5080000@suse.cz>
 <CAAmzW4MEAYJKkQs9ksq+2aOA02xqekmruqwEv5e4szK7i7BjPw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566FCFEB.1020305@suse.cz>
Date: Tue, 15 Dec 2015 09:31:39 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4MEAYJKkQs9ksq+2aOA02xqekmruqwEv5e4szK7i7BjPw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/14/2015 04:26 PM, Joonsoo Kim wrote:
> 2015-12-14 19:07 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 12/14/2015 06:02 AM, Joonsoo Kim wrote:
>>>
>>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>
>> Note that until now in compaction we've used basically an open-coded
>> round_down(), and ALIGN() for rounding up. You introduce a first use of
>> round_down(), and it would be nice to standardize on round_down() and
>> round_up() everywhere. I think it's more obvious than open-coding and
>> ALIGN() (which doesn't tell the reader if it's aligning up or down).
>> Hopefully they really do the same thing and there are no caveats...
>
> Okay. Will send another patch for this clean-up on next spin.

Great, I didn't mean that the cleanup is needed right now, but whether 
we agree on an idiom to use whenever doing any changes from now on.
Maybe it would be best to add some defines in the top of compaction.c 
that would also hide away the repeated pageblock_nr_pages everywhere? 
Something like:

#define pageblock_start(pfn) round_down(pfn, pageblock_nr_pages)
#define pageblock_end(pfn) round_up((pfn)+1, pageblock_nr_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
