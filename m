Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6986B025E
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 04:42:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l124so42949970wml.4
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 01:42:51 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id ui11si24073763wjb.278.2016.11.06.01.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Nov 2016 01:42:49 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id c17so11106357wmc.3
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 01:42:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87lgwxo5u9.fsf@tassilo.jf.intel.com>
References: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com> <87lgwxo5u9.fsf@tassilo.jf.intel.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sun, 6 Nov 2016 10:42:49 +0100
Message-ID: <CAMJBoFNWV92c5B3HLJ=6wgNNUJFpTUgu3qf1mWgYxTEhfaA_LA@mail.gmail.com>
Subject: Re: [PATCH/RFC] z3fold: use per-page read/write lock
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Nov 6, 2016 at 12:38 AM, Andi Kleen <andi@firstfloor.org> wrote:
> Vitaly Wool <vitalywool@gmail.com> writes:
>
>> Most of z3fold operations are in-page, such as modifying z3fold
>> page header or moving z3fold objects within a page. Taking
>> per-pool spinlock to protect per-page objects is therefore
>> suboptimal, and the idea of having a per-page spinlock (or rwlock)
>> has been around for some time. However, adding one directly to the
>> z3fold header makes the latter quite big on some systems so that
>> it won't fit in a signle chunk.
>
>> +     atomic_t page_lock;
>
> This doesnt make much sense. A standard spinlock is not bigger
> than 4 bytes either. Also reinventing locks is usually a bad
> idea: they are tricky to get right, you have no debugging support,
> hard to analyze, etc.

I understand the reinvention part but you're not quite accurate here
with the numbers.

E. g. on x86_64:
(gdb) p sizeof(rwlock_t)
$1 = 8

I believe a DIY lock is justified here, since the variant with
rwlock_t actually caused complaints from kbuild test robot building
the previous version of this patch [1] with gcc-6.0 for x86_64:

 In file included from arch/x86/include/asm/atomic.h:4:0,
                    from include/linux/atomic.h:4,
                    from mm/z3fold.c:25:
   mm/z3fold.c: In function 'init_z3fold':
>> include/linux/compiler.h:518:38: error: call to '__compiletime_assert_808' declared with attribute error: BUILD_BUG_ON failed: sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED

~vitaly

[1] https://patchwork.kernel.org/patch/9384871/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
