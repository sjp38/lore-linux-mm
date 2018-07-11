Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4226B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:17:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q21-v6so17131876pff.4
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:17:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9-v6sor3154939pfb.38.2018.07.11.15.17.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 15:17:44 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:17:42 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [2/2] mm: Drop unneeded ->vm_ops checks
Message-ID: <20180711221742.GA9360@roeck-us.net>
References: <20180710134821.84709-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710134821.84709-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Tue, Jul 10, 2018 at 04:48:21PM +0300, Kirill A. Shutemov wrote:
> We now have all VMAs with ->vm_ops set and don't need to check it for
> NULL everywhere.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

This patch causes two of my qemu tests to fail:
	arm:mps2-an385:mps2_defconfig:mps2-an385
	xtensa:de212:kc705-nommu:nommu_kc705_defconfig

Both are nommu configurations.

Reverting the patch fixes the problem. Bisect log is attached for reference.

Guenter

---
# bad: [98be45067040799a801e6ce52d8bf4659a153893] Add linux-next specific files for 20180711
# good: [1e4b044d22517cae7047c99038abb444423243ca] Linux 4.18-rc4
git bisect start 'HEAD' 'v4.18-rc4'
# good: [ade30e73739a5174bcaee5860fee76c2365548c5] Merge remote-tracking branch 'crypto/master'
git bisect good ade30e73739a5174bcaee5860fee76c2365548c5
# good: [792be221c35d19a1c486789e5b5c91c05279b94d] Merge remote-tracking branch 'tip/auto-latest'
git bisect good 792be221c35d19a1c486789e5b5c91c05279b94d
# good: [1d66737ba99400ab9a79c906a25b2090f4cc8b18] Merge remote-tracking branch 'mux/for-next'
git bisect good 1d66737ba99400ab9a79c906a25b2090f4cc8b18
# good: [c02d5416bd8504866dd80d2129f4648747166b6f] Merge remote-tracking branch 'kspp/for-next/kspp'
git bisect good c02d5416bd8504866dd80d2129f4648747166b6f
# bad: [1e741337a9416010a48c6034855e316ba8057111] ntb: ntb_hw_switchtec: cleanup 64bit IO defines to use the common header
git bisect bad 1e741337a9416010a48c6034855e316ba8057111
# good: [205a106bac127145a4defae7d0d35945001fe924] kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN
git bisect good 205a106bac127145a4defae7d0d35945001fe924
# good: [e87ebebf76c9ceeaea21a256341d6765c657e550] mm, oom: remove sleep from under oom_lock
git bisect good e87ebebf76c9ceeaea21a256341d6765c657e550
# bad: [1f927d8f894e116af625b2326b355f5292c89d2b] mm/page_owner: align with pageblock_nr pages
git bisect bad 1f927d8f894e116af625b2326b355f5292c89d2b
# bad: [cc8ce33f3475478af93a876e0cf4a99eabbe49e9] mm: revert mem_cgroup_put() introduction
git bisect bad cc8ce33f3475478af93a876e0cf4a99eabbe49e9
# bad: [1f989b6a333fc8d6bddd1552420bb97e3295468a] list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
git bisect bad 1f989b6a333fc8d6bddd1552420bb97e3295468a
# bad: [0454d28f4858b6c8b2606417d35e4e6868699130] mm, swap: fix race between swapoff and some swap operations
git bisect bad 0454d28f4858b6c8b2606417d35e4e6868699130
# bad: [7efeddad4bc281bf61f411a7fe9b19f3689cf62f] mm, swap: fix race between swapoff and some swap operations
git bisect bad 7efeddad4bc281bf61f411a7fe9b19f3689cf62f
# bad: [4a110365f1da9d5cabbd0a01796027c0a6d5e80b] mm: drop unneeded ->vm_ops checks
git bisect bad 4a110365f1da9d5cabbd0a01796027c0a6d5e80b
# first bad commit: [4a110365f1da9d5cabbd0a01796027c0a6d5e80b] mm: drop unneeded ->vm_ops checks
