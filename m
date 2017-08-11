Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4796B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:46:29 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p62so3881494oih.12
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:46:29 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id d144si577702oig.432.2017.08.11.06.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 06:46:28 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id t78so3700124ita.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:46:28 -0700 (PDT)
From: "Blake Caldwell" <caldweba@colorado.edu>
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com> <20170627133952.GA25343@rapoport-lnx>
In-Reply-To: <20170627133952.GA25343@rapoport-lnx>
Subject: RE: [RFC PATCH 0/5] userfaultfd: non-cooperative: syncronous events
Date: Fri, 11 Aug 2017 09:46:29 -0400
Message-ID: <011e01d312a8$3c97e6b0$b5c7b410$@colorado.edu>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Rapoport' <rppt@linux.vnet.ibm.com>
Cc: 'Pavel Emelyanov' <xemul@virtuozzo.com>, 'linux-mm' <linux-mm@kvack.org>, 'Andrea Arcangeli' <aarcange@redhat.com>

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Mike Rapoport
> Sent: Tuesday, June 27, 2017 9:40 AM
> To: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Pavel Emelyanov <xemul@virtuozzo.com>; linux-mm <linux-
> mm@kvack.org>
> Subject: Re: [RFC PATCH 0/5] userfaultfd: non-cooperative: syncronous
events
> 
> On Tue, May 16, 2017 at 01:35:57PM +0300, Mike Rapoport wrote:
> > Hi,
> 
> Any comments on this?
> Shall I repost without the "RFC" prefix?
> 
I have a use case for this feature exactly like what you have described. The
process should be suspended until the event has been handled. I would like
to test this if there is a rebased patchset out there somewhere? I'm using
4.13.0_rc3 from
https://kernel.googlesource.com/pub/scm/linux/kernel/git/andrea/aa.git

I wasn't able to apply the patches without heavy modification (mostly patch
3/5).

Thanks for the work on this.
> > These patches add ability to generate userfaultfd events so that thier
> > processing will be synchronized with the non-cooperative thread that
> > caused the event.
> >
> > In the non-cooperative case userfaultfd resumes execution of the
> > thread that caused an event when the notification is read() by the uffd
> monitor.
> > In some cases, like, for example, madvise(MADV_REMOVE), it might be
> > desirable to keep the thread that caused the event suspended until the
> > uffd monitor had the event handled.
> >
> > The first two patches just shuffle the code a bit to make subsequent
> > changes easier.
> > The patches 3 and 4 create some unification in the way the threads are
> > queued into waitqueues either after page fault or after a
> > non-cooperative event.
> > The fifth patch extends the userfaultfd API with an implementation of
> > UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
> > UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.
> >
> > Mike Rapoport (5):
> >   userfaultfd: introduce userfault_init_waitqueue helper
> >   userfaultfd: introduce userfaultfd_should_wait helper
> >   userfaultfd: non-cooperative: generalize wake key structure
> >   userfaultfd: non-cooperative: use fault_pending_wqh for all events
> >   userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE
> >
> >  fs/userfaultfd.c                 | 205
++++++++++++++++++++++++---------------
> >  include/uapi/linux/userfaultfd.h |  11 +++
> >  2 files changed, 136 insertions(+), 80 deletions(-)
> >
> > --
> > 2.7.4
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
