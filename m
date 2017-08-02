Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 735FF6B05DD
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 11:55:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p48so23058461qtf.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 08:55:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si32739026qkt.272.2017.08.02.08.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 08:55:25 -0700 (PDT)
Date: Wed, 2 Aug 2017 17:55:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Message-ID: <20170802155522.GB21775@redhat.com>
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170731122204.GB4878@dhcp22.suse.cz>
 <20170731133247.GK29716@redhat.com>
 <20170731134507.GC4829@dhcp22.suse.cz>
 <20170802123440.GD17905@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802123440.GD17905@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Wed, Aug 02, 2017 at 03:34:41PM +0300, Mike Rapoport wrote:
> I surely can take care of CRIU, but I don't know if QEMU or certain
> database application that uses userfaultfd rely on this API, not mentioning
> there maybe other unknown users.
> 
> Andrea, what do you think?

The manpage would need updates, from v4.11 to v4.13 -ENOSPC, from v4.1
-ESRCH and I don't see the benefit and it just looks confusion for
nothing, but if somebody feel strongly about it and does the work (and
risks to take the blame if something breaks...) I wouldn't be against
it, it won't make much of a difference anyway.

The reason I don't see any benefit in code readability is that I don't
see ESRCH as an obviously better retval, because if you grep for ESRCH
you'll see it's a failure to find a process with a certain pid, it is
an obvious retval when you're dealing with processes and pids, but we
never search pids and in fact the pid and the process may be already
gone but we still won't return ESRCH. UFFDIO_COPY never takes a pid as
parameter anywhere so why to return ESRCH? ENOSPC shall be interpreted
"no memory avail to copy anything", ESRCH as far as I can tell, could
be as unexpected as ENOSPC is you don't specify a pid as parameter to
the kernel.

If the mm_users is already zero and the mm is gone it means the
process is gone too, that is true, but the process could be gone
already and we could still obtain the mm_users and run UFFDIO_COPY if
there's async I/O pending or something. There's no association between
process/pid being still alive and the need to run a UFFDIO_COPY and
succeed at it.

Not ever dealing with pids and processes is why not even ESRCH is an
obvious perfect match for such an error, and this is why I think such
a change now would add no tangible pros and only short term cons.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
