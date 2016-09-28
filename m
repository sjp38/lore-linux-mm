Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6A556B0280
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 12:10:58 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i129so4452423ywe.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 09:10:58 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id g68si2195616otb.98.2016.09.28.09.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 09:10:31 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id t83so59276120oie.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 09:10:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160928111115.GS5016@twins.programming.kicks-ass.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net> <20160927143426.GP2794@worktop>
 <20160928104500.GC3903@techsingularity.net> <20160928111115.GS5016@twins.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Sep 2016 09:10:29 -0700
Message-ID: <CA+55aFxTPk-3zXEAWfXN2Hfm5Qw__B_2BJw7vNN_hFY+NTctgw@mail.gmail.com>
Subject: Re: page_waitqueue() considered harmful
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 28, 2016 at 4:11 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> -void unlock_page(struct page *page)
> +void __unlock_page(struct page *page)
>  {
> +       struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(&page->flags, PG_locked);
> +       wait_queue_head_t *wq = page_waitqueue(page);
> +
> +       if (waitqueue_active(wq))
> +               __wake_up(wq, TASK_NORMAL, 1, &key);
> +       else
> +               ClearPageContended(page);
>  }
> +EXPORT_SYMBOL(__unlock_page);

I think the above needs to be protected. Something like

    spin_lock_irqsave(&q->lock, flags);
    if (waitqueue_active(wq))
          __wake_up_locked(wq, TASK_NORMAL, 1, &key);
    else
          ClearPageContended(page);
    spin_unlock_irqrestore(&q->lock, flags);

because otherwise a new waiter could come in and add itself to the
wait-queue, and then set the bit, and now we clear it (because we
didn't see the new waiter).

The *waiter* doesn't need any extra locking, because doing

    add_wait_queue(..);
    SetPageContended(page);

is not racy (the add_wait_queue() will now already guarantee that
nobody else clears the bit).

Hmm?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
