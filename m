Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26E916B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:21:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 185so2064574wmk.12
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:21:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w44si4783022wrc.542.2017.08.10.01.21.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 01:21:20 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:21:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170810082118.GH23863@dhcp22.suse.cz>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
 <20170808174855.GK25347@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808174855.GK25347@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 08-08-17 19:48:55, Andrea Arcangeli wrote:
[...]
> The bug corrected by this patch 1/2 I pointed it out last week while
> reviewing other oom reaper fixes so that looks fine.
> 
> However I'd prefer to dump MMF_UNSTABLE for good instead of adding
> more of it. It can be replaced with unmap_page_range in
> __oom_reap_task_mm with a function that arms a special migration entry
> so that no branchs are added to the fast paths and it's all hidden
> inside is_migration_entry slow paths.

This sounds like an interesting idea but I would like to address the
_correctness_ issue first and optimize on top of it. If for nothing else
backporting a follow up fix sounds easier than a complete rework. There
are quite some callers of is_migration_entry and the patch won't be
trivial either. So can we focus on the fix first please?

[...]

> Overall OOM killing to me was reliable also before the oom reaper was
> introduced.

Yeah, this is the case in my experience as well but there are others
claiming otherwise and implementation wise the code was really fragile
enough to support their claims. Unbound lockup on TIF_MEMDIE task just
asks for troubles, especially when we have no idea what the oom victim
might be doing. Things are very simple when the victim was kicked out
from the userspace but this all gets very hairy when it was somewhere in
the kernel waiting for locks. It seems that we are mostly lucky in the
global oom situations. We have seen lockups with memcgs and had to move
the memcg oom handling to a lockless PF context. Those two were not too
different except the memcg was easier to hit.

[...]

> A couple of years ago I could trivially trigger OOM deadlocks on
> various ext4 paths that loops or use GFP_NOFAIL, but that was just a
> matter of letting GFP_NOIO/NOFS/NOFAIL kind of allocation go through
> memory reserves below the low watermark.

You would have to identify the dependency chain to do this properly,
otherwise you simply consume memory reserves and you are back to square
one.

> It is also fine to kill a few more processes in fact.

I strongly disagree. It might be acceptable to kill more tasks if there
is absolutely no other choice. OOM killing is a very disruptive action
and we shoud _really_ reduce it to absolute minimum.

[...]
> The main point of the oom reaper nowadays is to free memory fast
> enough so a second task isn't killed as a false positive, but it's not
> like anybody will notice much of a difference if a second task is
> killed, it wasn't commonly happening either.

No, you seem to misunderstand. Adding a kernel thread to optimize a
glacial kind of slow path would be really hard to justify. The sole
purpose of the oom reaper is _reliability_. We do not select another
task from an oom domain if there is an existing oom victim alive. So we
do not need the reaper to prevent another victim selection. All we need
this async context for is to _guarantee_ that somebody tries to reclaim
as much memory of the victim as possible and then allow the oom killer
to continue if the OOM situation is not resolve. Because that endless
waiting for a sync context is what causes those lockups.

> Certainly it's preferable to get two tasks killed than corrupted core
> dumps or corrupted memory, so if oom reaper will stay we need to
> document how we guarantee it's mutually exclusive against core dumping

corrupted anonymous memory in the core dump was deemed acceptable
trade off to get a more reliable oom handling. If there is a strong
usecase for the reliable core dump then we can work on it, of course but
the system stability is at the first place IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
