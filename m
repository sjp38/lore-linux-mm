Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3AF6B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 07:47:45 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id m5so5322761qaj.11
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 04:47:44 -0700 (PDT)
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
        by mx.google.com with ESMTPS id p5si18748048qah.13.2014.09.16.04.47.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 04:47:44 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id l6so5823173qcy.15
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 04:47:43 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 16 Sep 2014 07:47:41 -0400
Subject: Re: [PATCH 0/4] Remove possible deadlocks in nfs_release_page()
Message-ID: <20140916074741.1de870c5@tlielax.poochiereds.net>
In-Reply-To: <20140916051911.22257.24658.stgit@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

On Tue, 16 Sep 2014 15:31:34 +1000
NeilBrown <neilb@suse.de> wrote:

> Because nfs_release_page() submits a 'COMMIT' nfs request and waits
> for it to complete, and does this during memory reclaim, it is
> susceptible to deadlocks if memory allocation happens anywhere in
> sending the COMMIT message.  If the NFS server is on the same host
> (i.e. loop-back NFS), then any memory allocations in the NFS server
> can also cause deadlocks.
> 
> nfs_release_page() already has some code to avoid deadlocks in some
> circumstances, but these are not sufficient for loopback NFS.
> 
> This patch set changes the approach to deadlock avoidance.  Rather
> than detecting cases that could deadlock and avoiding the COMMIT, it
> always tries the COMMIT, but only waits a short time (1 second).
> This avoid any deadlock possibility at the expense of not waiting
> longer than 1 second even if no deadlock is pending.
> 
> nfs_release_page() does not *need* to wait longer - all callers that
> matter handle a failure gracefully - they move on to other pages.
> 
> This set:
>  - adds some "_timeout()" functions to "wait_on_bit".  Only a
>    wait_on_page version is actually used.
>  - exports page wake_up support.  NFS knows that the COMMIT is complete
>    when PG_private is clear.  So nfs_release_page will use
>    wait_on_page_bit_killable_timeout to wait for the bit to clear,
>    and needs access to wake_up_page()
>  - changes nfs_release_page() to use
>     wait_on_page_bit_killable_timeout()
>  - removes the other deadlock avoidance mechanisms from
>    nfs_release_page, so that PF_FSTRANS is again only used
>    by XFS.
> 
> As such, it needs buy-in from sched people, mm people, and NFS people.
> Assuming I get that buy-in, suggests for how these patches can flow
> into mainline would be appreciated ... I daren't hope they can all go
> in through one tree....
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (4):
>       SCHED: add some "wait..on_bit...timeout()" interfaces.
>       MM: export page_wakeup functions
>       NFS: avoid deadlocks with loop-back mounted NFS filesystems.
>       NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()
> 
> 
>  fs/nfs/file.c                   |   22 ++++++++++++----------
>  fs/nfs/write.c                  |    2 ++
>  include/linux/pagemap.h         |   12 ++++++++++--
>  include/linux/wait.h            |    5 ++++-
>  kernel/sched/wait.c             |   36 ++++++++++++++++++++++++++++++++++++
>  mm/filemap.c                    |   21 +++++++++++++++------
>  net/sunrpc/sched.c              |    2 --
>  net/sunrpc/xprtrdma/transport.c |    2 --
>  net/sunrpc/xprtsock.c           |   10 ----------
>  9 files changed, 79 insertions(+), 33 deletions(-)
> 

On balance, I like the NFS parts of this set -- particular the fact
that we get rid of the PF_FSTRANS abortion, and simplify the code quite
a bit. My only real concern is that you could end up stalling in this
code in situations where you really can't release the page.

For instance, suppose you're trying to reconnect the socket to the
server (a'la xs_tcp_setup_socket). The VM is low on memory and tries to
release a page that needs that socket in order to issue a COMMIT. That
situation is going to end up with the page unable to be released, but
you'll still wait 1s before returning. If the VM tries to release a
bunch of pages like this, then those waits could add up.

Also, we call things like invalidate_complete_page2 from the cache
invalidation code. Will we end up with potential problems now that we
have a stronger possibility that a page might not be freeable when it
calls releasepage? (no idea on this -- I'm just spitballing)

-- 
Jeff Layton <jlayton@primarydata.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
