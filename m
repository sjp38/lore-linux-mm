Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEB706B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 16:04:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g80so75053347pfb.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:04:47 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v6si7636907plk.333.2017.02.17.13.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 13:04:47 -0800 (PST)
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and
 PR_GET_MAX_VADDR
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ae493a75-138c-9c01-d4a1-90bcd01d560f@intel.com>
Date: Fri, 17 Feb 2017 13:04:46 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On 02/17/2017 12:02 PM, Linus Torvalds wrote:
> So if you use MAP_FIXED and give an address in the high range, it will
> just always work, and the MM will always consider the task size to be
> the full address space.
> 
> But for the common case where a process does no use MAP_FIXED, the
> kernel will never give a high address by default, and you have to do
> the process control thing to say "I want those high addresses".
> 
> Hmm?

Assuming that folks tend to hard-code MAP_FIXED addresses, they'll be
<48 bits and everything will work splendidly.  But, if folks do
something like take the CPU-enumerated virtual address size and use that
as a starting point, I can see things breaking.

MPX would definitely break if the hardware saw one of those high
addresses and was not ready for it.  It ends up just chopping off the
high bits of the address, so:

	0x10000000000000
and
	0x20000000000000

index into the same spot in the bounds tables.  It does this unless you
put the hardware in the new mode that uses the larger tables, and
consumes more bits of the virtual address.

Is this likely to break anything in practice?  Nah.  But it would nice
to avoid it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
