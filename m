Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7096B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:45:16 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 9so100664608qkk.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:45:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a85si661743qkc.136.2017.03.02.05.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 05:45:15 -0800 (PST)
Date: Thu, 2 Mar 2017 21:45:13 +0800
From: Xiong Zhou <xzhou@redhat.com>
Subject: Re: [PATCH 0/2] fix for direct-I/O to DAX mappings
Message-ID: <20170302134513.zwkfse3j3vjhzy55@XZHOUW.usersys.redhat.com>
References: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, x86@kernel.org, Xiong Zhou <xzhou@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sat, Feb 25, 2017 at 09:08:28AM -0800, Dan Williams wrote:
> Hi Andrew,
> 
> While Ross was doing a review of a new mmap+DAX direct-I/O test case for
> xfstests, from Xiong, he noticed occasions where it failed to trigger a
> page dirty event.  Dave then spotted the problem fixed by patch1. The
> pte_devmap() check is precluding pte_allows_gup(), i.e. bypassing
> permission checks and dirty tracking.

This mmap-dax-dio case still fails with this patchset, while it makes
sense. It's the test case that need to be fixed.

BTW, this patchset fixes another xfsrestore issue, which i hit now
and then, xfs/301 w/ or wo/ DAX only on nvdimms. xfsrestore never
return but killable.

Thanks,
> 
> Patch2 is a cleanup and clarifies that pte_unmap() only needs to be done
> once per page-worth of ptes. It unifies the exit paths similar to the
> generic gup_pte_range() in the __HAVE_ARCH_PTE_SPECIAL case.
> 
> I'm sending this through the -mm tree for a double-check from memory
> management folks. It has a build success notification from the kbuild
> robot.
> 
> ---
> 
> Dan Williams (2):
>       x86, mm: fix gup_pte_range() vs DAX mappings
>       x86, mm: unify exit paths in gup_pte_range()
> 
> 
>  arch/x86/mm/gup.c |   37 +++++++++++++++++++++----------------
>  1 file changed, 21 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
