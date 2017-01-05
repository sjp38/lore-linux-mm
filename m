Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 186BE6B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 15:15:09 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id x186so257472475vkd.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:15:09 -0800 (PST)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id b133si19425478vkf.209.2017.01.05.12.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 12:15:08 -0800 (PST)
Received: by mail-ua0-x235.google.com with SMTP id 88so382992960uaq.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:15:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com> <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 5 Jan 2017 12:14:47 -0800
Message-ID: <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 5, 2017 at 11:39 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 01/05/2017 11:29 AM, Kirill A. Shutemov wrote:
>> On Thu, Jan 05, 2017 at 11:13:57AM -0800, Dave Hansen wrote:
>>> On 12/26/2016 05:54 PM, Kirill A. Shutemov wrote:
>>>> MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
>>>> address available to map by userspace.
>>>
>>> What happens to existing mappings above the limit when this upper limit
>>> is dropped?
>>
>> Nothing: we only prevent creating new mappings. All existing are not
>> affected.
>>
>> The semantics here the same as with other resource limits.
>>
>>> Similarly, why do we do with an application running with something
>>> incompatible with the larger address space that tries to raise the
>>> limit?  Say, legacy MPX.
>>
>> It has to know what it does. Yes, it can change limit to the point where
>> application is unusable. But you can to the same with other limits.
>
> I'm not sure I'm comfortable with this.  Do other rlimit changes cause
> silent data corruption?  I'm pretty sure doing this to MPX would.
>

What actually goes wrong in this case?  That is, what combination of
MPX setup of subsequent allocations will cause a problem, and is the
problem worse than just a segfault?  IMO it would be really nice to
keep the messy case confined to MPX.

FWIW, this problem is kind of generic.  If you run code in a process,
MPX or otherwise, that assumes something about pointer values and then
create a pointer that violates its assumptions, you will cause
problems.  For example, some VMs use high bits to store metadata.  If
you feed a pointer that's too big to such code, boom.  This is exactly
why high addresses need to be opt-in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
