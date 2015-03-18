Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 804A16B006C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:08:45 -0400 (EDT)
Received: by igbue6 with SMTP id ue6so104347965igb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:08:45 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id sd3si2455575igb.32.2015.03.18.09.08.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 09:08:44 -0700 (PDT)
Received: by iegc3 with SMTP id c3so42802571ieg.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:08:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150317220840.GC28621@dastard>
References: <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
	<20150309191943.GF26657@destitution>
	<CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
	<20150312131045.GE3406@suse.de>
	<CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
	<20150312184925.GH3406@suse.de>
	<20150317070655.GB10105@dastard>
	<CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
	<20150317205104.GA28621@dastard>
	<CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
	<20150317220840.GC28621@dastard>
Date: Wed, 18 Mar 2015 09:08:44 -0700
Message-ID: <CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 17, 2015 at 3:08 PM, Dave Chinner <david@fromorbit.com> wrote:
>>
>> Damn. From a performance number standpoint, it looked like we zoomed
>> in on the right thing. But now it's migrating even more pages than
>> before. Odd.
>
> Throttling problem, like Mel originally suspected?

That doesn't much make sense for the original bisect you did, though.

Although if there are two different issues, maybe that bisect was
wrong. Or rather, incomplete.

>> Can you do a simple stupid test? Apply that commit 53da3bc2ba9e ("mm:
>> fix up numa read-only thread grouping logic") to 3.19, so that it uses
>> the same "pte_dirty()" logic as 4.0-rc4. That *should* make the 3.19
>> and 4.0-rc4 numbers comparable.
>
> patched 3.19 numbers on this test are slightly worse than stock
> 3.19, but nowhere near as bad as 4.0-rc4:
>
>         241,718      migrate:mm_migrate_pages           ( +-  5.17% )

Ok, that's still much worse than plain 3.19, which was ~55,000.
Assuming your memory/measurements were the same.

So apparently the pte_write() -> pte_dirty() check isn't equivalent at
all. My thinking that for the common case (ie private mappings) it
would be *exactly* the same, because all normal COW pages turn dirty
at the same time they turn writable (and, in page_mkclean_one(), turn
clean and read-only again at the same time). But if the numbers change
that much, then clearly my simplistic "they are the same in practice"
is just complete BS.

So why am I wrong? Why is testing for dirty not the same as testing
for writable?

I can see a few cases:

 - your load has lots of writable (but not written-to) shared memory,
and maybe the test should be something like

      pte_dirty(pte) || (vma->vm_flags & (VM_WRITE|VM_SHARED) ==
(VM_WRITE|VM_SHARED))

   and we really should have some helper function for this logic.

 - something completely different that I am entirely missing

What am I missing?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
