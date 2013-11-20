Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC006B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 03:12:17 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3826334pab.15
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 00:12:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.121])
        by mx.google.com with SMTP id yg5si13598302pbc.296.2013.11.20.00.12.14
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 00:12:16 -0800 (PST)
Message-ID: <528C6ED9.3070600@vmware.com>
Date: Wed, 20 Nov 2013 09:12:09 +0100
From: Thomas Hellstrom <thellstrom@vmware.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 0/3] Add dirty-tracking infrastructure for non-page-backed
 address spaces
References: <1384891576-7851-1-git-send-email-thellstrom@vmware.com> <528BEB60.7040402@amacapital.net>
In-Reply-To: <528BEB60.7040402@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-graphics-maintainer@vmware.com

On 11/19/2013 11:51 PM, Andy Lutomirski wrote:
> On 11/19/2013 12:06 PM, Thomas Hellstrom wrote:
>> Hi!
>>
>> Before going any further with this I'd like to check whether this is an
>> acceptable way to go.
>> Background:
>> GPU buffer objects in general and vmware svga GPU buffers in
>> particular are mapped by user-space using MIXEDMAP or PFNMAP. Sometimes the
>> address space is backed by a set of pages, sometimes it's backed by PCI memory.
>> In the latter case in particular, there is no way to track dirty regions
>> using page_mkwrite() and page_mkclean(), other than allocating a bounce
>> buffer and perform dirty tracking on it, and then copy data to the real GPU
>> buffer. This comes with a big memory- and performance overhead.
>>
>> So I'd like to add the following infrastructure with a callback pfn_mkwrite()
>> and a function mkclean_mapping_range(). Typically we will be cleaning a range
>> of ptes rather than random ptes in a vma.
>> This comes with the extra benefit of being usable when the backing memory of
>> the GPU buffer is not coherent with the GPU itself, and where we either need
>> to flush caches or move data to synchronize.
>>
>> So this is a RFC for
>> 1) The API. Is it acceptable? Any other suggestions if not?
>> 2) Modifying apply_to_page_range(). Better to make a standalone
>> non-populating version?
>> 3) tlb- mmu- and cache-flushing calls. I've looked at unmap_mapping_range()
>> and page_mkclean_one() to try to get it right, but still unsure.
> Most (all?) architectures have real dirty tracking -- you can mark a pte
> as "clean" and the hardware (or arch code) will mark it dirty when
> written, *without* a page fault.
>
> I'm not convinced that it works completely correctly right now (I
> suspect that there are some TLB flushing issues on the dirty->clean
> transition), and it's likely prone to bit-rot, since the page cache
> doesn't rely on it.
>
> That being said, using hardware dirty tracking should be *much* faster
> and less latency-inducing than doing it in software like this.  It may
> be worth trying to get HW dirty tracking working before adding more page
> fault-based tracking.
>
> (I think there's also some oddity on S/390.  I don't know what that
> oddity is or whether you should care.)
>
> --Andy

Andy,

Thanks for the tip. It indeed sounds interesting, however there are a 
couple of culprits:

1) As you say, it sounds like there might be TLB flushing issues. Let's 
say the TLB detects a write and raises an IRQ for the arch code to set 
the PTE dirty bit, and before servicing that interrupt, we clear the PTE 
and flush that TLB. What will happen? And if the TLB hardware would 
write directly to the in-memory PTE I guess we'd have the same 
synchronization issues. I guess we'd then need an atomic 
read-modify-write against the TLB hardware?
2) Even if most hardware is capable of this stuff, I'm not sure what 
would happen in a virtual machine. Need to check.
3) For dirty contents that need to appear on a screen within a short 
interval, we need the write notification anyway, to start a delayed task 
that will gather the dirty data and flush it to the screen...

Thanks,
/Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
