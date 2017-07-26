Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55CFE6B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:19:26 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 6so9105982qts.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:19:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c33si9690433qtb.549.2017.07.26.07.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 07:19:25 -0700 (PDT)
Date: Wed, 26 Jul 2017 16:19:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RESEND PATCH 1/2] userfaultfd: Add feature to request for a
 signal delivery
Message-ID: <20170726141922.GV29716@redhat.com>
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue, Jul 25, 2017 at 12:47:41AM -0400, Prakash Sangappa wrote:
> In some cases, userfaultfd mechanism should just deliver a SIGBUS signal
> to the faulting process, instead of the page-fault event. Dealing with
> page-fault event using a monitor thread can be an overhead in these
> cases. For example applications like the database could use the signaling
> mechanism for robustness purpose.
> 
> Database uses hugetlbfs for performance reason. Files on hugetlbfs
> filesystem are created and huge pages allocated using fallocate() API.
> Pages are deallocated/freed using fallocate() hole punching support.
> These files are mmapped and accessed by many processes as shared memory.
> The database keeps track of which offsets in the hugetlbfs file have
> pages allocated.
> 
> Any access to mapped address over holes in the file, which can occur due
> to bugs in the application, is considered invalid and expect the process
> to simply receive a SIGBUS.  However, currently when a hole in the file is
> accessed via the mapped address, kernel/mm attempts to automatically
> allocate a page at page fault time, resulting in implicitly filling the
> hole in the file. This may not be the desired behavior for applications
> like the database that want to explicitly manage page allocations of
> hugetlbfs files.
> 
> Using userfaultfd mechanism with this support to get a signal, database
> application can prevent pages from being allocated implicitly when
> processes access mapped address over holes in the file.
> 
> This patch adds UFFD_FEATURE_SIGBUS feature to userfaultfd mechnism to
> request for a SIGBUS signal.
> 
> See following for previous discussion about the database requirement
> leading to this proposal as suggested by Andrea.
> 
> http://www.spinics.net/lists/linux-mm/msg129224.html
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
>  fs/userfaultfd.c                 |    3 +++
>  include/uapi/linux/userfaultfd.h |   10 +++++++++-
>  2 files changed, 12 insertions(+), 1 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
