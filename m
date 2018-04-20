Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCA26B0003
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:10:14 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j69-v6so1174040lfg.6
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 06:10:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w89-v6sor497730lfk.66.2018.04.20.06.10.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 06:10:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
References: <bug-198497-200779@https.bugzilla.kernel.org/> <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
From: Jason Andryuk <jandryuk@gmail.com>
Date: Fri, 20 Apr 2018 09:10:11 -0400
Message-ID: <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
Subject: Re: [Bug 198497] handle_mm_fault / xen_pmd_val / radix_tree_lookup_slot
 Null pointer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bugzilla-daemon@bugzilla.kernel.org, willy@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, labbott@redhat.com

On Thu, Apr 12, 2018 at 1:28 PM,  <bugzilla-daemon@bugzilla.kernel.org> wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=198497
>
> --- Comment #25 from willy@infradead.org ---
> On Thu, Apr 12, 2018 at 10:12:09AM -0700, Andrew Morton wrote:
>> On Fri, 9 Feb 2018 06:47:26 -0800 Matthew Wilcox <willy@infradead.org> wrote:
>>
>> >
>> > ping?
>> >
>>
>> There have been a bunch of updates to this issue in bugzilla
>> (https://bugzilla.kernel.org/show_bug.cgi?id=198497).  Sigh, I don't
>> know what to do about this - maybe there's some way of getting bugzilla
>> to echo everything to linux-mm or something.
>>
>> Anyway, please take a look - we appear to have a bug here.  Perhaps
>> this bug is sufficiently gnarly for you to prepare a debugging patch
>> which we can add to the mainline kernel so we get (much) more debugging
>> info when people hit it?
>
> I have a few thoughts ...
>
>  - The debugging patch I prepared appears to be doing its job well.
>    People get the message and their machine stays working.
>  - The commonality appears to be Xen running 32-bit kernels.  Maybe we
>    can kick the problem over to them to solve?
>  - If we are seeing corruption purely in the lower bits, *we'll never
>    know*.  The radix tree lookup will simply not find anything, and all
>    will be well.  That said, the bad PTE values reported in that bug have
>    the NX bit and one other bit set; generally bit 32, 33 or 34.  I have
>    an idea for adding a parity bit, but haven't had time to implement it.
>    Anyone have an intern who wants an interesting kernel project to work on?
>
> Given that this is happening on Xen, I wonder if Xen is using some of the
> bits in the page table for its own purposes.

The backtraces include do_swap_page().  While I have a swap partition
configured, I don't think it's being used.  Are we somehow
misidentifying the page as a swap page?  I'm not familiar with the
code, but is there an easy way to query global swap usage?  That way
we can see if the check for a swap page is bogus.

My system works with the band-aid patch.  When that patch sets page =
NULL, does that mean userspace is just going to get a zero-ed page?
Userspace still works AFAICT, which makes me think it is a
mis-identified page to start with.

Regards,
Jason
