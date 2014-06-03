Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id D19EF6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 09:28:27 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id s18so1511272lam.18
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 06:28:26 -0700 (PDT)
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
        by mx.google.com with ESMTPS id 2si40802391lbn.60.2014.06.03.06.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 06:28:25 -0700 (PDT)
Received: by mail-la0-f42.google.com with SMTP id el20so3499576lab.1
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 06:28:25 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard> <20140529015830.GG6677@dastard>
	<20140529233638.GJ10092@bbox> <20140530001558.GB14410@dastard>
	<20140530021247.GR10092@bbox>
Date: Tue, 03 Jun 2014 15:28:22 +0200
In-Reply-To: <20140530021247.GR10092@bbox> (Minchan Kim's message of "Fri, 30
	May 2014 11:12:47 +0900")
Message-ID: <87mwduqg09.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Possibly stupid question: Is it true that any given task can only be
using one wait_queue_t at a time? If so, would it be an idea to put a
wait_queue_t into struct task_struct [maybe union'ed with a struct
wait_bit_queue] and avoid allocating this 40 byte structure repeatedly
on the stack.

E.g., in one of Minchan's stack traces, there are two calls of
mempool_alloc (which itself declares a wait_queue_t) and one
try_to_free_pages (which is the only caller of throttle_direct_reclaim,
which in turn uses wait_event_interruptible_timeout and
wait_event_killable).

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
