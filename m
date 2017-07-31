Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76A166B0605
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 09:36:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k68so15608878wmd.14
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 06:36:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e1si22815667wrc.491.2017.07.31.06.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 06:36:34 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6VDaW3C016564
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 09:36:32 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c24v7ajsn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 09:36:32 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 31 Jul 2017 14:36:31 +0100
Date: Mon, 31 Jul 2017 16:36:23 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731122204.GB4878@dhcp22.suse.cz>
Message-Id: <20170731133622.GC28632@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Mon, Jul 31, 2017 at 02:22:04PM +0200, Michal Hocko wrote:
> On Thu 27-07-17 09:26:59, Mike Rapoport wrote:
> > In the non-cooperative userfaultfd case, the process exit may race with
> > outstanding mcopy_atomic called by the uffd monitor.  Returning -ENOSPC
> > instead of -EINVAL when mm is already gone will allow uffd monitor to
> > distinguish this case from other error conditions.
> 
> Normally we tend to return ESRCH in such case. ENOSPC sounds rather
> confusing...

Well, I don't remember why I used ENOSPC in userfault_copy at the first
place, but if we are to keep it userfaultfd_zeropage should return the same
error...

> > Cc: stable@vger.kernel.org
> > Fixes: 96333187ab162 ("userfaultfd_copy: return -ENOSPC in case mm has gone")
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> > 
> > Unfortunately, I've overlooked userfaultfd_zeropage when I updated
> > userfaultd_copy :(
> > 
> >  fs/userfaultfd.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index cadcd12a3d35..2d8c2d848668 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1643,6 +1643,8 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> >  		ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
> >  				     uffdio_zeropage.range.len);
> >  		mmput(ctx->mm);
> > +	} else {
> > +		return -ENOSPC;
> >  	}
> >  	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
> >  		return -EFAULT;
> > -- 
> > 2.7.4
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
