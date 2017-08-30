Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24DB26B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:55:42 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t13so22761593qtc.7
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:55:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a10si6327528qtb.304.2017.08.30.13.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 13:55:41 -0700 (PDT)
Date: Wed, 30 Aug 2017 22:55:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170830205538.GH13559@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
 <20170830182013.GD2386@redhat.com>
 <180A2625-E3AB-44BF-A3B7-E687299B9DA9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <180A2625-E3AB-44BF-A3B7-E687299B9DA9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 11:40:08AM -0700, Nadav Amit wrote:
> The mmu_notifier users would have to be aware that invalidations may be
> deferred. If they perform their ``invalidationsa??a?? unconditionally, it may be
> ok. If the notifier users avoid invalidations based on the PTE in the
> secondary page-table, it can be a problem.

invalidate_page was always deferred post PT lock release.

This ->invalidate_range post PT lock release, is not a new thing,
we're still back to squre one to find out if invalidate_page callout
after PT lock release has always been broken here or not.

> On another note, you may want to consider combining the secondary page-table
> mechanisms with the existing TLB-flush mechanisms. Right now, it is
> partially done: tlb_flush_mmu_tlbonly(), for example, calls
> mmu_notifier_invalidate_range(). However, tlb_gather_mmu() does not call
> mmu_notifier_invalidate_range_start().

If you implement ->invalidate_range_start you don't care about tlb
gather at all and you must not implement ->invalidate_range.

> This can also prevent all kind of inconsistencies, and potential bugs. For
> instance, clear_refs_write() calls mmu_notifier_invalidate_range_start/end()
> but in between there is no call for mmu_notifier_invalidate_range().

It's done in mmu_notifier_invalidate_range_end which is again fully
equivalent except run after PT lock release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
