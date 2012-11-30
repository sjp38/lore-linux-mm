Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0212D6B0073
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 15:38:10 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hm9so385613wib.8
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:38:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 30 Nov 2012 12:37:49 -0800
Message-ID: <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
Subject: Re: [PATCH 00/10] Latest numa/core release, v18
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 30, 2012 at 11:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> When pushed hard enough via threaded workloads (for example via the
> numa02 test) then the upstream page migration code in mm/migration.c
> becomes unscalable, resulting in lot of scheduling on the anon vma
> mutex and a subsequent drop in performance.

Ugh.

I wonder if migration really needs that thing to be a mutex? I may be
wrong, but the anon_vma lock only protects the actual rmap chains, and
migration only ever changes the pte *contents*, not the actual chains
of pte's themselves, right?

So if this is a migration-specific scalability issue, then it might be
possible to solve by making the mutex be a rwsem instead, and have
migration only take it for reading.

Of course, I'm quite possibly wrong, and the code depends on full
mutual exclusion.

Just a thought, in case it makes somebody go "Hmm.."

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
