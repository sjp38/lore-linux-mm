Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1572D6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:40:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h1so13554424wre.0
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:40:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x12si5629344ede.160.2018.04.16.12.40.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 12:40:19 -0700 (PDT)
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
References: <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com>
 <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz>
 <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2df431db-6127-c8f5-4eab-23eaf29dcb49@suse.cz>
Date: Mon, 16 Apr 2018 21:38:21 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/16/2018 04:37 PM, Mikulas Patocka wrote:
>>> Can you or Mikulas briefly summarize how the dependency is avoided, and
>>> whether if (something like) SLAB_MINIMIZE_WASTE were implemented, the
>>> dm-bufio code would happily switch to it, or not?
>>
>> git log eeb67a0ba04df^..45354f1eb67224669a1 -- drivers/md/dm-bufio.c
>>
>> But the most signficant commit relative to SLAB_MINIMIZE_WASTE is: 
>> 359dbf19ab524652a2208a2a2cddccec2eede2ad ("dm bufio: use slab cache for 
>> dm_buffer structure allocations")
>>
>> So no, I don't see why dm-bufio would need to switch to
>> SLAB_MINIMIZE_WASTE if it were introduced in the future.
> 
> Currently, the slab cache rounds up the size of the slab to the next power 
> of two (if the size is large). And that wastes memory if that memory were 
> to be used for deduplication tables.
> 
> Generally, the performance of the deduplication solution depends on how 
> much data can you put to memory. If you round 640KB buffer to 1MB (this is 
> what the slab and slub subsystem currently do), you waste a lot of memory. 
> Deduplication indices with 640KB blocks are already used in the wild, so 
> it can't be easily changed.

Thank you both for the clarification.

Vlastimil

> 
>> Mike
> 
> Mikulas
> 
