Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8816B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 13:24:41 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s21so776861oie.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:24:41 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id k5si4987648oif.132.2017.08.07.10.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 10:24:40 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id x3so10412923oia.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:24:40 -0700 (PDT)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 7 Aug 2017 19:24:19 +0200
Message-ID: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
Subject: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, danielmicay@gmail.com, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
Cc: Kostya Serebryany <kcc@google.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

Hello,

The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
https://github.com/torvalds/linux/commit/eab09532d40090698b05a07c1c87f39fdbc5fab5
breaks user-space AddressSanitizer. AddressSanitizer makes assumptions
about address space layout for substantial performance gains. There
are multiple people complaining about this already:
https://github.com/google/sanitizers/issues/837
https://twitter.com/kayseesee/status/894594085608013825
https://bugzilla.kernel.org/show_bug.cgi?id=196537
AddressSanitizer maps shadow memory at [0x00007fff7000-0x10007fff7fff]
expecting that non-pie binaries will be below 2GB and pie
binaries/modules will be at 0x55 or 0x7f. This is not the first time
kernel address space shuffling breaks sanitizers. The last one was the
move to 0x55.

Is it possible to make this change less aggressive and keep the
executable under 2GB?

In future please be mindful of user-space sanitizers and talk to
address-sanitizer@googlegroups.com before shuffling address space.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
