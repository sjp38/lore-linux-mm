Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B10B16B02B4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:58:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d184so1578616wmd.15
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:58:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v63si528101wme.197.2017.06.15.15.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 15:58:51 -0700 (PDT)
Date: Thu, 15 Jun 2017 15:58:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] userfaultfd: shmem: handle coredumping in
 handle_userfault()
Message-Id: <20170615155849.c0bde2722026855dabe1c8b9@linux-foundation.org>
In-Reply-To: <20170615225231.GB11676@redhat.com>
References: <20170615214838.27429-1-aarcange@redhat.com>
	<20170615145428.55264cd6c7e058b6e7a58f58@linux-foundation.org>
	<20170615225231.GB11676@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Fri, 16 Jun 2017 00:52:31 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> > Can we please get that description into the changelog so that others
> > can decide which kernel(s) need the fix?
> 
> Only 4.11 is affected, pre-4.11 anon memory holes are skipped in
> __get_user_pages by checking FOLL_DUMP explicitly against empty
> pagetables (mm/gup.c:no_page_table()).
> 
> Should I re-submit with this detail?

Is OK thanks, I updated the changelog and queued it for 4.12.


From: Andrea Arcangeli <aarcange@redhat.com>
Subject: userfaultfd: shmem: handle coredumping in handle_userfault()

Anon and hugetlbfs handle FOLL_DUMP set by get_dump_page() internally to
__get_user_pages().

shmem as opposed has no special FOLL_DUMP handling there so
handle_mm_fault() is invoked without mmap_sem and ends up calling
handle_userfault() that isn't expecting to be invoked without mmap_sem
held.

This makes handle_userfault() fail immediately if invoked through
shmem_vm_ops->fault during coredumping and solves the problem.

The side effect is a BUG_ON with no lock held triggered by the coredumping
process which exits.  Only 4.11 is affected, pre-4.11 anon memory holes
are skipped in __get_user_pages by checking FOLL_DUMP explicitly against
empty pagetables (mm/gup.c:no_page_table()).

It's zero cost as we already had a check for current->flags to prevent
futex to trigger userfaults during exit (PF_EXITING).

Link: http://lkml.kernel.org/r/20170615214838.27429-1-aarcange@redhat.com
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: <stable@vger.kernel.org>	[4.11+]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
