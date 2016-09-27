Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99D1328024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:05:37 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id k17so6618722ywe.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:05:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r62si942788yba.281.2016.09.27.09.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 09:05:36 -0700 (PDT)
Date: Tue, 27 Sep 2016 18:05:29 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: BUG Re: mm: vma_merge: fix vm_page_prot SMP race condition
 against rmap_walk
Message-ID: <20160927160529.GJ4618@redhat.com>
References: <CAJ48U8XgWQZBFuWt2Gk_5JAXz3wONgd15OmBY0M-Urq+_VGe9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ48U8XgWQZBFuWt2Gk_5JAXz3wONgd15OmBY0M-Urq+_VGe9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaun Tancheff <shaun@tancheff.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Shaun Tancheff <shaun.tancheff@seagate.com>

Hello,

On Tue, Sep 27, 2016 at 05:16:15AM -0500, Shaun Tancheff wrote:
> git bisect points at commit  c9634dcf00c9c93b ("mm: vma_merge: fix
> vm_page_prot SMP race condition against rmap_walk")

I assume linux-next? But I can't find the commit, but I should know
what this is.

> 
> Last lines to console are [transcribed]:
> 
> vma ffff8c3d989a7c78 start 00007fe02ed4c000 end 00007fe02ed52000
> next ffff8c3d96de0c38 prev ffff8c3d989a6e40 mm ffff8c3d071cbac0
> prot 8000000000000025 anon_vma ffff8c3d96fc9b28 vm_ops           (null)
> pgoff 7fe02ed4c file           (null) private_data           (null)
> flags: 0x8100073(read|write|mayread|maywrite|mayexec|account|softdirty)

It's a false positive, you have DEBUG_VM_RB=y, you can disable it or
cherry-pick the fix:

https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=74d8b44224f31153e23ca8a7f7f0700091f5a9b2

The assumption validate_mm_rb did isn't valid anymore on the new code
during __vma_unlink, the validation code must be updated to skip the
next vma instead of the current one after this change. It's a bug in
DEBUG_VM_RB=y, if you keep DEBUG_VM_RB=n there's no bug.

> Reproducer is an Ubuntu 16.04.1 LTS x86_64 running on a VM (VirtualBox).
> Symptom is a solid hang after boot and switch to starting gnome session.
> 
> Hang at about 35s.
> 
> kdbg traceback is all null entries.
> 
> Let me know what additional information I can provide.

I already submitted the fix to Andrew last week:

https://marc.info/?l=linux-mm&m=147449253801920&w=2

I assume it's pending for merging in -mm.

If you can test this patch and confirm the problem goes away with
DEBUG_VM_RB=y it'd be great.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
