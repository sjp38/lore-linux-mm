Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C79B76B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 15:06:10 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so8988284pbc.40
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 12:06:10 -0700 (PDT)
Date: Tue, 8 Oct 2013 21:06:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Message-ID: <20131008190604.GB14223@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B0176@FMSMSX107.amr.corp.intel.com>
 <20131004183315.GA19557@quack.suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B07B7@FMSMSX107.amr.corp.intel.com>
 <20131007172604.GD30441@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Content-Disposition: inline
In-Reply-To: <20131007172604.GD30441@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon 07-10-13 19:26:04, Jan Kara wrote:
> On Mon 07-10-13 15:38:24, Marciniszyn, Mike wrote:
> > > > This patch and the sibling ipath patch will nominally take the mmap_sem
> > > > twice where the old routine only took it once.   This is a performance
> > > > issue.
> > >   It will take mmap_sem only once during normal operation. Only if
> > > get_user_pages_unlocked() fail, we have to take mmap_sem again to undo
> > > the change of mm->pinned_vm.
> > > 
> > > > Is the intent here to deprecate get_user_pages()?
> > 
> > The old code looked like:
> > __qib_get_user_pages()
> > 	(broken) ulimit test
> >              for (...)
> > 		get_user_pages()
> > 
> > qib_get_user_pages()
> > 	mmap_sem lock
> > 	__qib_get_user_pages()
> >              mmap_sem() unlock
> > 
> > The new code is:
> > 
> > get_user_pages_unlocked()
> > 	mmap_sem  lock
> > 	get_user_pages()
> > 	mmap_sem unlock
> > 
> > qib_get_user_pages()
> > 	mmap_sem lock
> >              ulimit test and locked pages maintenance
> >              mmap_sem unlock
> > 	for (...)
> > 		get_user_pages_unlocked()
> > 
> > I count an additional pair of mmap_sem transactions in the normal case.
>   Ah, sorry, you are right.
> 
> > > > Could the lock limit test be pushed into another version of the
> > > > wrapper so that there is only one set of mmap_sem transactions?
> > >   I'm sorry, I don't understand what you mean here...
> > > 
> > 
> > This is what I had in mind:
> > 
> > get_user_pages_ulimit_unlocked()
> > 	mmap_sem  lock
> > 	ulimit test and locked pages maintenance (from qib/ipath)
> >              for (...)
> > 	       get_user_pages_unlocked()	
> > 	mmap_sem unlock
> > 	
> > qib_get_user_pages()
> > 	get_user_pages_ulimit_unlocked()
> > 
> > This really pushes the code into a new wrapper common to ipath/qib and
> > any others that might want to combine locking with ulimit enforcement.
>   We could do that but frankly, I'd rather change ulimit enforcement to not
> require mmap_sem and use atomic counter instead. I'll see what I can do.
  OK, so something like the attached patch (compile tested only). What do
you think? I'm just not 100% sure removing mmap_sem surrounding stuff like
__ipath_release_user_pages() is safe. I don't see a reason why it shouldn't
be - we have references to the pages and we only mark them dirty and put the
reference - but maybe I miss something subtle...

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--BXVAT5kNtrzKuDFl
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Switch-mm-pinned_vm-to-atomic_long_t.patch"


--BXVAT5kNtrzKuDFl--
