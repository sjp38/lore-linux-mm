Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 011F9280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:14:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k126so12979847qkb.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:14:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p6si3682893qkb.53.2017.08.29.13.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:14:09 -0700 (PDT)
Date: Tue, 29 Aug 2017 16:14:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH] mm/rmap: do not call mmu_notifier_invalidate_page()
 v3
Message-ID: <20170829201404.GF7546@redhat.com>
References: <20170829190526.8767-1-jglisse@redhat.com>
 <CA+55aFy=+ipEWKYwckee7-QodyfwufejNq1WA3rSNUHKJiw+6g@mail.gmail.com>
 <CA+55aFynq_N8bYy2bKmp8eWnCbrFBpboeHCWJ92MF3zJ++V8og@mail.gmail.com>
 <CA+55aFywcw0S-5-SZPnbA6Z7QNqdZvxo8d6k1Txe6HEWKZ_pnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFywcw0S-5-SZPnbA6Z7QNqdZvxo8d6k1Txe6HEWKZ_pnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 29, 2017 at 12:58:45PM -0700, Linus Torvalds wrote:
> On Tue, Aug 29, 2017 at 12:16 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > And then you can check if something actually happened by catching the
> > *ATOMIC* call to mmu_notifier_invalidate_page(), setting a flag, and
> > then doing something blocking at mmu_notifier_invalidate_range_end()
> > time.
> >
> > Maybe.
> 
> Note that now I have looked more at the users, I think we actually
> just want to get rid of mmu_notifier_invalidate_page() entirely in
> favor of just calling mmu_notifier_invalidate_range_start()/end().
> 
> Nobody seems to want an atomic version of
> mmu_notifier_invalidate_page(), they are perfectly happy just getting
> those range_start/end() call instead.
> 
> HOWEVER.
> 
> There do seem to be places (eg powernv/npu-dma.c, iommu/amd_iommu_v2.c
> and ommu/intel-svm.c) that want to get the "invalidate_page()" or
> "invalidate_range()" calls, but do *not* catch the begin/end() ones.
> The "range" calls were for atomic cases, and the "page" call was for
> the few places that weren't (but should have been). They seem to do
> the same things.
> 
> So just switching from mmu_notifier_invalidate_page() to the
> "invalidate_range_start()/end()" pair instead could break those cases.
> 
> But the mmu_notifier_invalidate_range() call has always been atomic,
> afaik.  It's called from the ptep_clear_flush_notify(), which is
> called while holdin gthe ptl lock as far as I can tell.
> 
> So to handle the powernv/npu-dma.c, iommu/amd_iommu_v2.c and
> ommu/intel-svm.c correctly, _and_ get he KVM case right, we probably
> need to:
> 
>  - replace the existing mmu_notifier_invalidate_page() call with
> mmu_notifier_invalidate_range(), and make sure it's inside the locked
> region (ie fs/dax.c too - actually move it inside the lock)
> 
>  - surround the locked region with those
> mmu_notifier_invalidate_range_start()/end() calls.
> 
>  - get rid of mmu_notifier_invalidate_page() entirely, it had bad
> semantics anyway.
> 
> and from all I can tell that should work for everybody.
> 
> But maybe I'm missing something.
> 

So ignore what i just sent, i will rework it toward that direction.
I believe you are right.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
