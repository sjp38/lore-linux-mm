Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 61E536B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:34:11 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so104820135pad.3
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:34:11 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id pc2si34820222pbb.178.2015.09.20.21.34.09
        for <linux-mm@kvack.org>;
        Sun, 20 Sep 2015 21:34:09 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <55FF88BA.6080006@sr71.net>
Date: Sun, 20 Sep 2015 21:34:02 -0700
MIME-Version: 1.0
In-Reply-To: <20150920085554.GA21906@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 09/20/2015 01:55 AM, Ingo Molnar wrote:
> * Dave Hansen <dave@sr71.net> wrote:
>> +Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature
>> +which will be found on future Intel CPUs.
>> +
>> +Memory Protection Keys provides a mechanism for enforcing page-based
>> +protections, but without requiring modification of the page tables
>> +when an application changes protection domains.  It works by
>> +dedicating 4 previously ignored bits in each page table entry to a
>> +"protection key", giving 16 possible keys.
> 
> Wondering how user-space is supposed to discover the number of protection keys,
> is that CPUID leaf based, or hardcoded on the CPU feature bit?

The 16 keys are essentially hard-coded from the cpuid bit.

>> +There is also a new user-accessible register (PKRU) with two separate
>> +bits (Access Disable and Write Disable) for each key.  Being a CPU
>> +register, PKRU is inherently thread-local, potentially giving each
>> +thread a different set of protections from every other thread.
>> +
>> +There are two new instructions (RDPKRU/WRPKRU) for reading and writing
>> +to the new register.  The feature is only available in 64-bit mode,
>> +even though there is theoretically space in the PAE PTEs.  These
>> +permissions are enforced on data access only and have no effect on
>> +instruction fetches.
> 
> Another question, related to enumeration as well: I'm wondering whether there's 
> any way for the kernel to allocate a bit or two for its own purposes - such as 
> protecting crypto keys? Or is the facility fundamentally intended for user-space 
> use only?

No, that's not possible with the current setup.

Userspace has complete control over the contents of the PKRU register
with unprivileged instructions.  So the kernel can not practically
protect any of its own data with this.

> Similarly, the pmem (persistent memory) driver could employ protection keys to 
> keep terabytes of data 'masked out' most of the time - protecting data from kernel 
> space memory corruption bugs.

I wish we could do this, but we can not with the current implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
