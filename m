Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3B868828E2
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:41:42 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so37277311wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:41:42 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y125si20413838wmy.113.2016.02.29.05.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 05:41:41 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id l68so8281076wml.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:41:41 -0800 (PST)
Date: Mon, 29 Feb 2016 14:41:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/5] oom reaper: handle mlocked pages
Message-ID: <20160229134139.GB16930@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-3-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1602221734140.4688@chino.kir.corp.google.com>
 <20160223132157.GD14178@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602281844180.3975@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602281844180.3975@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun 28-02-16 19:19:11, Hugh Dickins wrote:
> On Tue, 23 Feb 2016, Michal Hocko wrote:
> > On Mon 22-02-16 17:36:07, David Rientjes wrote:
> > > 
> > > Are we concerned about munlock_vma_pages_all() taking lock_page() and 
> > > perhaps stalling forever, the same way it would stall in exit_mmap() for 
> > > VM_LOCKED vmas, if another thread has locked the same page and is doing an 
> > > allocation?
> > 
> > This is a good question. I have checked for that particular case
> > previously and managed to convinced myself that this is OK(ish).
> > munlock_vma_pages_range locks only THP pages to prevent from the
> > parallel split-up AFAICS.
> 
> I think you're mistaken on that: there is also the lock_page()
> on every page in Phase 2 of __munlock_pagevec().

Ohh, I have missed that one. Thanks for pointing it out!

[...]
> > Just for the reference this is what I came up with (just compile tested).
> 
> I tried something similar internally (on an earlier kernel).  Like
> you I've set that work aside for now, there were quicker ways to fix
> the issue at hand.  But it does continue to offend me that munlock
> demands all those page locks: so if you don't get back to it before me,
> I shall eventually.
> 
> I didn't understand why you complicated yours with the "enforce"
> arg to munlock_vma_pages_range(): why not just trylock in all cases?

Well, I have to confess that I am not really sure I understand all the
consequences of the locking here. It has always been subtle and weird
issues popping up from time to time. So I only wanted to have that
change limitted to the oom_reaper. So I would really appreciate if
somebody more knowledgeable had a look. We can drop the mlock patch for
now.

Thanks for looking into this, Hugh!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
