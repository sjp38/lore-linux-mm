Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECAD6B007E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:16:15 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p65so163244513wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:16:15 -0800 (PST)
Date: Tue, 8 Mar 2016 11:15:50 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 09/18] ipc, shm: make shmem attach/detach wait for
 mmap_sem killable
Message-ID: <20160308191550.GA4404@linux-uzut.site>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-10-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1456752417-9626-10-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian K?nig <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

On Mon, 29 Feb 2016, Michal Hocko wrote:

>From: Michal Hocko <mhocko@suse.com>
>
>shmat and shmdt rely on mmap_sem for write. If the waiting task
>gets killed by the oom killer it would block oom_reaper from
>asynchronous address space reclaim and reduce the chances of timely
>OOM resolving. Wait for the lock in the killable mode and return with
>EINTR if the task got killed while waiting.
>
>Cc: Davidlohr Bueso <dave@stgolabs.net>
>Cc: Hugh Dickins <hughd@google.com>
>Signed-off-by: Michal Hocko <mhocko@suse.com>

I have no objection to this perse, just one comment below.

Acked-by: Davidlohr Bueso <dave@stgolabs.net>

>---
> ipc/shm.c | 9 +++++++--
> 1 file changed, 7 insertions(+), 2 deletions(-)
>
>diff --git a/ipc/shm.c b/ipc/shm.c
>index 331fc1b0b3c7..b8cfa05940d2 100644
>--- a/ipc/shm.c
>+++ b/ipc/shm.c
>@@ -1200,7 +1200,11 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
> 	if (err)
> 		goto out_fput;
>
>-	down_write(&current->mm->mmap_sem);
>+	if (down_write_killable(&current->mm->mmap_sem)) {
>+		err = -EINVAL;
>+		goto out_fput;
>+	}

This should be EINTR, no?

Thanks,
Davidlohr

>+
> 	if (addr && !(shmflg & SHM_REMAP)) {
> 		err = -EINVAL;
> 		if (addr + size < addr)
>@@ -1271,7 +1275,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
> 	if (addr & ~PAGE_MASK)
> 		return retval;
>
>-	down_write(&mm->mmap_sem);
>+	if (down_write_killable(&mm->mmap_sem))
>+		return -EINTR;
>
> 	/*
> 	 * This function tries to be smart and unmap shm segments that
>-- 
>2.7.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
