Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75D186B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 16:28:02 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id f2so21152025uaf.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 13:28:02 -0800 (PST)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id f62si1713577vkc.110.2017.01.05.13.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 13:28:01 -0800 (PST)
Received: by mail-vk0-x230.google.com with SMTP id p9so306013436vkd.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 13:28:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com> <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com> <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 5 Jan 2017 13:27:40 -0800
Message-ID: <CALCETrW7yxmgrR15yvxkXOF1pHy5vicwDv6Oj019ecEyBCrWBQ@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 5, 2017 at 12:49 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 01/05/2017 12:14 PM, Andy Lutomirski wrote:
>>> I'm not sure I'm comfortable with this.  Do other rlimit changes cause
>>> silent data corruption?  I'm pretty sure doing this to MPX would.
>>>
>> What actually goes wrong in this case?  That is, what combination of
>> MPX setup of subsequent allocations will cause a problem, and is the
>> problem worse than just a segfault?  IMO it would be really nice to
>> keep the messy case confined to MPX.
>
> The MPX bounds tables are indexed by virtual address.  They need to grow
> if the virtual address space grows.   There's an MSR that controls
> whether we use the 48-bit or 57-bit layout.  It basically decides
> whether we need a 2GB (48-bit) or 1TB (57-bit) bounds directory.
>
> The question is what we do with legacy MPX applications.  We obviously
> can't let them just allocate a 2GB table and then go let the hardware
> pretend it's 1TB in size.  We also can't hand the hardware using a 2GB
> table an address >48-bits.
>
> Ideally, I'd like to make sure that legacy MPX can't be enabled if this
> RLIMIT is set over 48-bits (really 47).  I'd also like to make sure that
> legacy MPX is active, that the RLIMIT can't be raised because all hell
> will break loose when the new addresses show up.
>
> Remember, we already have (legacy MPX) binaries in the wild that have no
> knowledge of this stuff.  So, we can implicitly have the kernel bump
> this rlimit around, but we can't expect userspace to do it, ever.

If you s/rlimit/prctl, then I think this all makes sense with one
exception.  It would be a bit sad if the personality-setting tool
didn't work if compiled with MPX.

So what if we had a second prctl field that is the value that kicks in
after execve()?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
