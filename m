Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E04CD6B0607
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 09:45:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h126so20288808wmf.10
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 06:45:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38si15643978wry.326.2017.07.31.06.45.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 06:45:09 -0700 (PDT)
Date: Mon, 31 Jul 2017 15:45:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Message-ID: <20170731134507.GC4829@dhcp22.suse.cz>
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
 <20170731133247.GK29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731133247.GK29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Mon 31-07-17 15:32:47, Andrea Arcangeli wrote:
> On Mon, Jul 31, 2017 at 02:22:04PM +0200, Michal Hocko wrote:
> > On Thu 27-07-17 09:26:59, Mike Rapoport wrote:
> > > In the non-cooperative userfaultfd case, the process exit may race with
> > > outstanding mcopy_atomic called by the uffd monitor.  Returning -ENOSPC
> > > instead of -EINVAL when mm is already gone will allow uffd monitor to
> > > distinguish this case from other error conditions.
> > 
> > Normally we tend to return ESRCH in such case. ENOSPC sounds rather
> > confusing...
> 
> This is in sync and consistent with the retval for UFFDIO_COPY upstream:
> 
> 	if (mmget_not_zero(ctx->mm)) {
> 		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
> 				   uffdio_copy.len);
> 		mmput(ctx->mm);
> 	} else {
> 		return -ENOSPC;
> 	}
> 
> If you preferred ESRCH I certainly wouldn't have been against, but we
> should have discussed it before it was upstream. All it matters is
> it's documented in the great manpage that was written for it as quoted
> below.

OK, I wasn't aware of this.
 
> +.TP
> +.B ENOENT
> +(Since Linux 4.11)
> +The faulting process has changed
> +its virtual memory layout simultaneously with outstanding
> +.I UFFDIO_COPY
> +operation.
> +.TP
> +.B ENOSPC
> +(Since Linux 4.11)
> +The faulting process has exited at the time of
> +.I UFFDIO_COPY
> +operation.
> 
> To change it now, we would need to involve manpage and other code
> changes.

Well, ESRCH is more appropriate so I would rather change it sooner than
later. But if we are going to risk user space breakage then this is not
worth the risk. I expected there are very few users of this API
currently so maybe it won't be a big disaster?

Anyway, at least this is documented so I will leave the decision to you.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
