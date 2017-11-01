Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 476556B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:04:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t10so3572129pgo.20
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:04:58 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c26si1832272pge.158.2017.11.01.14.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 14:04:57 -0700 (PDT)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BF4FD21958
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 21:04:56 +0000 (UTC)
Received: by mail-io0-f171.google.com with SMTP id e89so9097255ioi.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:04:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5bc39561-b65e-82fd-3218-d91a4d22613a@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223224.B9F5D5CA@viggo.jf.intel.com>
 <CALCETrUVC4KMPLNzs1mH=sGs9W9-HtajHAHOtOv0-LaT6uNb+g@mail.gmail.com>
 <38b34f81-3adb-98c5-c482-0d53b9155d3b@linux.intel.com> <CALCETrUSUYz8NcTz4aWkdCSo1dQh02QpYyLkWn=ScXoGH2vL1Q@mail.gmail.com>
 <5bc39561-b65e-82fd-3218-d91a4d22613a@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 14:04:35 -0700
Message-ID: <CALCETrUecDLRTdQBERrzk4nuS-fGFg0USkWRXfRMGw1fxYRP7w@mail.gmail.com>
Subject: Re: [PATCH 21/23] x86, pcid, kaiser: allow flushing for future ASID switches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 1, 2017 at 1:59 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> On 11/01/2017 01:31 PM, Andy Lutomirski wrote:
>> On Wed, Nov 1, 2017 at 7:17 AM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>> On 11/01/2017 01:03 AM, Andy Lutomirski wrote:
>>>>> This ensures that any futuee context switches will do a full flush
>>>>> of the TLB so they pick up the changes.
>>>> I'm convuced.  What was wrong with the old code?  I guess I just don't
>>>> see what the problem is that is solved by this patch.
>>>
>>> Instead of flushing *now* with INVPCID, this lets us flush *later* with
>>> CR3.  It just hijacks the code that you already have that flushes CR3
>>> when loading a new ASID by making all ASIDs look new in the future.
>>>
>>> We have to load CR3 anyway, so we might as well just do this flush then.
>>
>> Would it make more sense to put it in flush_tlb_func_common() instead?
>>
>> Also, I don't understand what clear_non_loaded_ctxs() is trying to do.
>> It looks like it's invalidating all the other logical address spaces.
>> And I don't see why you want a all_other_ctxs_invalid variable.  Isn't
>> the goal to mark a single ASID as needing a *user* flush the next time
>> we switch to user mode using that ASID?  Your code seems like it's
>> going to flush a lot of *kernel* PCIDs.
>
> The point of the whole thing is to (relatively) efficiently flush
> *kernel* TLB entries in *other* address spaces.

Aha!  That wasn't at all clear to me from the changelog.  Can I make a
totally different suggestion?  Add a new function
__flush_tlb_one_kernel() and use it for kernel addresses.  That
function should just do __flush_tlb_all() if KAISER is on.  Then make
sure that there are no performance-critical looks that call
__flush_tlb_one_kernel() in KAISER mode.  The approach you're using is
quite expensive, and I suspect that just going a global flush may
actually be faster.  It's certainly a lot simpler.

Optionally add a warning to __flush_tlb_one() if the address is a
kernel address to help notice any missed conversions.  Or just rename
it to __flush_tlb_one_user().

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
