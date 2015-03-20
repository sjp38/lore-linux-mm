Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD446B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 21:29:48 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so81263910iec.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 18:29:47 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id z4si621003igl.6.2015.03.19.18.29.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 18:29:47 -0700 (PDT)
Received: by ignm3 with SMTP id m3so21352727ign.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 18:29:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150320002311.GG28621@dastard>
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
	<20150320002311.GG28621@dastard>
Date: Thu, 19 Mar 2015 18:29:47 -0700
Message-ID: <CA+55aFyqXDVv9JkkhvM26x6PC5V82corR7HQNxmkeGZjOCxD=A@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 19, 2015 at 5:23 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Bit more variance there than the pte checking, but runtime
> difference is in the noise - 5m4s vs 4m54s - and profiles are
> identical to the pte checking version.

Ahh, so that "!(vma->vm_flags & VM_WRITE)" test works _almost_ as well
as the original !pte_write() test.

Now, can you check that on top of rc4? If I've gotten everything
right, we now have:

 - plain 3.19 (pte_write): 4m54s
 - 3.19 with vm_flags & VM_WRITE: 5m4s
 - 3.19 with pte_dirty: 5m20s

so the pte_dirty version seems to have been a bad choice indeed.

For 4.0-rc4, (which uses pte_dirty) you had 7m50s, so it's still
_much_ worse, but I'm wondering whether that VM_WRITE test will at
least shrink the difference like it does for 3.19.

And the VM_WRITE test should be stable and not have any subtle
interaction with the other changes that the numa pte things
introduced. It would be good to see if the profiles then pop something
*else* up as the performance difference (which I'm sure will remain,
since the 7m50s was so far off).

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
