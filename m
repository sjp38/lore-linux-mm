Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7EA36B05D1
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 08:34:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u89so5893839wrc.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 05:34:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 93si27008277wra.429.2017.08.02.05.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 05:34:56 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72CYm81126871
	for <linux-mm@kvack.org>; Wed, 2 Aug 2017 08:34:55 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c3bf0t1ca-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 Aug 2017 08:34:54 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 2 Aug 2017 13:34:47 +0100
Date: Wed, 2 Aug 2017 15:34:41 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
 <20170731133247.GK29716@redhat.com>
 <20170731134507.GC4829@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731134507.GC4829@dhcp22.suse.cz>
Message-Id: <20170802123440.GD17905@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Mon, Jul 31, 2017 at 03:45:08PM +0200, Michal Hocko wrote:
> On Mon 31-07-17 15:32:47, Andrea Arcangeli wrote:
> > On Mon, Jul 31, 2017 at 02:22:04PM +0200, Michal Hocko wrote:
> > > On Thu 27-07-17 09:26:59, Mike Rapoport wrote:
> > > > In the non-cooperative userfaultfd case, the process exit may race with
> > > > outstanding mcopy_atomic called by the uffd monitor.  Returning -ENOSPC
> > > > instead of -EINVAL when mm is already gone will allow uffd monitor to
> > > > distinguish this case from other error conditions.
> > > 
> > > Normally we tend to return ESRCH in such case. ENOSPC sounds rather
> > > confusing...
> > 
> > This is in sync and consistent with the retval for UFFDIO_COPY upstream:
> > 
> > 	if (mmget_not_zero(ctx->mm)) {
> > 		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
> > 				   uffdio_copy.len);
> > 		mmput(ctx->mm);
> > 	} else {
> > 		return -ENOSPC;
> > 	}
> > 
> > If you preferred ESRCH I certainly wouldn't have been against, but we
> > should have discussed it before it was upstream. All it matters is
> > it's documented in the great manpage that was written for it as quoted
> > below.
> 
> OK, I wasn't aware of this.
> 
> > +.TP
> > +.B ENOENT
> > +(Since Linux 4.11)
> > +The faulting process has changed
> > +its virtual memory layout simultaneously with outstanding
> > +.I UFFDIO_COPY
> > +operation.
> > +.TP
> > +.B ENOSPC
> > +(Since Linux 4.11)
> > +The faulting process has exited at the time of
> > +.I UFFDIO_COPY
> > +operation.
> > 
> > To change it now, we would need to involve manpage and other code
> > changes.
> 
> Well, ESRCH is more appropriate so I would rather change it sooner than
> later. But if we are going to risk user space breakage then this is not
> worth the risk. I expected there are very few users of this API
> currently so maybe it won't be a big disaster?

I surely can take care of CRIU, but I don't know if QEMU or certain
database application that uses userfaultfd rely on this API, not mentioning
there maybe other unknown users.

Andrea, what do you think?

> Anyway, at least this is documented so I will leave the decision to you.
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
