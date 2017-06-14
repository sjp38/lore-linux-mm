Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 603386B02C3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:31:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v20so1654846qtg.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:31:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a20si252792qth.97.2017.06.14.08.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 08:31:38 -0700 (PDT)
Date: Wed, 14 Jun 2017 17:31:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm, thp: Do not loose dirty bit in
 __split_huge_pmd_locked()
Message-ID: <20170614153131.GC5847@redhat.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <20170614135143.25068-4-kirill.shutemov@linux.intel.com>
 <20170614161857.69d54338@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614161857.69d54338@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jun 14, 2017 at 04:18:57PM +0200, Martin Schwidefsky wrote:
> Could we change pmdp_invalidate to make it return the old pmd entry?

That to me seems the simplest fix to avoid losing the dirty bit.

I earlier suggested to replace pmdp_invalidate with something like
old_pmd = pmdp_establish(pmd_mknotpresent(pmd)) (then tlb flush could
then be conditional to the old pmd being present). Making
pmdp_invalidate return the old pmd entry would be mostly equivalent to
that.

The advantage of not changing pmdp_invalidate is that we could skip a
xchg which is more costly in __split_huge_pmd_locked and
madvise_free_huge_pmd so perhaps there's a point to keep a variant of
pmdp_invalidate that doesn't use xchg internally (and in turn can't
return the old pmd value atomically).

If we don't want new messy names like pmdp_establish we could have a
__pmdp_invalidate that returns void, and pmdp_invalidate that returns
the old pmd and uses xchg (and it'd also be backwards compatible as
far as the callers are concerned). So those places that don't need the
old value returned and can skip the xchg, could simply
s/pmdp_invalidate/__pmdp_invalidate/ to optimize.

One way or another for change_huge_pmd I think we need a xchg like in
native_pmdp_get_and_clear but that sets the pmd to
pmd_mknotpresent(pmd) instead of zero. And this whole issues
originates because both change_huge_pmd(prot_numa = 1) and
madvise_free_huge_pmd both run concurrently with the mmap_sem for
reading.

In the earlier email on this topic, I also mentioned the concern of
the _notify mmu notifier invalidate that got dropped silently with the
s/pmdp_huge_get_and_clear_notify/pmdp_invalidate/ conversion but I
later noticed the mmu notifier invalidate is already covered by the
caller. So change_huge_pmd should have called pmdp_huge_get_and_clear
in the first place and the _notify prefix in the old code was a
mistake as far as I can tell. So we can focus only on the dirty bit
retention issue.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
