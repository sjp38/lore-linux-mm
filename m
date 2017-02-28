Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35DFD6B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:15:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so5996838pfg.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 23:15:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t19si967539plj.305.2017.02.27.23.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 23:15:39 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1S7E8dp049735
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:15:37 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28vyqeu39q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:15:37 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 28 Feb 2017 07:15:34 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] userfaultfd non-cooperative further update for 4.11 merge window
Date: Tue, 28 Feb 2017 09:15:29 +0200
In-Reply-To: <20170224181957.19736-1-aarcange@redhat.com>
References: <20170224181957.19736-1-aarcange@redhat.com>
Message-Id: <1488266129-8411-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Fri, 24 Feb 2017 19:19:54 +0100, Andrea Arcangeli wrote:
> Hello,
> 
> unfortunately I noticed one relevant bug in userfaultfd_exit while
> doing more testing. I've been doing testing before and this was also
> tested by kbuild bot and exercised by the selftest, but this bug never
> reproduced before.
> 
> I dropped userfaultfd_exit as result. I dropped it because of
> implementation difficulty in receiving signals in __mmput and because
> I think -ENOSPC as result from the background UFFDIO_COPY should be
> enough already.

The -ENOSPC from UFFDIO_COPY will be enough, I believe.

> Before I decided to remove userfaultfd_exit, I noticed
> userfaultfd_exit wasn't exercised by the selftest and when I tried to
> exercise it, after moving it to a more correct place in __mmput where
> it would make more sense and where the vma list is stable, it resulted
> in the event_wait_completion in D state. So then I added the second
> patch to be sure even if we call userfaultfd_event_wait_completion too
> late during task exit(), we won't risk to generate tasks in D
> state. The same check exists in handle_userfault() for the same
> reason, except it makes a difference there, while here is just a
> robustness check and it's run under WARN_ON_ONCE.
> 
> While looking at the userfaultfd_event_wait_completion() function I
> looked back at its callers too while at it and I think it's not ok to
> stop executing dup_fctx on the fcs list because we relay on
> userfaultfd_event_wait_completion to execute
> userfaultfd_ctx_put(fctx->orig) which is paired against
> userfaultfd_ctx_get(fctx->orig) in dup_userfault just before
> list_add(fcs). This change only takes care of fctx->orig but this area
> also needs further review looking for similar problems in fctx->new.

I'll take a look at fctx->new. 

> The only patch that is urgent is the first because it's an use after
> free during a SMP race condition that affects all processes if
> CONFIG_USERFAULTFD=y. Very hard to reproduce though and probably
> impossible without SLUB poisoning enabled.
> 
> Mike and Pavel please review, thanks!

Thanks for the fixes :)

> Andrea
> 
> Andrea Arcangeli (3):
>   userfaultfd: non-cooperative: rollback userfaultfd_exit
>   userfaultfd: non-cooperative: robustness check
>   userfaultfd: non-cooperative: release all ctx in dup_userfaultfd_complete

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
 
>  fs/userfaultfd.c                 | 47 +++++++---------------------------------
>  include/linux/userfaultfd_k.h    |  6 -----
>  include/uapi/linux/userfaultfd.h |  5 +----
>  kernel/exit.c                    |  1 -
>  4 files changed, 9 insertions(+), 50 deletions(-)

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
