Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D33BB6B3D76
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 13:30:47 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id m10so2039508lfk.6
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 10:30:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t73-v6sor31947126lje.19.2018.11.25.10.30.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 10:30:45 -0800 (PST)
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com. [209.85.167.53])
        by smtp.gmail.com with ESMTPSA id c133sm9933619lfc.45.2018.11.25.10.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 10:30:43 -0800 (PST)
Received: by mail-lf1-f53.google.com with SMTP id p6so11895303lfc.1
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 10:30:42 -0800 (PST)
MIME-Version: 1.0
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Nov 2018 10:30:25 -0800
Message-ID: <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
Subject: Re: [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bhe@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, david@redhat.com, mgorman@techsingularity.net, dh.herrmann@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, kan.liang@intel.com, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, Nov 24, 2018 at 7:21 PM Hugh Dickins <hughd@google.com> wrote:
>
> Linus, I'm addressing this patch to you because I see from Tim Chen's
> thread that it would interest you, and you were disappointed not to
> root cause the issue back then.  I'm not pushing for you to fast-track
> this into 4.20-rc, but I expect Andrew will pick it up for mmotm, and
> thence linux-next.  Or you may spot a terrible defect, but I hope not.

The only terrible defect I spot is that I wish the change to the
'lock' argument in wait_on_page_bit_common() came with a comment
explaining the new semantics.

The old semantics were somewhat obvious (even if not documented): if
'lock' was set,  we'd make the wait exclusive, and we'd lock the page
before returning. That kind of matches the intuitive meaning for the
function prototype, and it's pretty obvious in the callers too.

The new semantics don't have the same kind of really intuitive
meaning, I feel. That "-1" doesn't mean "unlock", it means "drop page
reference", so there is no longer a fairly intuitive and direct
mapping between the argument name and type and the behavior of the
function.

So I don't hate the concept of the patch at all, but I do ask to:

 - better documentation.

   This might not be "documentation" at all, maybe that "lock"
variable should just be renamed (because it's not about just locking
any more), and would be better off as a tristate enum called
"behavior" that has "LOCK, DROP, WAIT" values?

 - while it sounds likely that this is indeed the same issue that
plagues us with the insanely long wait-queues, it would be *really*
nice to have that actually confirmed.

   Does somebody still have access to the customer load that triggered
the horrible scaling issues before?

In particular, on that second issue: the "fixes" that went in for the
wait-queues didn't really fix any real scalability problem, it really
just fixed the excessive irq latency issues due to the long traversal
holding a lock.

If this really fixes the fundamental issue, that should show up as an
actual performance difference, I'd expect..

End result: I like and approve of the patch, but I'd like it a lot
more if the code behavior was clarified a bit, and I'd really like to
close the loop on that old nasty page wait queue issue...

                   Linus
