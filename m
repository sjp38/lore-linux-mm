Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 936D38E0086
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 08:46:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w18so6501194qts.8
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 05:46:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g194sor26762912qka.139.2019.01.24.05.46.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 05:46:48 -0800 (PST)
Date: Thu, 24 Jan 2019 08:46:46 -0500
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: possible deadlock in __do_page_fault
Message-ID: <20190124134646.GA53008@google.com>
References: <201901230201.x0N214eq043832@www262.sakura.ne.jp>
 <20190123155751.GA168927@google.com>
 <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Jan 24, 2019 at 10:52:30AM +0900, Tetsuo Handa wrote:
> Joel Fernandes wrote:
> > > Anyway, I need your checks regarding whether this approach is waiting for
> > > completion at all locations which need to wait for completion.
> > 
> > I think you are waiting in unwanted locations. The only location you need to
> > wait in is ashmem_pin_unpin.
> > 
> > So, to my eyes all that is needed to fix this bug is:
> > 
> > 1. Delete the range from the ashmem_lru_list
> > 2. Release the ashmem_mutex
> > 3. fallocate the range.
> > 4. Do the completion so that any waiting pin/unpin can proceed.
> > 
> > Could you clarify why you feel you need to wait for completion at those other
> > locations?
> 
> Because I don't know how ashmem works.

You sound like you're almost there though.

> > Note that once a range is unpinned, it is open sesame and userspace cannot
> > really expect consistent data from such range till it is pinned again.
> 
> Then, I'm tempted to eliminate shrinker and LRU list (like a draft patch shown
> below). I think this is not equivalent to current code because this shrinks
> upon only range_alloc() time and I don't know whether it is OK to temporarily
> release ashmem_mutex during range_alloc() at "Case #4" of ashmem_pin(), but
> can't we go this direction? 

No, the point of the shrinker is to do a lazy free. We cannot free things
during unpin since it can be pinned again and we need to find that range by
going through the list. We also cannot get rid of any lists. Since if
something is re-pinned, we need to find it and find out if it was purged. We
also need the list for knowing what was unpinned so the shrinker works.

By the way, all this may be going away quite soon (the whole driver) as I
said, so just give it a little bit of time.

I am happy to fix it soon if that's not the case (which I should know soon -
like a couple of weeks) but I'd like to hold off till then.

> By the way, why not to check range_alloc() failure before calling range_shrink() ?

That would be a nice thing to do. Send a patch?

thanks,

 - Joel
