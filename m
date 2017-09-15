Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE4626B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:47:01 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j26so5705355iod.5
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 04:47:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor315726oif.228.2017.09.15.04.47.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 04:47:00 -0700 (PDT)
MIME-Version: 1.0
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Fri, 15 Sep 2017 14:46:19 +0300
Message-ID: <CAGqmi75hqVN7YKopWFUdB1=PKMwrvTRTWVJCtfnWHJCz3Zj09w@mail.gmail.com>
Subject: RFC: replace jhash2 with xxhash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi mm folks,
Recently xxhash has been added in kernel[1]

jhash2 for now (AFAIK) is a lookup3 Jenkins Hash,
in mm subsystem it's used in 2 places:
ksm.c      [2] - for hashing pages
hugetlb.c [3] - hash 4/8 byte value pairs.

I do some reverse porting to userspace (i'm hard to test performance
of that hashes in kernel)
xxhash useless for small keyvalue pairs (read as it's useless to touch
hugetlb.c),
but for PAGE_SIZE'ed data it's much faster

PAGE_SIZE: 4096, loop count: 1048576
jhash2:   0x12a1b130 perf: 1917 ms
xxhash64: 0x297821d3a9243df7 perf: 362 ms
xxhash32: 0xf46b3473 perf: 728 ms

PAGE_SIZE: 16384, loop count: 1048576
jhash2:   0xb73b6438 perf: 7644 ms
xxhash64: 0x360051a038cb61ca perf: 1477 ms
xxhash32: 0xe22e33b5 perf: 2939 ms

PAGE_SIZE: 65536, loop count: 1048576
jhash2:   0x20fb1308 perf: 32441 ms
xxhash64: 0x4a108bab621e8049 perf: 5872 ms
xxhash32: 0xe52eafe perf: 11727 ms

Test cpu: Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz

i.e. for KSM that's can make hash much faster, even
may be that make a sense to use 64bit hash if kernel compiled for 64bit target.

Thanks.

P.S.
I can write a patch if you found that useful

P.S.S.
I can push test code to GitHub and add link if needed

[1] For 4.14, commit 5d2405227a9eaea48e8cc95756a06d407b11f141
     https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?h=next-20170915&id=5d2405227a9eaea48e8cc95756a06d407b11f141
[2] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/ksm.c?h=v4.13#n989
[3] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/hugetlb.c?h=v4.13#n3813
-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
