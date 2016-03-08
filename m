Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC8E6B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 15:07:36 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fe3so4005748pab.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 12:07:36 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ey9si6697860pab.123.2016.03.08.12.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 12:07:35 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id bj10so19759311pad.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 12:07:35 -0800 (PST)
Date: Tue, 8 Mar 2016 12:07:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/5] oom reaper: handle mlocked pages
In-Reply-To: <20160308134032.GG13542@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1603081139380.8735@eggly.anvils>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org> <1454505240-23446-3-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1602221734140.4688@chino.kir.corp.google.com> <20160223132157.GD14178@dhcp22.suse.cz> <alpine.LSU.2.11.1602281844180.3975@eggly.anvils>
 <20160229134139.GB16930@dhcp22.suse.cz> <20160308134032.GG13542@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 8 Mar 2016, Michal Hocko wrote:
> On Mon 29-02-16 14:41:39, Michal Hocko wrote:
> > On Sun 28-02-16 19:19:11, Hugh Dickins wrote:
> > > On Tue, 23 Feb 2016, Michal Hocko wrote:
> > > > On Mon 22-02-16 17:36:07, David Rientjes wrote:
> > > > > 
> > > > > Are we concerned about munlock_vma_pages_all() taking lock_page() and 
> > > > > perhaps stalling forever, the same way it would stall in exit_mmap() for 
> > > > > VM_LOCKED vmas, if another thread has locked the same page and is doing an 
> > > > > allocation?
> > > > 
> > > > This is a good question. I have checked for that particular case
> > > > previously and managed to convinced myself that this is OK(ish).
> > > > munlock_vma_pages_range locks only THP pages to prevent from the
> > > > parallel split-up AFAICS.
> > > 
> > > I think you're mistaken on that: there is also the lock_page()
> > > on every page in Phase 2 of __munlock_pagevec().
> > 
> > Ohh, I have missed that one. Thanks for pointing it out!
> > 
> > [...]
> > > > Just for the reference this is what I came up with (just compile tested).
> > > 
> > > I tried something similar internally (on an earlier kernel).  Like
> > > you I've set that work aside for now, there were quicker ways to fix
> > > the issue at hand.  But it does continue to offend me that munlock
> > > demands all those page locks: so if you don't get back to it before me,
> > > I shall eventually.
> > > 
> > > I didn't understand why you complicated yours with the "enforce"
> > > arg to munlock_vma_pages_range(): why not just trylock in all cases?
> > 
> > Well, I have to confess that I am not really sure I understand all the
> > consequences of the locking here. It has always been subtle and weird
> > issues popping up from time to time. So I only wanted to have that
> > change limitted to the oom_reaper. So I would really appreciate if
> > somebody more knowledgeable had a look. We can drop the mlock patch for
> > now.
> 
> According to the rc7 announcement it seems we are approaching the merge
> window. Should we drop the patch for now or the risk of the lockup is
> too low to care about and keep it in for now as it might be already
> useful and change the munlock path to not depend on page locks later on?
> 
> I am OK with both ways.

You're asking about the Subject patch, "oom reaper: handle mlocked pages",
I presume.  Your Work-In-Progress mods to munlock_vma_pages_range() should
certainly be dropped for now, and revisited by one of us another time.

I vote for dropping "oom reaper: handle mlocked pages" for now too.
If I understand correctly, the purpose of the oom reaper is to free up
as much memory from the targeted task as possible, while avoiding getting
stuck on locks; in advance of the task actually exiting and doing the
freeing itself, but perhaps getting stuck on locks as it does so.

If that's a fair description, then it's inappropriate for the oom reaper
to call munlock_vma_pages_all(), with the risk of getting stuck on many
page locks; best leave that risk to the task when it exits as at present.
Of course we should come back to this later, fix munlock_vma_pages_range()
with trylocks (on the pages only? rmap mutexes also?), and then integrate
"oom reaper: handle mlocked pages".

(Or if we had the old mechanism for scanning unevictable lrus on demand,
perhaps simply not avoid the VM_LOCKED vmas in __oom_reap_vmas(), let
the clear_page_mlock() in page_remove_*rmap() handle all the singly
mapped and mlocked pages, and un-mlock the rest by scanning unevictables.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
