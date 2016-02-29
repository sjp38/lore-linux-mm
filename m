Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4D9828DF
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:04:20 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so50827112wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:04:20 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id 3si20529927wmk.45.2016.02.29.06.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:04:19 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id l68so63987917wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:04:18 -0800 (PST)
Date: Mon, 29 Feb 2016 17:04:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/18] change mmap_sem taken for write killable
Message-ID: <20160229140416.GA12506@node.shutemov.name>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Feb 29, 2016 at 02:26:39PM +0100, Michal Hocko wrote:
> Hi,
> this is a follow up work for oom_reaper [1]. As the async OOM killing
> depends on oom_sem for read we would really appreciate if a holder for
> write stood in the way. This patchset is changing many of down_write
> calls to be killable to help those cases when the writer is blocked and
> waiting for readers to release the lock and so help __oom_reap_task to
> process the oom victim.
> 
> Most of the patches are really trivial because the lock is help from a
> shallow syscall paths where we can return EINTR trivially. Others seem
> to be easy as well as the callers are already handling fatal errors and
> bail and return to userspace which should be sufficient to handle the
> failure gracefully. I am not familiar with all those code paths so a
> deeper review is really appreciated.

What about effect on userspace? IIUC, we would have now EINTR returned
from bunch of syscall, which haven't had this errno on the table before.
Should we care?

> As this work is touching more areas which are not directly connected I
> have tried to keep the CC list as small as possible and people who I
> believed would be familiar are CCed only to the specific patches (all
> should have received the cover though).
> 
> This patchset is based on linux-next and it depends on down_write_killable
> for rw_semaphores posted recently [2].
> 
> I haven't covered all the mmap_write(mm->mmap_sem) instances here
> 
> $ git grep "down_write(.*\<mmap_sem\>)" next/master | wc -l
> 102
> $ git grep "down_write(.*\<mmap_sem\>)" | wc -l
> 66
> 
> I have tried to cover those which should be relatively easy to review in
> this series because this alone should be a nice improvement. Other places
> can be changed on top.
> 
> Any feedback is highly appreciated.
> 
> ---
> [1] http://lkml.kernel.org/r/1452094975-551-1-git-send-email-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/1456750705-7141-1-git-send-email-mhocko@kernel.org
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
