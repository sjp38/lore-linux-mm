Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B32D8440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 14:26:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i5so2566820pfe.15
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:26:37 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u186si6706206pgb.578.2017.11.09.11.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 11:26:36 -0800 (PST)
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
Date: Thu, 9 Nov 2017 11:26:34 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/09/2017 11:04 AM, Andy Lutomirski wrote:
> On Wed, Nov 8, 2017 at 11:47 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> The VSYSCALL page is mapped by kernel page tables at a kernel address.
>> It is troublesome to support with KAISER in place, so disable the
>> native case.
>>
>> Also add some help text about how KAISER might affect the emulation
>> case as well.
> 
> Can you re-explain why this is helpful?

How about this?

The KAISER code attempts to "poison" the user portion of the kernel page
tables.  It detects the entries pages that it wants that it wants to
poison in two ways:
 * Looking for addresses >= PAGE_OFFSET
 * Looking for entries without _PAGE_USER set

But, to allow the _PAGE_USER check to work, we stopped it from being
set on all init_mm entries.

The VDSO is at a address >= PAGE_OFFSET and it is also mapped by the
init_mm.  The fact that we remove _PAGE_USER from the page tables makes
it unreadable to userspace.

This makes the "NATIVE" case totally unusable since userspace can not
even see the memory any more.  Disable it whenever KAISER is enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
