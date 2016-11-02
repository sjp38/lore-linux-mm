Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0B586B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 11:18:38 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q197so42024655oic.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 08:18:38 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id q28si2102356otq.166.2016.11.02.08.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 08:18:38 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id x4so20551970oix.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 08:18:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161102070346.12489-3-npiggin@gmail.com>
References: <20161102070346.12489-1-npiggin@gmail.com> <20161102070346.12489-3-npiggin@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Nov 2016 09:18:37 -0600
Message-ID: <CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue should
 be checked
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, Nov 2, 2016 at 1:03 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> +       __wake_up_locked_key(q, TASK_NORMAL, &key);
> +       if (!waitqueue_active(q) || !key.page_match) {
> +               ClearPageWaiters(page);

Is that "page_match" optimization really worth it? I'd rather see
numbers for that particular optimization. I'd rather see the
contention bit being explicitly not precise.

Also, it would be lovely to get numbers against the plain 4.8
situation with the per-zone waitqueues. Maybe that used to help your
workload, so the 2.2% improvement might be partly due to me breaking
performance on your machine.

But other than that this all looks fine to me.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
