Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9C696B0038
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 16:48:51 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id f81so19476356oih.4
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:48:51 -0700 (PDT)
Received: from mail-ot0-x22c.google.com (mail-ot0-x22c.google.com. [2607:f8b0:4003:c0f::22c])
        by mx.google.com with ESMTPS id u188si8968883oig.318.2017.03.21.13.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 13:48:50 -0700 (PDT)
Received: by mail-ot0-x22c.google.com with SMTP id i1so159324463ota.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:48:50 -0700 (PDT)
MIME-Version: 1.0
From: Andrei Vagin <avagin@gmail.com>
Date: Tue, 21 Mar 2017 13:48:50 -0700
Message-ID: <CANaxB-wtxWcHyOV1gJRjWvAi88FitcTYQzDUAvwV23YyQX0X+w@mail.gmail.com>
Subject: linux-next: something wrong with 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Kirill,

We use travis-ci to test linux-next. We don't have access to virtual
machines or serial console logs there. And we found that
linux-next-20170320 doesn't boot. It's all information what we have
now.

Here are out logs:
https://travis-ci.org/avagin/criu/jobs/213276252
https://s3.amazonaws.com/archive.travis-ci.org/jobs/213276252/log.txt

I bisected this issue and here is the bisect log:
[avagin@laptop linux-next]$ git bisect log
# bad: [50eff530518ae89e25d09ec1aa41a7aea6a7d51c] Add linux-next
specific files for 20170321
# good: [97da3854c526d3a6ee05c849c96e48d21527606c] Linux 4.11-rc3
git bisect start 'HEAD' '97da3854c526d3a6ee05c849c96e48d21527606c'
# good: [445775520e021af86ee95b76eecca2df8203ce93] Merge
remote-tracking branch 'drm/drm-next'
git bisect good 445775520e021af86ee95b76eecca2df8203ce93
# bad: [9f18c54f1a491ed2ff42354352fa72949ce21622] Merge
remote-tracking branch 'usb-serial/usb-next'
git bisect bad 9f18c54f1a491ed2ff42354352fa72949ce21622
# good: [8a96989361a21261af9b33db7f0463e23e11af60] Merge
remote-tracking branch 'device-mapper/for-next'
git bisect good 8a96989361a21261af9b33db7f0463e23e11af60
# good: [86550c0919cab6e71fe3955d764f7b8fe7f6d203] Merge
remote-tracking branch 'spi/for-next'
git bisect good 86550c0919cab6e71fe3955d764f7b8fe7f6d203
# bad: [cb1341c192398fc727bdd9b2ac42c5b36d5bcb9e] Merge
remote-tracking branch 'tip/auto-latest'
git bisect bad cb1341c192398fc727bdd9b2ac42c5b36d5bcb9e
# good: [ad86b2388abbf931aacac1a5d0b022ad7a7dafe9] Merge branch 'perf/core'
git bisect good ad86b2388abbf931aacac1a5d0b022ad7a7dafe9
# good: [091c3e29ebd9400f96e4456cc882dd6af6991b8f] Merge branch 'x86/microcode'
git bisect good 091c3e29ebd9400f96e4456cc882dd6af6991b8f
# bad: [e93480537fd7ecaf5ed1a662a979376f6fee50e3] mm/gup: Mark all
pages PageReferenced in generic get_user_pages_fast()
git bisect bad e93480537fd7ecaf5ed1a662a979376f6fee50e3
# bad: [06c830a48346643e195801460dfe16d96ba4dff5] x86/power: Add
5-level paging support
git bisect bad 06c830a48346643e195801460dfe16d96ba4dff5
# good: [fe1e8c3e9634071ac608172e29bf997596d17c7c] x86/mm: Extend
headers with basic definitions to support 5-level paging
git bisect good fe1e8c3e9634071ac608172e29bf997596d17c7c
# good: [0318e5abe1c0933b8bf6763a1a0d3caec4f0826d] x86/mm/gup: Add
5-level paging support
git bisect good 0318e5abe1c0933b8bf6763a1a0d3caec4f0826d
# bad: [b50858ce3e2a25a7f4638464e857853fbfc81823] x86/mm/vmalloc: Add
5-level paging support
git bisect bad b50858ce3e2a25a7f4638464e857853fbfc81823
# bad: [ea3b5e60ce804403ca019039d6331368521348de] x86/mm/ident_map:
Add 5-level paging support
git bisect bad ea3b5e60ce804403ca019039d6331368521348de
# first bad commit: [ea3b5e60ce804403ca019039d6331368521348de]
x86/mm/ident_map: Add 5-level paging support

What we do in travis-ci:
* clone a kernel tree
* curl -o .config
https://raw.githubusercontent.com/avagin/criu/linux-next/scripts/linux-next-config
* make olddefconfig
* make localyesconfig
* kexec -l linux/arch/x86/boot/bzImage --command-line "root=/dev/sda1
cgroup_enable=memory swapaccount=1 apparmor=0 console=ttyS0
console=ttyS0 debug raid=noautodetect slub_debug=FZP"
* kexec -e

Thanks,
Andrei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
