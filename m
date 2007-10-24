Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l9O0Y2Lh027820
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 17:34:02 -0700
Received: from rv-out-0910.google.com (rvfb22.prod.google.com [10.140.179.22])
	by zps36.corp.google.com with ESMTP id l9O0Y1KC028855
	for <linux-mm@kvack.org>; Tue, 23 Oct 2007 17:34:02 -0700
Received: by rv-out-0910.google.com with SMTP id b22so23484rvf
        for <linux-mm@kvack.org>; Tue, 23 Oct 2007 17:34:01 -0700 (PDT)
Message-ID: <b040c32a0710231734j789b376fu93390f60e3d2ecdc@mail.gmail.com>
Date: Tue, 23 Oct 2007 17:34:01 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] hugetlb: fix i_blocks accounting
In-Reply-To: <1193151154.18417.39.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0710201118g5abb6608me57d7b9057f86919@mail.gmail.com>
	 <1193151154.18417.39.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/23/07, Adam Litke <agl@us.ibm.com> wrote:
> On Sat, 2007-10-20 at 11:18 -0700, Ken Chen wrote:
> > For administrative purpose, we want to query actual block usage for
> > hugetlbfs file via fstat.  Currently, hugetlbfs always return 0.  Fix
> > that up since kernel already has all the information to track it
> > properly.
>
> Hey Ken.  You might want to wait on this for another minute or two.  I
> will be sending out patches later today to fix up hugetlbfs quotas.
> Right now the code does not handle private mappings correctly (ie.  it
> does not call get_quota() for COW pages and it never calls put_quota()
> for any private page).  Because of this, your i_blocks number will be
> wrong most of the time.

Adam, speaking of hugetlb file system quota, there is another bug in
there for shared mapping as well.

At the time of mmap (MMAP_SHARED), kernel only check page reservation
against available hugetlb page pool.  FS quota is not checked at all.
Now we over commit the fs quota for shared mapping, but still let the
mmap to succeed.  At later point in the page fault path, app will
eventually die with SIGBUS due to lack of fs quota.  This behavior
broke a few apps for us. The bad part is there is no easy recovery
path once a SIGBUS is raised.

I tried with MAP_POPULATE, but unfortunately it doesn't propagate
error code back up to user space on mmap; same thing with mlockall
that also ignores error code returned from make_pages_present().
Using mlock is at best half baked because VM_LOCKED maybe already set
via other means.

So this fs quota thing really needs some love and attention.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
