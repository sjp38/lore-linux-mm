Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B89BA6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:12:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j71-v6so3266620lfj.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:12:51 -0700 (PDT)
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id j3si1079444lje.390.2018.04.03.06.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 06:12:50 -0700 (PDT)
Subject: Re: Signal handling in a page fault handler
References: <20180402141058.GL13332@bombadil.infradead.org>
 <152275879566.32747.9293394837417347482@mail.alporthouse.com>
From: Thomas Hellstrom <thomas@shipmail.org>
Message-ID: <e10f5e18-299b-57fd-4ba7-800caa1a105d@shipmail.org>
Date: Tue, 3 Apr 2018 15:12:35 +0200
MIME-Version: 1.0
In-Reply-To: <152275879566.32747.9293394837417347482@mail.alporthouse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Matthew Wilcox <willy@infradead.org>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux-kernel@vger.kernel.org

On 04/03/2018 02:33 PM, Chris Wilson wrote:
> Quoting Matthew Wilcox (2018-04-02 15:10:58)
>> Souptick and I have been auditing the various page fault handler routines
>> and we've noticed that graphics drivers assume that a signal should be
>> able to interrupt a page fault.  In contrast, the page cache takes great
>> care to allow only fatal signals to interrupt a page fault.
>>
>> I believe (but have not verified) that a non-fatal signal being delivered
>> to a task which is in the middle of a page fault may well end up in an
>> infinite loop, attempting to handle the page fault and failing forever.
>>
>> Here's one of the simpler ones:
>>
>>          ret = mutex_lock_interruptible(&etnaviv_obj->lock);
>>          if (ret)
>>                  return VM_FAULT_NOPAGE;
>>
>> (many other drivers do essentially the same thing including i915)
>>
>> On seeing NOPAGE, the fault handler believes the PTE is in the page
>> table, so does nothing before it returns to arch code at which point
>> I get lost in the magic assembler macros.  I believe it will end up
>> returning to userspace if the signal is non-fatal, at which point it'll
>> go right back into the page fault handler, and mutex_lock_interruptible()
>> will immediately fail.  So we've converted a sleeping lock into the most
>> expensive spinlock.
> I'll ask the obvious question: why isn't the signal handled on return to
> userspace?

+1

>
>> I don't think the graphics drivers really want to be interrupted by
>> any signal.
> Assume the worst case and we may block for 10s. Even a 10ms delay may be
> unacceptable to some signal handlers (one presumes). For the number one
> ^C usecase, yes that may be reduced to only bother if it's killable, but
> I wonder if there are not timing loops (e.g. sigitimer in Xorg < 1.19)
> that want to be able to interrupt random blockages.
> -Chris

I think the TTM page fault handler originally set the standard for this. 
First, IMO any critical section that waits for the GPU (like typically 
the page fault handler does), should be locked at least killable. The 
need for interruptible locks came from the X server's silken mouse 
relying on signals for smooth mouse operations: You didn't want the X 
server to be stuck in the kernel waiting for GPU completion when it 
should handle the cursor move request.. Now that doesn't seem to be the 
case anymore but to reiterate Chris' question, why would the signal 
persist once returned to user-space?

/Thomas







> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel
