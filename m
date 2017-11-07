Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25BAB6B0288
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:15:28 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id o126so7689891oif.21
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:15:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f20si279936oti.4.2017.11.07.00.15.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 00:15:27 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
 <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
 <20171106174707.19f6c495@roar.ozlabs.ibm.com>
 <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
 <20171106192524.12ea3187@roar.ozlabs.ibm.com>
 <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
 <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
 <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <b7348864-533a-ef40-e66f-b14d0f422c04@redhat.com>
Date: Tue, 7 Nov 2017 09:15:21 +0100
MIME-Version: 1.0
In-Reply-To: <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 11/07/2017 06:07 AM, Nicholas Piggin wrote:

> First of all, using addr and MAP_FIXED to develop our heuristic can
> never really give unchanged ABI. It's an in-band signal. brk() is a
> good example that steadily keeps incrementing address, so depending
> on malloc usage and address space randomization, you will get a brk()
> that ends exactly at 128T, then the next one will be >
> DEFAULT_MAP_WINDOW, and it will switch you to 56 bit address space.

Note that this brk phenomenon is only a concern for some currently 
obscure process memory layouts where the heap ends up at the top of the 
address space.  Usually, there is something above it which eliminates 
the possibility that it can cross into the 128 TiB wilderness.  So the 
brk problem only happens on some architectures (e.g., not x86-64), and 
only with strange ways of running programs (explicitly ld.so invocation 
and likely static PIE, too).

> So unless everyone else thinks I'm crazy and disagrees, I'd ask for
> a bit more time to make sure we get this interface right. I would
> hope for something like prctl PR_SET_MM which can be used to set
> our user virtual address bits on a fine grained basis. Maybe a
> sysctl, maybe a personality. Something out-of-band. I don't wan to
> get too far into that discussion yet. First we need to agree whether
> or not the code in the tree today is a problem.

There is certainly more demand for similar functionality, like creating 
mappings below 2 GB/4 GB/32 GB, and probably other bit patterns. 
Hotspot would use this to place the heap with compressed oops, instead 
of manually hunting for a suitable place for the mapping.  (Essentially, 
32-bit pointers on 64-bit architectures for sufficiently small heap 
sizes.)  It would perhaps be possible to use the hints address as a 
source of the bit count, for full flexibility.  And the mapping should 
be placed into the upper half of the selected window if possible.

MAP_FIXED is near-impossible to use correctly.  I hope you don't expect 
applications to do that.  If you want address-based opt in, it should 
work without MAP_FIXED.  Sure, in obscure cases, applications might 
still see out-of-range addresses, but I expected a full opt-out based on 
RLIMIT_AS would be sufficient for them.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
