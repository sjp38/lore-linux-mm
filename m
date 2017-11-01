Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 246936B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 16:59:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so3527840pgu.22
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 13:59:20 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id bg3si516098plb.668.2017.11.01.13.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 13:59:18 -0700 (PDT)
Subject: Re: [PATCH 21/23] x86, pcid, kaiser: allow flushing for future ASID
 switches
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223224.B9F5D5CA@viggo.jf.intel.com>
 <CALCETrUVC4KMPLNzs1mH=sGs9W9-HtajHAHOtOv0-LaT6uNb+g@mail.gmail.com>
 <38b34f81-3adb-98c5-c482-0d53b9155d3b@linux.intel.com>
 <CALCETrUSUYz8NcTz4aWkdCSo1dQh02QpYyLkWn=ScXoGH2vL1Q@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5bc39561-b65e-82fd-3218-d91a4d22613a@linux.intel.com>
Date: Wed, 1 Nov 2017 13:59:17 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrUSUYz8NcTz4aWkdCSo1dQh02QpYyLkWn=ScXoGH2vL1Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/01/2017 01:31 PM, Andy Lutomirski wrote:
> On Wed, Nov 1, 2017 at 7:17 AM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>> On 11/01/2017 01:03 AM, Andy Lutomirski wrote:
>>>> This ensures that any futuee context switches will do a full flush
>>>> of the TLB so they pick up the changes.
>>> I'm convuced.  What was wrong with the old code?  I guess I just don't
>>> see what the problem is that is solved by this patch.
>>
>> Instead of flushing *now* with INVPCID, this lets us flush *later* with
>> CR3.  It just hijacks the code that you already have that flushes CR3
>> when loading a new ASID by making all ASIDs look new in the future.
>>
>> We have to load CR3 anyway, so we might as well just do this flush then.
> 
> Would it make more sense to put it in flush_tlb_func_common() instead?
> 
> Also, I don't understand what clear_non_loaded_ctxs() is trying to do.
> It looks like it's invalidating all the other logical address spaces.
> And I don't see why you want a all_other_ctxs_invalid variable.  Isn't
> the goal to mark a single ASID as needing a *user* flush the next time
> we switch to user mode using that ASID?  Your code seems like it's
> going to flush a lot of *kernel* PCIDs.

The point of the whole thing is to (relatively) efficiently flush
*kernel* TLB entries in *other* address spaces.  I did it way down in
the TLB handling functions because not everybody goes through
flush_tlb_func_common() to flush kernel addresses.

I used the variable instead of just invalidating the contexts directly
because I hooked into the __flush_tlb_single() path and it's used in
loops like this:

	for (addr = start; addr < end; addr++)
		__flush_tlb_single()

I didn't want to add a loop that effectively does:

	for (addr = start; addr < end; addr++)
		__flush_tlb_single();
		for (i = 0; i < TLB_NR_DYN_ASIDS; i++)
			this_cpu_write(cpu_tlbstate.ctxs[i].ctx_id, 0);

Even with just 6 ASIDS it seemed a little silly.  It would get _very_
silly if we ever decided to grow TLB_NR_DYN_ASIDS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
