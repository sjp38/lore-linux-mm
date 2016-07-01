Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE9036B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 18:29:08 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id v190so314302508vka.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 15:29:08 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 202si1274479vkp.191.2016.07.01.15.29.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 15:29:07 -0700 (PDT)
Message-ID: <1467412092.7422.56.camel@kernel.crashing.org>
Subject: Re: [PATCH 0/4] [RFC][v4] Workaround for Xeon Phi PTE A/D bits
 erratum
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 02 Jul 2016 08:28:12 +1000
In-Reply-To: <20160701174658.6ED27E64@viggo.jf.intel.com>
References: <20160701174658.6ED27E64@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com

On Fri, 2016-07-01 at 10:46 -0700, Dave Hansen wrote:
> The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
> Landing) has an erratum where a processor thread setting the Accessed
> or Dirty bits may not do so atomically against its checks for the
> Present bit.A  This may cause a thread (which is about to page fault)
> to set A and/or D, even though the Present bit had already been
> atomically cleared.

Interesting.... I always wondered where in the Intel docs did it specify
that present was tested atomically with setting of A and D ... I couldn't
find it.

Isn't there a more fundamental issue however that you may actually lose
those bits ? For example if we do an munmap, in zap_pte_range()

We first exchange all the PTEs with 0 with ptep_get_and_clear_full()
and we then transfer D that we just read into the struct page.

We rely on the fact that D will never be set again, what we go it a
"final" D bit. IE. We rely on the fact that a processor either:

   - Has a cached PTE in its TLB with D set, in which case it can still
write to the page until we flush the TLB or

   - Doesn't have a cached PTE in its TLB with D set and so will fail
to do so due to the atomic P check, thus never writing.

With the errata, don't you have a situation where a processor in the second
category will write and set D despite P having been cleared (due to the
race) and thus causing us to miss the transfer of that D to the struct
page and essentially completely miss that the physical page is dirty ?

(Leading to memory corruption).

> If the PTE is used for storing a swap index or a NUMA migration index,
> the A bit could be misinterpreted as part of the swap type.A  The stray
> bits being set cause a software-cleared PTE to be interpreted as a
> swap entry.A  In some cases (like when the swap index ends up being
> for a non-existent swapfile), the kernel detects the stray value
> and WARN()s about it, but there is no guarantee that the kernel can
> always detect it.
> 
> This patch changes the kernel to attempt to ignore those stray bits
> when they get set.A  We do this by making our swap PTE format
> completely ignore the A/D bits, and also by ignoring them in our
> pte_none() checks.
> 
> Andi Kleen wrote the original version of this patch.A  Dave Hansen
> wrote the later ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
