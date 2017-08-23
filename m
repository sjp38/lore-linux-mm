Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08FAC280396
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:25:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a186so3467845pge.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:25:23 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id h9si1287603pli.389.2017.08.23.08.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 08:25:22 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id y129so1485341pgy.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:25:22 -0700 (PDT)
From: Boqun Feng <boqun.feng@gmail.com>
Subject: [PATCH 0/2] completion: Reduce stack usage caused by COMPLETION_INITIALIZER_ONSTACK()
Date: Wed, 23 Aug 2017 23:25:36 +0800
Message-Id: <20170823152542.5150-1-boqun.feng@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com

With LOCKDEP_CROSSRELEASE and LOCKDEP_COMPLETIONS introduced, the growth
in kernel stack usage of several functions were reported:

	https://marc.info/?l=linux-kernel&m=150270063231284&w=2

The root cause of this is in COMPLETION_INITIALIZER_ONSTACK(), we use

	({init_completion(&work); work})

, which will create a temporary object when returned. However this
temporary object is unnecessary. And this patch fixes it by making the
statement expression in COMPLETION_INITIALIZER_ONSTACK() return a
pointer rather than a whole structure. This will reduce the stack usage
even if !LOCKDEP.

However, such a change does make one COMPLETION_INITIALIZER_ONSTACK()
callsite invalid, so we fix this first via converting to
init_completion().

Regards,
Boqun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
