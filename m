Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 38B266B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 11:20:32 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so7242328pbc.17
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 08:20:31 -0700 (PDT)
From: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Subject: RE: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Date: Mon, 7 Oct 2013 15:20:28 +0000
Message-ID: <32E1700B9017364D9B60AED9960492BC211B079B@FMSMSX107.amr.corp.intel.com>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
 <32E1700B9017364D9B60AED9960492BC211B0176@FMSMSX107.amr.corp.intel.com>
 <20131004183315.GA19557@quack.suse.cz>
In-Reply-To: <20131004183315.GA19557@quack.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>



> -----Original Message-----
> From: Jan Kara [mailto:jack@suse.cz]
> Sent: Friday, October 04, 2013 2:33 PM
> To: Marciniszyn, Mike
> Cc: Jan Kara; LKML; linux-mm@kvack.org; infinipath; Roland Dreier; linux-
> rdma@vger.kernel.org
> Subject: Re: [PATCH 23/26] ib: Convert qib_get_user_pages() to
> get_user_pages_unlocked()
>=20
> On Fri 04-10-13 13:52:49, Marciniszyn, Mike wrote:
> > > Convert qib_get_user_pages() to use get_user_pages_unlocked().  This
> > > shortens the section where we hold mmap_sem for writing and also
> > > removes the knowledge about get_user_pages() locking from ipath
> > > driver. We also fix a bug in testing pinned number of pages when
> changing the code.
> > >
> >
> > This patch and the sibling ipath patch will nominally take the mmap_sem
> > twice where the old routine only took it once.   This is a performance
> > issue.
>   It will take mmap_sem only once during normal operation. Only if
> get_user_pages_unlocked() fail, we have to take mmap_sem again to undo
> the change of mm->pinned_vm.
>=20
> > Is the intent here to deprecate get_user_pages()?
>   Well, as much as I'd like to, there are really places in mm code which =
need
> to call get_user_pages() while holding mmap_sem to be able to inspect
> corresponding vmas etc. So I want to reduce get_user_pages() use as much
> as possible but I'm not really hoping in completely removing it.
>=20
> > I agree, the old code's lock limit test is broke and needs to be fixed.
> > I like the elimination of the silly wrapper routine!
> >
> > Could the lock limit test be pushed into another version of the
> > wrapper so that there is only one set of mmap_sem transactions?
>   I'm sorry, I don't understand what you mean here...
>=20
> 								Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
