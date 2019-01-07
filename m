Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5788E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 23:32:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so37042881edd.11
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 20:32:44 -0800 (PST)
Received: from nautica.notk.org (nautica.notk.org. [91.121.71.147])
        by mx.google.com with ESMTPS id w11si212430eda.242.2019.01.06.20.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Jan 2019 20:32:42 -0800 (PST)
Date: Mon, 7 Jan 2019 05:32:27 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190107043227.GA3325@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Linus Torvalds wrote on Sat, Jan 05, 2019:
> But I think my patch to just rip out all that page lookup, and just
> base it on the page table state has the fundamental advantage that it
> gets rid of code. Maybe I should jst commit it, and see if anything
> breaks? We do have options in case things break, and then we'd at
> least know who cares (and perhaps a lot more information of _why_ they
> care).

There actually are many tools like fincore which depend on mincore to
try to tell whether a file is "loaded in cache" or not (I personally use
vmtouch[1], but I know of at least nocache[2] uses it as well to only
try to evict used pages)

[1] https://hoytech.com/vmtouch/
[2] https://github.com/Feh/nocache


I mostly use these to either fadvise(POSIX_FADV_DONTNEED) or
prefetch/lock whole files so my "production" use-cases don't actually
rely on the mincore part of them; but when playing with these actions
it's actually fairly useful to be able to visualize which part of a file
ended in cache or monitor how a file's content evolve in cache...

There are various non-obvious behaviours where being able to poke around
is enlightening (e.g. fadvise dontneed is actually a hint, so even if
nothing uses the file linux sometimes keep the data around if it thinks
that would be useful and nocache has a mode to call fadvise multiple
times and things like that...)


Anyway, I agree the use of mincore for this is rather ugly, and
frankly some "cache management API" might be better in the long run if
only for performance reason (don't try these tools on a hundred TB
sparse file...), but until that pipe dream comes true I think mincore as
it was is useful for system admins.



Linus Torvalds wrote on Sun, Jan 06, 2019:
> I decided to just apply that patch. It is *not* marked for stable,
> very intentionally, because I expect that we will need to wait and see
> if there are issues with it, and whether we might have to do something
> entirely different (more like the traditional behavior with some extra
> "only for owner" logic).

FWIW I personally don't care much about "only for owner" or depending on
mmap options; I don't understand much of the security implications
honestly so I'm not sure how these limitations actually help.
On the other hand, a simple CAP_SYS_ADMIN check making the call take
either behaviour should be safe and would cover what I described above.


(by the way, while we are discussing permissions, a regular user can use
fadvise dontneed on files it doesn't own as well as long as it can open
them for reading; I'm not sure if that would need restricting as well in
the context of the security issue. Frankly even with mincore someone
could likely tell the difference through timing, if they just do it a
few times. Do magic, probe, flush out, repeat until satisfied.)


Thanks,
-- 
Dominique Martinet | Asmadeus
