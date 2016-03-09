Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA37B6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 05:16:54 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so63937438wml.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:16:54 -0800 (PST)
Date: Wed, 9 Mar 2016 11:16:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/18] ipc, shm: make shmem attach/detach wait for
 mmap_sem killable
Message-ID: <20160309101651.GE27018@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-10-git-send-email-mhocko@kernel.org>
 <20160308191550.GA4404@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160308191550.GA4404@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian K?nig <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On Tue 08-03-16 11:15:50, Davidlohr Bueso wrote:
> On Mon, 29 Feb 2016, Michal Hocko wrote:
> 
> >From: Michal Hocko <mhocko@suse.com>
> >
> >shmat and shmdt rely on mmap_sem for write. If the waiting task
> >gets killed by the oom killer it would block oom_reaper from
> >asynchronous address space reclaim and reduce the chances of timely
> >OOM resolving. Wait for the lock in the killable mode and return with
> >EINTR if the task got killed while waiting.
> >
> >Cc: Davidlohr Bueso <dave@stgolabs.net>
> >Cc: Hugh Dickins <hughd@google.com>
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I have no objection to this perse, just one comment below.
> 
> Acked-by: Davidlohr Bueso <dave@stgolabs.net>

Thanks!

[...]
> >-	down_write(&current->mm->mmap_sem);
> >+	if (down_write_killable(&current->mm->mmap_sem)) {
> >+		err = -EINVAL;
> >+		goto out_fput;
> >+	}
> 
> This should be EINTR, no?

Of course. Thanks for catching that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
