Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF0096B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:33:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u89so344514wrc.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 02:33:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d43si5081620wrd.85.2017.08.10.02.33.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 02:33:51 -0700 (PDT)
Date: Thu, 10 Aug 2017 11:33:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] userfaultfd: replace ENOSPC with ESRCH in case mm has
 gone during copy/zeropage
Message-ID: <20170810093349.GK23863@dhcp22.suse.cz>
References: <1502111545-32305-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170808060816.GA31648@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808060816.GA31648@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue 08-08-17 09:08:17, Mike Rapoport wrote:
> (adding Michal)

Thanks

> On Mon, Aug 07, 2017 at 04:12:25PM +0300, Mike Rapoport wrote:
> > When the process exit races with outstanding mcopy_atomic, it would be
> > better to return ESRCH error. When such race occurs the process and it's mm
> > are going away and returning "no such process" to the uffd monitor seems
> > better fit than ENOSPC.

Not only the error message would be less confusing I also think that
error handling should be more straightforward. Although I cannot find
any guidelines for ENOSPC handling I've considered this errno as
potentially temporary and retry might be feasible while ESRCH is a
terminal error. I do not expect any userfaultfd users would retry on
error but who knows how the interface will be used in future so better
be prepared.

> > Suggested-by: Michal Hocko <mhocko@suse.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> > Cc: Pavel Emelyanov <xemul@virtuozzo.com>
> > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> > ---
> > The man-pages update is ready and I'll send it out once the patch is
> > merged.
> > 
> >  fs/userfaultfd.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index 06ea26b8c996..b0d5897bc4e6 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1600,7 +1600,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
> >  				   uffdio_copy.len);
> >  		mmput(ctx->mm);
> >  	} else {
> > -		return -ENOSPC;
> > +		return -ESRCH;
> >  	}
> >  	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
> >  		return -EFAULT;
> > @@ -1647,7 +1647,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> >  				     uffdio_zeropage.range.len);
> >  		mmput(ctx->mm);
> >  	} else {
> > -		return -ENOSPC;
> > +		return -ESRCH;
> >  	}
> >  	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
> >  		return -EFAULT;
> > -- 
> > 2.7.4
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
