Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEAD06B0005
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 20:19:11 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so60345402pat.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 17:19:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pw6si788147pab.161.2016.07.07.17.19.10
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 17:19:10 -0700 (PDT)
Subject: [PATCH 0/4] [RFC][v4] Workaround for Xeon Phi PTE A/D bits erratum
From: Dave Hansen <dave@sr71.net>
Date: Thu, 07 Jul 2016 17:19:09 -0700
Message-Id: <20160708001909.FB2443E2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, dave.hansen@intel.com, Dave Hansen <dave@sr71.net>

This patch survived a bunch of testing over the past week, including
on hardware affected by the issue.  A debugging patch showed the
"stray" bits being set, and no ill effects were noticed.

Barring any heartburn from folks, I think this is ready for the tip
tree.

--

The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
Landing) has an erratum where a processor thread setting the Accessed
or Dirty bits may not do so atomically against its checks for the
Present bit.  This may cause a thread (which is about to page fault)
to set A and/or D, even though the Present bit had already been
atomically cleared.

These bits are truly "stray".  In the case of the Dirty bit, the
thread associated with the stray set was *not* allowed to write to
the page.  This means that we do not have to launder the bit(s); we
can simply ignore them.

More details can be found in the "Specification Update" under "KNL4":

	http://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/xeon-phi-processor-specification-update.pdf

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
