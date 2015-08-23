Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADFD86B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 16:53:34 -0400 (EDT)
Received: by lalv9 with SMTP id v9so66232821lal.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 13:53:33 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id tk5si11445973lbb.14.2015.08.23.13.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 13:53:32 -0700 (PDT)
Received: by lalv9 with SMTP id v9so66232563lal.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 13:53:31 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
References: <20150823060443.GA9882@gmail.com>
	<20150823064603.14050.qmail@ns.horizon.com>
	<20150823081750.GA28349@gmail.com>
Date: Sun, 23 Aug 2015 22:53:28 +0200
In-Reply-To: <20150823081750.GA28349@gmail.com> (Ingo Molnar's message of
	"Sun, 23 Aug 2015 10:17:51 +0200")
Message-ID: <87lhd1wwtz.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

On Sun, Aug 23 2015, Ingo Molnar <mingo@kernel.org> wrote:

> Ok, fair enough - so how about the attached approach instead, which
> uses a 64-bit generation counter to track changes to the vmalloc
> state.

How does this invalidation approach compare to the jiffies approach? In
other words, how often does the vmalloc info actually change (or rather,
in this approximation, how often is vmap_area_lock taken)? In
particular, does it also solve the problem with git's test suite and
similar situations with lots of short-lived processes?

> ==============================>
> From f9fd770e75e2edb4143f32ced0b53d7a77969c94 Mon Sep 17 00:00:00 2001
> From: Ingo Molnar <mingo@kernel.org>
> Date: Sat, 22 Aug 2015 12:28:01 +0200
> Subject: [PATCH] mm/vmalloc: Cache the vmalloc memory info
>
> Linus reported that glibc (rather stupidly) reads /proc/meminfo
> for every sysinfo() call,

Not quite: It is done by the two functions get_{av,}phys_pages
functions; and get_phys_pages is called (once per process) by glibc's
qsort implementation. In fact, sysinfo() is (at least part of) the cure,
not the disease. Whether qsort should care about the total amount of
memory is another discussion.

<http://thread.gmane.org/gmane.comp.lib.glibc.alpha/54342/focus=54558>

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
