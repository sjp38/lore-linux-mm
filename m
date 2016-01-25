Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9C16D6B0009
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 16:30:01 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id g73so169607520ioe.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:30:01 -0800 (PST)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id k20si36098096ioe.26.2016.01.25.13.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 13:30:00 -0800 (PST)
Received: by mail-io0-x232.google.com with SMTP id 1so165922287ion.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:30:00 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 25 Jan 2016 13:30:00 -0800
Message-ID: <CAMbhsRTAeobrQAqujusAVpw+wZyr3WsdKd4iQPi62GWyLB3gJA@mail.gmail.com>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Tue, Jan 19, 2016 at 3:30 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Tue, Jan 19, 2016 at 02:14:30PM -0800, Andrew Morton wrote:
>> On Tue, 19 Jan 2016 13:02:39 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
>>
>> > b764375 ("procfs: mark thread stack correctly in proc/<pid>/maps")
>> > added [stack:TID] annotation to /proc/<pid>/maps. Finding the task of
>> > a stack VMA requires walking the entire thread list, turning this into
>> > quadratic behavior: a thousand threads means a thousand stacks, so the
>> > rendering of /proc/<pid>/maps needs to look at a million threads. The
>> > cost is not in proportion to the usefulness as described in the patch.
>> >
>> > Drop the [stack:TID] annotation to make /proc/<pid>/maps (and
>> > /proc/<pid>/numa_maps) usable again for higher thread counts.
>> >
>> > The [stack] annotation inside /proc/<pid>/task/<tid>/maps is retained,
>> > as identifying the stack VMA there is an O(1) operation.
>>
>> Four years ago, ouch.
>>
>> Any thoughts on the obvious back-compatibility concerns?  ie, why did
>> Siddhesh implement this in the first place?  My bad for not ensuring
>> that the changelog told us this.
>>
>> https://lkml.org/lkml/2012/1/14/25 has more info:
>>
>> : Memory mmaped by glibc for a thread stack currently shows up as a
>> : simple anonymous map, which makes it difficult to differentiate between
>> : memory usage of the thread on stack and other dynamic allocation.
>> : Since glibc already uses MAP_STACK to request this mapping, the
>> : attached patch uses this flag to add additional VM_STACK_FLAGS to the
>> : resulting vma so that the mapping is treated as a stack and not any
>> : regular anonymous mapping.  Also, one may use vm_flags to decide if a
>> : vma is a stack.
>>
>> But even that doesn't really tell us what the actual *value* of the
>> patch is to end-users.
>
> I doubt it can be very useful as it's unreliable: if two stacks are
> allocated end-to-end (which is not good idea, but still) it can only
> report [stack:XXX] for the first one as they are merged into one VMA.
> Any other anon VMA merged with the stack will be also claimed as stack,
> which is not always correct.
>
> I think report the VMA as anon is the best we can know about it,
> everything else just rather expensive guesses.

An alternative to guessing is the anonymous VMA naming patch used on
Android, https://lkml.org/lkml/2013/10/30/518.  It allows userspace to
name anonymous memory however it wishes, and prevents vma merging
adjacent regions with different names.  Android uses it to label
native heap memory, but it would work well for stacks too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
