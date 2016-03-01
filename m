Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 447636B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 16:07:11 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id c203so46271743oia.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:07:11 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id j21si10124322oib.97.2016.03.01.13.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 13:07:10 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id c203so46271540oia.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:07:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160301125340.ffcc278e7f35fc3a28268e08@linux-foundation.org>
References: <20160301195504.40400.79558.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160301125340.ffcc278e7f35fc3a28268e08@linux-foundation.org>
Date: Tue, 1 Mar 2016 13:07:10 -0800
Message-ID: <CAPcyv4hxU-JM5mwM_YnZciyEBieVtyPf42QQpZv30HnhbcrTRQ@mail.gmail.com>
Subject: Re: [RFC PATCH] semaphore: fix uninitialized list_head vs list_force_poison
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Peter Zijlstra <peterz@infradead.org>, XFS Developers <xfs@oss.sgi.com>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Mar 1, 2016 at 12:53 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 01 Mar 2016 11:55:04 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> list_force_poison is a debug mechanism to make sure that ZONE_DEVICE
>> pages never appear on an lru.  Those pages only exist for enabling DMA
>> to device discovered memory ranges and are not suitable for general
>> purpose allocations.  list_force_poison() explicitly initializes a
>> list_head with a poison value that list_add() can use to detect mistaken
>> use of page->lru.
>>
>> Unfortunately, it seems calling list_add() leads to the poison value
>> leaking on to the stack and occasionally cause stack-allocated
>> list_heads to be inadvertently "force poisoned".
>>
>>  list_add attempted on force-poisoned entry
>>  WARNING: at lib/list_debug.c:34
>>  [..]
>>  NIP [c00000000043c390] __list_add+0xb0/0x150
>>  LR [c00000000043c38c] __list_add+0xac/0x150
>>  Call Trace:
>>  [c000000fb5fc3320] [c00000000043c38c] __list_add+0xac/0x150 (unreliable)
>>  [c000000fb5fc33a0] [c00000000081b454] __down+0x4c/0xf8
>>  [c000000fb5fc3410] [c00000000010b6f8] down+0x68/0x70
>>  [c000000fb5fc3450] [d0000000201ebf4c] xfs_buf_lock+0x4c/0x150 [xfs]
>>
>>  list_add attempted on force-poisoned entry(0000000000000500),
>>   new->next == d0000000059ecdb0, new->prev == 0000000000000500
>>  WARNING: at lib/list_debug.c:33
>>  [..]
>>  NIP [c00000000042db78] __list_add+0xa8/0x140
>>  LR [c00000000042db74] __list_add+0xa4/0x140
>>  Call Trace:
>>  [c0000004c749f620] [c00000000042db74] __list_add+0xa4/0x140 (unreliable)
>>  [c0000004c749f6b0] [c0000000008010ec] rwsem_down_read_failed+0x6c/0x1a0
>>  [c0000004c749f760] [c000000000800828] down_read+0x58/0x60
>>  [c0000004c749f7e0] [d000000005a1a6bc] xfs_log_commit_cil+0x7c/0x600 [xfs]
>>
>> We can squash these uninitialized list_heads as they pop-up as this
>> patch does, or maybe need to rethink how to implement the
>> list_force_poison() safety mechanism.
>
> Yes, problem.
>
>>  kernel/locking/rwsem-xadd.c |    4 +++-
>>  kernel/locking/semaphore.c  |    4 +++-
>
> The patch adds slight overhead and there will be other uninitialized
> list_heads around the place and more will turn up in the future.
>
> I don't see how list_force_poison is fixable, really - we're relying
> upon some uninitialized word of memory not having some particular value.
> Good luck with that.
>
> Maybe we simply remove list_force_poison() - it isn't terribly
> important?
>
>         /* ZONE_DEVICE pages must never appear on a slab lru */
>
> Can we instead add a check of page_zone(page) into the lru-addition
> sites?

That's a possibility although I also wanted to catch drivers that
think they can use page->lru as long as they have a reference against
the page.  However, moving the safety mechanism to the individual call
sites guarantees that we'll miss some.  It trades one form of
wack-a-mole for another, so I think just killing list_force_poison()
is our best option.

> There are probably quite a few possible places.  (Why does the
> comment say "slab"?).

Yeah, it should say zone lru, I was referring to placing a ZONE_DEVICE
page on a free list that would allow it to be allocated via
alloc_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
