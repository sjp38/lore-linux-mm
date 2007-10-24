Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OD6gAg021713
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:06:42 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OD6fGA100654
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 07:06:42 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OD6fsh022951
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 07:06:41 -0600
Subject: Re: [patch] hugetlb: fix i_blocks accounting
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <b040c32a0710231734j789b376fu93390f60e3d2ecdc@mail.gmail.com>
References: <b040c32a0710201118g5abb6608me57d7b9057f86919@mail.gmail.com>
	 <1193151154.18417.39.camel@localhost.localdomain>
	 <b040c32a0710231734j789b376fu93390f60e3d2ecdc@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 08:06:36 -0500
Message-Id: <1193231196.18417.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-23 at 17:34 -0700, Ken Chen wrote:
> On 10/23/07, Adam Litke <agl@us.ibm.com> wrote:
> > On Sat, 2007-10-20 at 11:18 -0700, Ken Chen wrote:
> > > For administrative purpose, we want to query actual block usage for
> > > hugetlbfs file via fstat.  Currently, hugetlbfs always return 0.  Fix
> > > that up since kernel already has all the information to track it
> > > properly.
> >
> > Hey Ken.  You might want to wait on this for another minute or two.  I
> > will be sending out patches later today to fix up hugetlbfs quotas.
> > Right now the code does not handle private mappings correctly (ie.  it
> > does not call get_quota() for COW pages and it never calls put_quota()
> > for any private page).  Because of this, your i_blocks number will be
> > wrong most of the time.
> 
> Adam, speaking of hugetlb file system quota, there is another bug in
> there for shared mapping as well.

Yep ;)  I already have a fix for that too in this series.  Coming right
up.

> At the time of mmap (MMAP_SHARED), kernel only check page reservation
> against available hugetlb page pool.  FS quota is not checked at all.
> Now we over commit the fs quota for shared mapping, but still let the
> mmap to succeed.  At later point in the page fault path, app will
> eventually die with SIGBUS due to lack of fs quota.  This behavior
> broke a few apps for us. The bad part is there is no easy recovery
> path once a SIGBUS is raised.
> 
> I tried with MAP_POPULATE, but unfortunately it doesn't propagate
> error code back up to user space on mmap; same thing with mlockall
> that also ignores error code returned from make_pages_present().
> Using mlock is at best half baked because VM_LOCKED maybe already set
> via other means.
> 
> So this fs quota thing really needs some love and attention.

Yep, now that we are actually starting to use it...

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
