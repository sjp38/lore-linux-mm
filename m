Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1186A6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 13:26:10 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so7598106pab.32
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 10:26:10 -0700 (PDT)
Date: Mon, 7 Oct 2013 19:26:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Message-ID: <20131007172604.GD30441@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B0176@FMSMSX107.amr.corp.intel.com>
 <20131004183315.GA19557@quack.suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B07B7@FMSMSX107.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32E1700B9017364D9B60AED9960492BC211B07B7@FMSMSX107.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

On Mon 07-10-13 15:38:24, Marciniszyn, Mike wrote:
> > > This patch and the sibling ipath patch will nominally take the mmap_sem
> > > twice where the old routine only took it once.   This is a performance
> > > issue.
> >   It will take mmap_sem only once during normal operation. Only if
> > get_user_pages_unlocked() fail, we have to take mmap_sem again to undo
> > the change of mm->pinned_vm.
> > 
> > > Is the intent here to deprecate get_user_pages()?
> 
> The old code looked like:
> __qib_get_user_pages()
> 	(broken) ulimit test
>              for (...)
> 		get_user_pages()
> 
> qib_get_user_pages()
> 	mmap_sem lock
> 	__qib_get_user_pages()
>              mmap_sem() unlock
> 
> The new code is:
> 
> get_user_pages_unlocked()
> 	mmap_sem  lock
> 	get_user_pages()
> 	mmap_sem unlock
> 
> qib_get_user_pages()
> 	mmap_sem lock
>              ulimit test and locked pages maintenance
>              mmap_sem unlock
> 	for (...)
> 		get_user_pages_unlocked()
> 
> I count an additional pair of mmap_sem transactions in the normal case.
  Ah, sorry, you are right.

> > > Could the lock limit test be pushed into another version of the
> > > wrapper so that there is only one set of mmap_sem transactions?
> >   I'm sorry, I don't understand what you mean here...
> > 
> 
> This is what I had in mind:
> 
> get_user_pages_ulimit_unlocked()
> 	mmap_sem  lock
> 	ulimit test and locked pages maintenance (from qib/ipath)
>              for (...)
> 	       get_user_pages_unlocked()	
> 	mmap_sem unlock
> 	
> qib_get_user_pages()
> 	get_user_pages_ulimit_unlocked()
> 
> This really pushes the code into a new wrapper common to ipath/qib and
> any others that might want to combine locking with ulimit enforcement.
  We could do that but frankly, I'd rather change ulimit enforcement to not
require mmap_sem and use atomic counter instead. I'll see what I can do.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
