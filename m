Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733506B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 16:19:51 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i77-v6so3270762ywe.19
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 13:19:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e62-v6sor1154297ywa.174.2018.07.27.13.19.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 13:19:45 -0700 (PDT)
Date: Fri, 27 Jul 2018 16:22:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Making direct reclaim fail when thrashing
Message-ID: <20180727202236.GB12399@cmpxchg.org>
References: <20180727162143.26466-1-drake@endlessm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727162143.26466-1-drake@endlessm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Drake <drake@endlessm.com>
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux@endlessm.com, linux-kernel@vger.kernel.org

On Fri, Jul 27, 2018 at 11:21:43AM -0500, Daniel Drake wrote:
> Split from the thread
>   [PATCH 0/10] psi: pressure stall information for CPU, memory, and IO v2
> where we were discussing if/how to make the direct reclaim codepath
> fail if we're excessively thrashing, so that the OOM killer might
> step in. This is potentially desirable when the thrashing is so bad
> that the UI stops responding, causing the user to pull the plug.
> 
> On Tue, Jul 17, 2018 at 7:23 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > mm/workingset.c allows for tracking when an actual page got evicted.
> > workingset_refault tells us whether a give filemap fault is a recent
> > refault and activates the page if that is the case. So what you need is
> > to note how many refaulted pages we have on the active LRU list. If that
> > is a large part of the list and if the inactive list is really small
> > then we know we are trashing. This all sounds much easier than it will
> > eventually turn out to be of course but I didn't really get to play with
> > this much.

I've mentioned it in the other thread, but whether refaults are a
performance/latency problem depends 99% on your available IO capacity
and the IO patterns. On a highly contended IO device, refaults of a
single unfortunately located page can lead to multi-second stalls. On
an idle SSD, thousands of refaults might not be noticable to the user.

Without measuring how much time these events take out of your day, you
can't really tell eif they're a problem or not. The event rate or the
proportion between pages and refaults doesn't carry that signal.
