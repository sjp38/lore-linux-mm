Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 742C88E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 21:29:05 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id x18-v6so2910746lji.0
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 18:29:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor8124428lfi.3.2018.12.22.18.29.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Dec 2018 18:29:03 -0800 (PST)
Subject: Re: [PATCH 03/12] __wr_after_init: generic header
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-4-igor.stoppa@huawei.com>
 <8474D7CA-E5FF-40B1-9428-855854CDDB5F@gmail.com>
 <20181221194547.GI10600@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <6562ebd3-e97d-41c4-261a-9f4b863118eb@gmail.com>
Date: Sun, 23 Dec 2018 04:28:59 +0200
MIME-Version: 1.0
In-Reply-To: <20181221194547.GI10600@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 21/12/2018 21:45, Matthew Wilcox wrote:
> On Fri, Dec 21, 2018 at 11:38:16AM -0800, Nadav Amit wrote:
>>> On Dec 19, 2018, at 1:33 PM, Igor Stoppa <igor.stoppa@gmail.com> wrote:
>>>
>>> +static inline void *wr_memset(void *p, int c, __kernel_size_t len)
>>> +{
>>> +	return __wr_op((unsigned long)p, (unsigned long)c, len, WR_MEMSET);
>>> +}
>>
>> What do you think about doing something like:
>>
>> #define __wr          __attribute__((address_space(5)))
>>
>> And then make all the pointers to write-rarely memory to use this attribute?
>> It might require more changes to the code, but can prevent bugs.
> 
> I like this idea.  It was something I was considering suggesting.

I have been thinking about this sort of problem, although from a bit 
different angle:

1) enforcing alignment for pointers
This can be implemented in similar way, by creating a multi-attribute 
that would define section, address space, like said here, and alignment.
However I'm not sure if it's possible to do anything to enforce the 
alignment of a pointer field within a structure. I haven't had time to 
look into this yet.

2) validation of the correctness of the actual value
Inside the kernel code, a function is not supposed to sanitize its 
arguments, as long as they come from some other trusted part of the 
kernel, rather than say from userspace or from some HW interface.
However,ROP/JOP should be considered.

I am aware of various efforts to make it harder to exploit these 
techniques, like signed pointers, CFI plugins, LTO.

But they are not necessarily available on every platform and mostly, 
afaik, they focus on specific type of attacks.


LTO can help with global optimizations, for example inlining functions 
across different objects.

CFI can detect jumps in the middle of a function, rather than proper 
function invocation, from its natural entry point.

Signed pointers can prevent data-based attacks to the execution flow, 
and they might have a role in preventing the attack I have in mind, but 
they are not available on all platforms.

What I'd like to do, is to verify, at runtime, that the pointer belongs 
to the type that the receiving function is meant for.

Ex: a legitimate __wr_after_init data must exist between 
__start_wr_after_init and __end_wr_after_init

That is easier and cleaner to test, imho.

But dynamically allocated memory doesn't have any such constraint.
If it was possible to introduce, for example, a flag to pass to vmalloc, 
to get the vmap_area from within a specific address range, it would 
reduce the attack surface.

In the implementation I have right now, I'm using extra flags for the 
pmalloc pages, which means the metadata is the new target for an attack.

But with adding the constraint that a dynamically allocated protected 
memory page must be within a range, then the attacker must change the 
underlying PTE. And if a region of PTEs are all part of protected 
memory, it is possible to make the PMD write rare.

--
igor
