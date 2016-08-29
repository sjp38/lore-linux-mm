Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2051F830E7
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:43:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so302777454pfg.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:43:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id gg3si39021398pac.136.2016.08.29.05.43.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 05:43:10 -0700 (PDT)
Date: Mon, 29 Aug 2016 15:42:33 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm: use-after-free in collapse_huge_page
Message-ID: <20160829124233.GA40092@black.fi.intel.com>
References: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Sun, Aug 28, 2016 at 12:42:21PM +0200, Dmitry Vyukov wrote:
> Hello,
> 
> I've git the following use-after-free in collapse_huge_page while
> running syzkaller fuzzer. It is in khugepaged, so not reproducible. On
> commit 61c04572de404e52a655a36752e696bbcb483cf5 (Aug 25).
> 
> ==================================================================
> BUG: KASAN: use-after-free in collapse_huge_page+0x28b1/0x3500 at addr
> ffff88006c731388
> Read of size 8 by task khugepaged/1327
> CPU: 0 PID: 1327 Comm: khugepaged Not tainted 4.8.0-rc3+ #33
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffffffff884b8280 ffff88003c207920 ffffffff82d1b239 ffffffff89ec1520
>  fffffbfff1097050 ffff88003e94c700 ffff88006c731300 ffff88006c7313c0
>  0000000000000000 ffff88003c207b88 ffff88003c207948 ffffffff817da1fc
> Call Trace:
>  [<ffffffff817da82e>] __asan_report_load8_noabort+0x3e/0x40
> mm/kasan/report.c:322
>  [<ffffffff817ff651>] collapse_huge_page+0x28b1/0x3500 mm/khugepaged.c:1004

Okay, I think the patch below should do the trick. Build tested only.

Andrea, Ebru, could you re-check if it's reasonable.
