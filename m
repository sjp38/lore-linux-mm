Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6BA6B05E0
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:22:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g32so6660152wrd.8
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:22:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si25221646wrb.275.2017.08.02.09.22.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 09:22:53 -0700 (PDT)
Date: Wed, 2 Aug 2017 18:22:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Message-ID: <20170802162248.GA3476@dhcp22.suse.cz>
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
 <20170731133247.GK29716@redhat.com>
 <20170731134507.GC4829@dhcp22.suse.cz>
 <20170802123440.GD17905@rapoport-lnx>
 <20170802155522.GB21775@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802155522.GB21775@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Wed 02-08-17 17:55:22, Andrea Arcangeli wrote:
> On Wed, Aug 02, 2017 at 03:34:41PM +0300, Mike Rapoport wrote:
> > I surely can take care of CRIU, but I don't know if QEMU or certain
> > database application that uses userfaultfd rely on this API, not mentioning
> > there maybe other unknown users.
> > 
> > Andrea, what do you think?
> 
> The manpage would need updates, from v4.11 to v4.13 -ENOSPC, from v4.1
> -ESRCH and I don't see the benefit and it just looks confusion for
> nothing, but if somebody feel strongly about it and does the work (and
> risks to take the blame if something breaks...) I wouldn't be against
> it, it won't make much of a difference anyway.
> 
> The reason I don't see any benefit in code readability is that I don't
> see ESRCH as an obviously better retval, because if you grep for ESRCH
> you'll see it's a failure to find a process with a certain pid, it is
> an obvious retval when you're dealing with processes and pids, but we
> never search pids and in fact the pid and the process may be already
> gone but we still won't return ESRCH. UFFDIO_COPY never takes a pid as
> parameter anywhere so why to return ESRCH?

ESRCH refers to "no such process". Strictly speaking userfaultfd code is
about a mm which is gone but that is a mere detail. In fact the owner of
the mm is gone as well. You might not refer to the process by its pid
but you are surely refer to a process via its address space. That's why
I think this error code is more appropriate.

But as I've said, this might be really risky to change. My impression
was that userfaultfd is not widely used yet and those can be fixed
easily but if that is not the case then we have to live with the current
ENOSPC.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
