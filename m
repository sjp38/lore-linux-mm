Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id EE3866B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:54:52 -0400 (EDT)
Received: by lbbuc2 with SMTP id uc2so7558064lbb.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:54:52 -0700 (PDT)
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com. [209.85.215.50])
        by mx.google.com with ESMTPS id ld16si18038304lbb.169.2015.04.28.15.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:54:51 -0700 (PDT)
Received: by layy10 with SMTP id y10so7550966lay.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:54:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55400CA7.3050902@redhat.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi> <55400CA7.3050902@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Apr 2015 15:54:29 -0700
Message-ID: <CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 3:41 PM, Rik van Riel <riel@redhat.com> wrote:
> On 04/28/2015 06:15 PM, Kirill A. Shutemov wrote:
>> On Tue, Apr 28, 2015 at 01:42:10PM -0700, Andy Lutomirski wrote:
>>> At some point, I'd like to implement PCID on x86 (if no one beats me
>>> to it, and this is a low priority for me), which will allow us to skip
>>> expensive TLB flushes while context switching.  I have no idea whether
>>> ARM can do something similar.
>>
>> I talked with Dave about implementing PCID and he thinks that it will be
>> net loss. TLB entries will live longer and it means we would need to trigger
>> more IPIs to flash them out when we have to. Cost of IPIs will be higher
>> than benifit from hot TLB after context switch.
>
> I suspect that may depend on how you do the shootdown.
>
> If, when receiving a TLB shootdown for a non-current PCID, we just flush
> all the entries for that PCID and remove the CPU from the mm's
> cpu_vm_mask_var, we will never receive more than one shootdown IPI for
> a non-current mm, but we will still get the benefits of TLB longevity
> when dealing with eg. pipe workloads where tasks take turns running on
> the same CPU.

I had a totally different implementation idea in mind.  It goes
something like this:

For each CPU, we allocate a fixed number of PCIDs, e.g. 0-7.  We have
a per-cpu array of the mm [1] that owns each PCID.  On context switch,
we look up the new mm in the array and, if there's a PCID mapped, we
switch cr3 and select that PCID.  If there is no PCID mapped, we
choose one (LRU?  clock replacement?), switch cr3 and select and
invalidate that PCID.

When it's time to invalidate a TLB entry on an mm that's active
remotely, we really don't want to send an IPI to a CPU that doesn't
actually have that mm active.  Instead we bump some kind of generation
counter in the mm_struct that will cause the next switch to that mm
not to match the PCID list.  To keep this working, I think we also
need to update the per-cpu PCID list with our generation counter
either when we context switch out or when we process a TLB shootdown
IPI.

This could be a bit tricky to get right, but I think it can be done
without adding more than a cacheline or two to the context switch
overhead and without any extra IPIs at all.

[1] It shouldn't be just an mm_struct pointer, because then we have to
invalidate it somehow when we recycle an mm_struct.  Maybe we'd use
some kind of counter.   We also need a TLB shootdown generation
counter of some sort as described.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
