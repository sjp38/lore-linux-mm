Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 822A06B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:33:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e204so3060598wma.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:33:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o104si5246465wrb.203.2017.08.10.06.33.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 06:33:43 -0700 (PDT)
Date: Thu, 10 Aug 2017 15:33:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170810133338.GV23863@dhcp22.suse.cz>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
 <20170808174855.GK25347@redhat.com>
 <20170810082118.GH23863@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810082118.GH23863@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 10-08-17 10:21:18, Michal Hocko wrote:
> On Tue 08-08-17 19:48:55, Andrea Arcangeli wrote:
> [...]
> > The bug corrected by this patch 1/2 I pointed it out last week while
> > reviewing other oom reaper fixes so that looks fine.
> > 
> > However I'd prefer to dump MMF_UNSTABLE for good instead of adding
> > more of it. It can be replaced with unmap_page_range in
> > __oom_reap_task_mm with a function that arms a special migration entry
> > so that no branchs are added to the fast paths and it's all hidden
> > inside is_migration_entry slow paths.
> 
> This sounds like an interesting idea but I would like to address the
> _correctness_ issue first and optimize on top of it. If for nothing else
> backporting a follow up fix sounds easier than a complete rework. There
> are quite some callers of is_migration_entry and the patch won't be
> trivial either. So can we focus on the fix first please?

Btw, if the overhead is a concern then we can add a jump label and only
make the code active only while the OOM is in progress. We already do
count all oom victims so we have a clear entry and exit points. This
would still sound easier to do than teach every is_migration_entry a new
migration entry type and handle it properly, not to mention make
everybody aware of this for future callers of is_migration_entry.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
