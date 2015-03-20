Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFAA6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 20:23:29 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so90798968pad.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 17:23:29 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id am9si6169798pad.8.2015.03.19.17.23.27
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 17:23:28 -0700 (PDT)
Date: Fri, 20 Mar 2015 11:23:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150320002311.GG28621@dastard>
References: <20150317070655.GB10105@dastard>
 <CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
 <20150317205104.GA28621@dastard>
 <CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
 <20150317220840.GC28621@dastard>
 <CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
 <CA+55aFy-Mw74rAdLMMMUgnsG3ZttMWVNGz7CXZJY7q9fqyRYfg@mail.gmail.com>
 <CA+55aFyxA9u2cVzV+S7TSY9ZvRXCX=z22YAbi9mdPVBKmqgR5g@mail.gmail.com>
 <20150319224143.GI10105@dastard>
 <CA+55aFy5UeNnFUTi619cs3b9Up2NQ1wbuyvcCS614+o3=z=wBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy5UeNnFUTi619cs3b9Up2NQ1wbuyvcCS614+o3=z=wBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 19, 2015 at 04:05:46PM -0700, Linus Torvalds wrote:
> Can you try Mel's change to make it use
> 
>         if (!(vma->vm_flags & VM_WRITE))
> 
> instead of the pte details? Again, on otherwise plain 3.19, just so
> that we have a baseline. I'd be *so* much happer with checking the vma
> details over per-pte details, especially ones that change over the
> lifetime of the pte entry, and the NUMA code explicitly mucks with.

$ sudo perf_3.18 stat -a -r 6 -e migrate:mm_migrate_pages sleep 10

 Performance counter stats for 'system wide' (6 runs):

    266,750      migrate:mm_migrate_pages ( +-  7.43% )

	  10.002032292 seconds time elapsed ( +-  0.00% )

Bit more variance there than the pte checking, but runtime
difference is in the noise - 5m4s vs 4m54s - and profiles are
identical to the pte checking version.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
