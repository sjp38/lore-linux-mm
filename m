Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0751F6B0009
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:10 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so45307334wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/18] change mmap_sem taken for write killable
Date: Mon, 29 Feb 2016 14:26:39 +0100
Message-Id: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

Hi,
this is a follow up work for oom_reaper [1]. As the async OOM killing
depends on oom_sem for read we would really appreciate if a holder for
write stood in the way. This patchset is changing many of down_write
calls to be killable to help those cases when the writer is blocked and
waiting for readers to release the lock and so help __oom_reap_task to
process the oom victim.

Most of the patches are really trivial because the lock is help from a
shallow syscall paths where we can return EINTR trivially. Others seem
to be easy as well as the callers are already handling fatal errors and
bail and return to userspace which should be sufficient to handle the
failure gracefully. I am not familiar with all those code paths so a
deeper review is really appreciated.

As this work is touching more areas which are not directly connected I
have tried to keep the CC list as small as possible and people who I
believed would be familiar are CCed only to the specific patches (all
should have received the cover though).

This patchset is based on linux-next and it depends on down_write_killable
for rw_semaphores posted recently [2].

I haven't covered all the mmap_write(mm->mmap_sem) instances here

$ git grep "down_write(.*\<mmap_sem\>)" next/master | wc -l
102
$ git grep "down_write(.*\<mmap_sem\>)" | wc -l
66

I have tried to cover those which should be relatively easy to review in
this series because this alone should be a nice improvement. Other places
can be changed on top.

Any feedback is highly appreciated.

---
[1] http://lkml.kernel.org/r/1452094975-551-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1456750705-7141-1-git-send-email-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
