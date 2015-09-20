Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 830146B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 04:56:00 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so75741518wic.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 01:55:59 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id q11si9628089wiw.60.2015.09.20.01.55.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 01:55:58 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so75741149wic.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 01:55:58 -0700 (PDT)
Date: Sun, 20 Sep 2015 10:55:54 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20150920085554.GA21906@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150916174913.AF5FEA6D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Dave Hansen <dave@sr71.net> wrote:

> +Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature
> +which will be found on future Intel CPUs.
> +
> +Memory Protection Keys provides a mechanism for enforcing page-based
> +protections, but without requiring modification of the page tables
> +when an application changes protection domains.  It works by
> +dedicating 4 previously ignored bits in each page table entry to a
> +"protection key", giving 16 possible keys.

Wondering how user-space is supposed to discover the number of protection keys,
is that CPUID leaf based, or hardcoded on the CPU feature bit?

> +There is also a new user-accessible register (PKRU) with two separate
> +bits (Access Disable and Write Disable) for each key.  Being a CPU
> +register, PKRU is inherently thread-local, potentially giving each
> +thread a different set of protections from every other thread.
> +
> +There are two new instructions (RDPKRU/WRPKRU) for reading and writing
> +to the new register.  The feature is only available in 64-bit mode,
> +even though there is theoretically space in the PAE PTEs.  These
> +permissions are enforced on data access only and have no effect on
> +instruction fetches.

Another question, related to enumeration as well: I'm wondering whether there's 
any way for the kernel to allocate a bit or two for its own purposes - such as 
protecting crypto keys? Or is the facility fundamentally intended for user-space 
use only?

Just a quick example: let's assume the kernel has an information leak hole, a way 
to read any kernel address and pass that to the kernel attacker. Let's also assume 
that the main crypto-keys of the kernel are protected by protection-keys. The code 
exposing the information leak will very likely have protection-key protected areas 
masked out, so the scope of the information leak is mitigated to a certain degree, 
the crypto keys are not readable.

Similarly, the pmem (persistent memory) driver could employ protection keys to 
keep terabytes of data 'masked out' most of the time - protecting data from kernel 
space memory corruption bugs.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
