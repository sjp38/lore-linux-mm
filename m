Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA576B0261
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:16:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so59232070pfa.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:16:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id u84si9657494pgb.258.2017.01.12.08.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:16:48 -0800 (PST)
Date: Thu, 12 Jan 2017 17:16:43 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 05/15] lockdep: Make check_prev_add can use a separate
 stack_trace
Message-ID: <20170112161643.GB3144@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481260331-360-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Fri, Dec 09, 2016 at 02:12:01PM +0900, Byungchul Park wrote:
> check_prev_add() saves a stack trace of the current. But crossrelease
> feature needs to use a separate stack trace of another context in
> check_prev_add(). So make it use a separate stack trace instead of one
> of the current.
> 

So I was thinking, can't we make check_prevs_add() create the stack
trace unconditionally but record if we used it or not, and then return
the entries when unused. All that is serialized by graph_lock anyway and
that way we already pass a stack into check_prev_add() so we can easily
pass in a different one.

I think that removes a bunch of tricky and avoids all the new tricky.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
