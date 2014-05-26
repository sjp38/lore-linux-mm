Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id A95E76B0037
	for <linux-mm@kvack.org>; Mon, 26 May 2014 16:49:09 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so344956igb.15
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:49:09 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id cw13si22460599icb.74.2014.05.26.13.49.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 13:49:09 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id hn18so343213igb.6
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:49:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140526203232.GC5444@laptop.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
	<CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
	<20140526203232.GC5444@laptop.programming.kicks-ass.net>
Date: Tue, 27 May 2014 00:49:08 +0400
Message-ID: <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, May 27, 2014 at 12:32 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, May 27, 2014 at 12:19:16AM +0400, Konstantin Khlebnikov wrote:
>> On Mon, May 26, 2014 at 6:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > Hi all,
>> >
>> > I mentioned at LSF/MM that I wanted to revive this, and at the time there were
>> > no disagreements.
>> >
>> > I finally got around to refreshing the patch(es) so here goes.
>> >
>> > These patches introduce VM_PINNED infrastructure, vma tracking of persistent
>> > 'pinned' page ranges. Pinned is anything that has a fixed phys address (as
>> > required for say IO DMA engines) and thus cannot use the weaker VM_LOCKED. One
>> > popular way to pin pages is through get_user_pages() but that not nessecarily
>> > the only way.
>>
>> Lol, this looks like resurrection of VM_RESERVED which I've removed
>> not so long time ago.

That was swap-out prevention from 2.4 era, something between VM_IO and
VM_LOCKED with various side effects.

>
> Not sure what VM_RESERVED did, but there might be a similarity.
>
>> Maybe single-bit state isn't flexible enought?
>
> Not sure what you mean, the one bit is perfectly fine for what I want it
> to do.
>
>> This supposed to supports pinning only by one user and only in its own mm?
>
> Pretty much, that's adequate for all users I'm aware of and mirrors the
> mlock semantics.

Ok, fine. Because get_user_pages is used sometimes for pinning pages
from different mm.

Another suggestion. VM_RESERVED is stronger than VM_LOCKED and extends
its functionality.
Maybe it's easier to add VM_DONTMIGRATE and use it together with VM_LOCKED.
This will make accounting easier. No?

>
>> This might be done as extension of existing memory-policy engine.
>> It allows to keep vm_area_struct slim in normal cases and change
>> behaviour when needed.
>> memory-policy might hold reference-counter of "pinners", track
>> ownership and so on.
>
> That all sounds like raping the mempolicy code and massive over
> engineering.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
