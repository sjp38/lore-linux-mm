Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7BFA6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 16:06:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so351989839pgd.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 13:06:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 8si49421804pfu.111.2016.12.13.13.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 13:06:36 -0800 (PST)
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161209050130.GC2595@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a2f86495-b55f-fda0-40d2-242c45d3c1f3@intel.com>
Date: Tue, 13 Dec 2016 13:06:35 -0800
MIME-Version: 1.0
In-Reply-To: <20161209050130.GC2595@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/08/2016 09:01 PM, Ingo Molnar wrote:
>> >   - Handle opt-in wider address space for userspace.
>> > 
>> >     Not all userspace is ready to handle addresses wider than current
>> >     47-bits. At least some JIT compiler make use of upper bits to encode
>> >     their info.
>> > 
>> >     We need to have an interface to opt-in wider addresses from userspace
>> >     to avoid regressions.
>> > 
>> >     For now, I've included testing-only patch which bumps TASK_SIZE to
>> >     56-bits. This can be handy for testing to see what breaks if we max-out
>> >     size of virtual address space.
> So this is just a detail - but it sounds a bit limiting to me to provide an 'opt 
> in' flag for something that will work just fine on the vast majority of 64-bit 
> software.

MPX is going to be a real pain here.  It is relatively transparent to
applications that use it, and old MPX binaries are entirely incompatible
with the new address space size, so an opt-out wouldn't be friendly.

Because the top-level MPX bounds table is indexed by the virtual
address, a growth in vaddr space is going to require the table to grow
(or change somehow).  The solution baked into the hardware spec is to
just make the top-level table 512x larger to accommodate the 512x
increase in vaddr space.  (This behavior is controlled by a new MSR, btw...)

So, either we disable MPX on all old MPX binaries by returning an error
when the prctl() tries to enable MPX and 5-level paging is on, or we go
with some form of an opt-in.  New MPX binaries will opt-in to the larger
address space since they know to allocate the new, larger table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
