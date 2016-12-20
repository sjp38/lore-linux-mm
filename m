Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08D186B0339
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 12:31:21 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j15so565626ioj.7
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 09:31:21 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id v11si17196560iov.153.2016.12.20.09.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 09:31:19 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id b123so14729201itb.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 09:31:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com> <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
 <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 20 Dec 2016 09:31:18 -0800
Message-ID: <CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Mon, Dec 19, 2016 at 4:20 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 12/19/2016 03:07 PM, Linus Torvalds wrote:
>>     +wait_queue_head_t *bit_waitqueue(void *word, int bit)
>>     +{
>>     +       const int __maybe_unused nid = page_to_nid(virt_to_page(word));
>>     +
>>     +       return __bit_waitqueue(word, bit, nid);
>>
>> No can do. Part of the problem with the old coffee was that it did that
>> virt_to_page() crud. That doesn't work with the virtually mapped stack.
>
> Ahhh, got it.
>
> So, what did you have in mind?  Just redirect bit_waitqueue() to the
> "first_online_node" waitqueues?

That was my initial thought, but now that I'm back home and look at
the code, I realize:

 - we never merged the PageWaiters patch. I thought we already did,
because I didn't think there was any confusion left, but that was
clearly just in my dreams.

   I was surprised that you'd see the cache ping-pong with per-page
contention bit, but thought that maybe your benchmark was some kind of
broken "fault in the same page over and over again on multiple nodes"
thing. But it was simpler than that - you simply don't have the
per-page contention bit at all.

   And quite frankly, I still suspect that just doing the per-page
contention bit will solve everything, and we don't want to do the
numa-spreading bit_waitqueue() at all.

 - but if I'm wrong, and you can still see numa issues even with the
per-page contention bit in place, we should just treat
"bit_waitqueue()" separately from the page waitqueue, and just have a
separate (non-node) array for the bit-waitqueue.

I'll go back and try to see why the page flag contention patch didn't
get applied.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
