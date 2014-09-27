Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 81B676B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 23:04:51 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id ey11so2611630pad.13
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 20:04:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xq3si11868632pbb.253.2014.09.26.20.04.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 20:04:50 -0700 (PDT)
Message-ID: <542628C8.8030004@oracle.com>
Date: Fri, 26 Sep 2014 23:02:32 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref in migrate_page_move_mapping
References: <5420407E.8040406@oracle.com> <alpine.LSU.2.11.1409221531570.1244@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1409221531570.1244@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Andrey Ryabinin <a.ryabinin@samsung.com>

On 09/22/2014 07:04 PM, Hugh Dickins wrote:
>> but I'm not sure what went wrong.
> Most likely would be a zeroing of the radix_tree node, just as you
> were experiencing zeroing of other mm structures in earlier weeks.
> 
> Not that I've got any suggestions on where to take it from there.

I've added poisoning to a few mm related structures, and managed to
confirm that the issue here is indeed corruption rather than something
specific with the given structures.

Right now I'm looking into making KASan (Cc Andrey) to mark the poison
bytes somehow so it would trigger an error on access, that way we'll
know what's corruption them.

Andrey, since it takes a while to trigger this corruption, could you
confirm that if I kasan_poison_shadow() a few bytes I will get a KASan
report on any read/write to them?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
