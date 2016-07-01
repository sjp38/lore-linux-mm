Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6024A828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 13:47:04 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id cx13so167186pac.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 10:47:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id va9si4954169pac.186.2016.07.01.10.47.02
        for <linux-mm@kvack.org>;
        Fri, 01 Jul 2016 10:47:02 -0700 (PDT)
Subject: [PATCH 0/4] [RFC][v4] Workaround for Xeon Phi PTE A/D bits erratum
From: Dave Hansen <dave@sr71.net>
Date: Fri, 01 Jul 2016 10:46:58 -0700
Message-Id: <20160701174658.6ED27E64@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>

This is very lightly tested.  I haven't even run it on the affected
hardware.  Just sending it quickly in case someone can easily see
something fatally wrong with it.

This seems a lot less fragile than the previous patches that relied
on TLB flushing.  Those seemed like it would be easy to add new code
that hit this issue.

The new approach seems like it'll be harder to break.  The most
likely thing to break would be someone looking for a zero pte_val()
and seeing a stray bit.  But that seems like a better alternative
than the nastiness that could happen if one of these bits *is*
considered when reading a swap PTE.

--

The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
Landing) has an erratum where a processor thread setting the Accessed
or Dirty bits may not do so atomically against its checks for the
Present bit.  This may cause a thread (which is about to page fault)
to set A and/or D, even though the Present bit had already been
atomically cleared.

If the PTE is used for storing a swap index or a NUMA migration index,
the A bit could be misinterpreted as part of the swap type.  The stray
bits being set cause a software-cleared PTE to be interpreted as a
swap entry.  In some cases (like when the swap index ends up being
for a non-existent swapfile), the kernel detects the stray value
and WARN()s about it, but there is no guarantee that the kernel can
always detect it.

This patch changes the kernel to attempt to ignore those stray bits
when they get set.  We do this by making our swap PTE format
completely ignore the A/D bits, and also by ignoring them in our
pte_none() checks.

Andi Kleen wrote the original version of this patch.  Dave Hansen
wrote the later ones.

v4: complete rework: let the bad bits stay around, but try to
    ignore them
v3: huge rework to keep batching working in unmap case
v2: out of line. avoid single thread flush. cover more clear
    cases

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
