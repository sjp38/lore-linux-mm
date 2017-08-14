Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 230386B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:50:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s21so10530563oie.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 01:50:26 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id x193si3973434oia.323.2017.08.14.01.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 01:50:25 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id q70so8704341oic.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 01:50:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com> <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Aug 2017 10:50:24 +0200
Message-ID: <CAK8P3a3ABsxTaS7ZdcWNbTx7j5wFRc0h=ZVWAC_h-E+XbFv+8Q@mail.gmail.com>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Boqun Feng <boqun.feng@gmail.com>, kirill@shutemov.name, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com

On Mon, Aug 7, 2017 at 9:12 AM, Byungchul Park <byungchul.park@lge.com> wrote:
> Although wait_for_completion() and its family can cause deadlock, the
> lock correctness validator could not be applied to them until now,
> because things like complete() are usually called in a different context
> from the waiting context, which violates lockdep's assumption.
>
> Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
> detector to those completion operations. Applied it.
>
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>

This patch introduced a significant growth in kernel stack usage for a small
set of functions. I see two new warnings for functions that get tipped over the
1024 or 2048 byte frame size limit in linux-next (with a few other patches
applied):

Before:

drivers/md/dm-integrity.c: In function 'write_journal':
drivers/md/dm-integrity.c:827:1: error: the frame size of 504 bytes is
larger than xxx bytes [-Werror=frame-larger-than=]
drivers/mmc/core/mmc_test.c: In function 'mmc_test_area_io_seq':
drivers/mmc/core/mmc_test.c:1491:1: error: the frame size of 680 bytes
is larger than 104 bytes [-Werror=frame-larger-than=]

After:

drivers/md/dm-integrity.c: In function 'write_journal':
drivers/md/dm-integrity.c:827:1: error: the frame size of 1280 bytes
is larger than 1024 bytes [-Werror=frame-larger-than=]
drivers/mmc/core/mmc_test.c: In function 'mmc_test_area_io_seq':
drivers/mmc/core/mmc_test.c:1491:1: error: the frame size of 1072
bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

I have not checked in detail why this happens, but I'm guessing that
there is an overall increase in stack usage with
CONFIG_LOCKDEP_COMPLETE in functions using completions,
and I think it would be good to try to come up with a version that doesn't
add as much.

        Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
