Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE25B6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:47:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u62so1872422lfg.6
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:47:00 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 10si1422247ljt.12.2017.06.15.01.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 01:46:58 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id v20so713570lfa.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:46:58 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:46:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] mm, thp: Do not loose dirty bit in
 __split_huge_pmd_locked()
Message-ID: <20170615084656.bqevrlwtyyyxdbmd@node.shutemov.name>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <20170614135143.25068-4-kirill.shutemov@linux.intel.com>
 <20170614161857.69d54338@mschwideX1>
 <20170614153131.GC5847@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614153131.GC5847@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 14, 2017 at 05:31:31PM +0200, Andrea Arcangeli wrote:
> Hello,
> 
> On Wed, Jun 14, 2017 at 04:18:57PM +0200, Martin Schwidefsky wrote:
> > Could we change pmdp_invalidate to make it return the old pmd entry?
> 
> That to me seems the simplest fix to avoid losing the dirty bit.
> 
> I earlier suggested to replace pmdp_invalidate with something like
> old_pmd = pmdp_establish(pmd_mknotpresent(pmd)) (then tlb flush could
> then be conditional to the old pmd being present). Making
> pmdp_invalidate return the old pmd entry would be mostly equivalent to
> that.
> 
> The advantage of not changing pmdp_invalidate is that we could skip a
> xchg which is more costly in __split_huge_pmd_locked and
> madvise_free_huge_pmd so perhaps there's a point to keep a variant of
> pmdp_invalidate that doesn't use xchg internally (and in turn can't
> return the old pmd value atomically).
> 
> If we don't want new messy names like pmdp_establish we could have a
> __pmdp_invalidate that returns void, and pmdp_invalidate that returns
> the old pmd and uses xchg (and it'd also be backwards compatible as
> far as the callers are concerned). So those places that don't need the
> old value returned and can skip the xchg, could simply
> s/pmdp_invalidate/__pmdp_invalidate/ to optimize.

We have few pmdp_invalidate() callers:

 - clear_soft_dirty_pmd();
 - madvise_free_huge_pmd();
 - change_huge_pmd();
 - __split_huge_pmd_locked();

Only madvise_free_huge_pmd() doesn't care about old pmd.

__split_huge_pmd_locked() actually needs to check dirty after
pmdp_invalidate(), see patch 3/3 of the patchset.

I don't think it worth introduce one more primitive only for
madvise_free_huge_pmd().

I'll stick with single pmdp_invalidate() that returns old value.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
