Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2D16B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 16:52:58 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id c1so158451igq.1
        for <linux-mm@kvack.org>; Wed, 14 May 2014 13:52:57 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id za4si2247958icb.103.2014.05.14.13.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 13:52:57 -0700 (PDT)
Message-ID: <5373D781.7020109@oracle.com>
Date: Wed, 14 May 2014 16:52:17 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: replace remap_file_pages() syscall with emulation
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com> <1399552888-11024-3-git-send-email-kirill.shutemov@linux.intel.com> <20140508145729.3d82d2c989cfc483c94eb324@linux-foundation.org> <5370E4B4.1060802@oracle.com> <20140512170514.GA28227@node.dhcp.inet.fi>
In-Reply-To: <20140512170514.GA28227@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

On 05/12/2014 01:05 PM, Kirill A. Shutemov wrote:
> On Mon, May 12, 2014 at 11:11:48AM -0400, Sasha Levin wrote:
>> On 05/08/2014 05:57 PM, Andrew Morton wrote:
>>> On Thu,  8 May 2014 15:41:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>>>
>>>>> remap_file_pages(2) was invented to be able efficiently map parts of
>>>>> huge file into limited 32-bit virtual address space such as in database
>>>>> workloads.
>>>>>
>>>>> Nonlinear mappings are pain to support and it seems there's no
>>>>> legitimate use-cases nowadays since 64-bit systems are widely available.
>>>>>
>>>>> Let's drop it and get rid of all these special-cased code.
>>>>>
>>>>> The patch replaces the syscall with emulation which creates new VMA on
>>>>> each remap_file_pages(), unless they it can be merged with an adjacent
>>>>> one.
>>>>>
>>>>> I didn't find *any* real code that uses remap_file_pages(2) to test
>>>>> emulation impact on. I've checked Debian code search and source of all
>>>>> packages in ALT Linux. No real users: libc wrappers, mentions in strace,
>>>>> gdb, valgrind and this kind of stuff.
>>>>>
>>>>> There are few basic tests in LTP for the syscall. They work just fine
>>>>> with emulation.
>>>>>
>>>>> To test performance impact, I've written small test case which
>>>>> demonstrate pretty much worst case scenario: map 4G shmfs file, write to
>>>>> begin of every page pgoff of the page, remap pages in reverse order,
>>>>> read every page.
>>>>>
>>>>> The test creates 1 million of VMAs if emulation is in use, so I had to
>>>>> set vm.max_map_count to 1100000 to avoid -ENOMEM.
>>>>>
>>>>> Before:		23.3 ( +-  4.31% ) seconds
>>>>> After:		43.9 ( +-  0.85% ) seconds
>>>>> Slowdown:	1.88x
>>>>>
>>>>> I believe we can live with that.
>>>>>
>>> There's still all the special-case goop around the place to be cleaned
>>> up - VM_NONLINEAR is a decent search term.  As is "grep nonlinear
>>> mm/*.c".  And although this cleanup is the main reason for the
>>> patchset, let's not do it now - we can do all that if/after this patch
>>> get merged.
>>>
>>> I'll queue the patches for some linux-next exposure and shall send
>>> [1/2] Linuswards for 3.16 if nothing terrible happens.  Once we've
>>> sorted out the too-many-vmas issue we'll need to work out when to merge
>>> [2/2].
>>
>> It seems that since no one is really using it, it's also impossible to
>> properly test it. I've sent a fix that deals with panics in error paths
>> that are very easy to trigger, but I'm worried that there are a lot more
>> of those hiding over there.
> 
> Sorry for that.
> 
>> Since we can't find any actual users, testing suites are very incomplete
>> w.r.t this syscall, and the amount of work required to "remove" it is
>> non-trivial, can we just kill this syscall off?
>>
>> It sounds to me like a better option than to ship a new, buggy and possibly
>> security dangerous version which we can't even test.
> 
> Taking into account your employment, is it possible to check how the RDBMS
> (old but it still supported 32-bit versions) would react on -ENOSYS here?

Alrighty, I got an answer:

1. remap_file_pages() only works when the "VLM" feature of the db is enabled,
so those databases can work just fine without it, but be limited to 3-4GB of
memory. This is not needed at all on 64bit machines.

2. As of OL7 (kernel 3.8), there will not be a 32bit kernel build. I'm still
waiting for an answer whether there will do a 32bit DB build for a 64bit kernel,
but that never happened before and seems unlikely.

3. They're basically saying that by the time upstream releases a kernel without
remap_file_pages() no one will need it here.

To sum it up, they're fine with removing remap_file_pages().


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
