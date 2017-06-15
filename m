Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 077CF6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:54:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h64so1423190wmg.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:54:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q18si346646wrb.366.2017.06.15.14.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 14:54:30 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:54:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] userfaultfd: shmem: handle coredumping in
 handle_userfault()
Message-Id: <20170615145428.55264cd6c7e058b6e7a58f58@linux-foundation.org>
In-Reply-To: <20170615214838.27429-1-aarcange@redhat.com>
References: <20170615214838.27429-1-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Thu, 15 Jun 2017 23:48:38 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> Anon and hugetlbfs handle FOLL_DUMP set by get_dump_page() internally
> to __get_user_pages().
> 
> shmem as opposed has no special FOLL_DUMP handling there so
> handle_mm_fault() is invoked without mmap_sem and ends up calling
> handle_userfault() that isn't expecting to be invoked without mmap_sem
> held.
> 
> This makes handle_userfault() fail immediately if invoked through
> shmem_vm_ops->fault during coredumping and solves the problem.
> 
> It's zero cost as we already had a check for current->flags to prevent
> futex to trigger userfaults during exit (PF_EXITING).

So what are the user-visible effects of the bug?  Incomplete core files,
I assume?

Can we please get that description into the changelog so that others
can decide which kernel(s) need the fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
