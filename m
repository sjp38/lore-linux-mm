Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB97B6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 15:49:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so1416601018pgc.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:49:45 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m14si47274502pgd.277.2017.01.05.12.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 12:49:44 -0800 (PST)
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
 <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
 <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
Date: Thu, 5 Jan 2017 12:49:44 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 01/05/2017 12:14 PM, Andy Lutomirski wrote:
>> I'm not sure I'm comfortable with this.  Do other rlimit changes cause
>> silent data corruption?  I'm pretty sure doing this to MPX would.
>>
> What actually goes wrong in this case?  That is, what combination of
> MPX setup of subsequent allocations will cause a problem, and is the
> problem worse than just a segfault?  IMO it would be really nice to
> keep the messy case confined to MPX.

The MPX bounds tables are indexed by virtual address.  They need to grow
if the virtual address space grows.   There's an MSR that controls
whether we use the 48-bit or 57-bit layout.  It basically decides
whether we need a 2GB (48-bit) or 1TB (57-bit) bounds directory.

The question is what we do with legacy MPX applications.  We obviously
can't let them just allocate a 2GB table and then go let the hardware
pretend it's 1TB in size.  We also can't hand the hardware using a 2GB
table an address >48-bits.

Ideally, I'd like to make sure that legacy MPX can't be enabled if this
RLIMIT is set over 48-bits (really 47).  I'd also like to make sure that
legacy MPX is active, that the RLIMIT can't be raised because all hell
will break loose when the new addresses show up.

Remember, we already have (legacy MPX) binaries in the wild that have no
knowledge of this stuff.  So, we can implicitly have the kernel bump
this rlimit around, but we can't expect userspace to do it, ever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
