Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 697D96B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 14:30:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o3so2901236qte.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:30:31 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id f3si2338856qtd.385.2017.09.20.11.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 11:30:30 -0700 (PDT)
Date: Wed, 20 Sep 2017 20:30:41 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/1] userfaultfd: non-cooperative: fix fork use after free
Message-ID: <20170920183041.GA29542@kroah.com>
References: <20170919131839.GD30715@leverpostej>
 <20170920180413.26713-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920180413.26713-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, syzkaller@googlegroups.com, stable@vger.kernel.org

On Wed, Sep 20, 2017 at 08:04:13PM +0200, Andrea Arcangeli wrote:
> When reading the event from the uffd, we put it on a temporary
> fork_event list to detect if we can still access it after releasing
> and retaking the event_wqh.lock.
> 
> If fork aborts and removes the event from the fork_event all is fine
> as long as we're still in the userfault read context and fork_event
> head is still alive.
> 
> We've to put the event allocated in the fork kernel stack, back from
> fork_event list-head to the event_wqh head, before returning from
> userfaultfd_ctx_read, because the fork_event head lifetime is limited
> to the userfaultfd_ctx_read stack lifetime.
> 
> Forgetting to move the event back to its event_wqh place then results
> in __remove_wait_queue(&ctx->event_wqh, &ewq->wq); in
> userfaultfd_event_wait_completion to remove it from a head that has
> been already freed from the reader stack.
> 
> This could only happen if resolve_userfault_fork failed (for example
> if there are no file descriptors available to allocate the fork
> uffd). If it succeeded it was put back correctly.
> 
> Furthermore, after find_userfault_evt receives a fork event, the
> forked userfault context in fork_nctx and
> uwq->msg.arg.reserved.reserved1 can be released by the fork thread as
> soon as the event_wqh.lock is released. Taking a reference on the
> fork_nctx before dropping the lock prevents an use after free in
> resolve_userfault_fork().
> 
> If the fork side aborted and it already released everything, we still
> try to succeed resolve_userfault_fork(), if possible.
> 
> Reported-by: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/userfaultfd.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 56 insertions(+), 10 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
