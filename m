Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2CFB6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:43:33 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so135901363ioj.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 23:43:33 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y66si3273780ita.42.2016.06.16.23.43.32
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 23:43:32 -0700 (PDT)
Date: Fri, 17 Jun 2016 15:43:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160617064330.GD2374@bbox>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
 <20160613150653.GA30642@cmpxchg.org>
 <20160615004027.GA17127@bbox>
 <20160616144102.GA17692@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160616144102.GA17692@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Sangwoo Park <sangwoo2.park@lge.com>

Hi Hannes,

On Thu, Jun 16, 2016 at 10:41:02AM -0400, Johannes Weiner wrote:
> On Wed, Jun 15, 2016 at 09:40:27AM +0900, Minchan Kim wrote:
> > A question is it seems cgroup2 doesn't have per-cgroup swappiness.
> > Why?
> > 
> > I think we need it in one-cgroup-per-app model.
> 
> Can you explain why you think that?
> 
> As we have talked about this recently in the LRU balancing thread,
> swappiness is the cost factor between file IO and swapping, so the
> only situation I can imagine you'd need a memcg swappiness setting is
> when you have different cgroups use different storage devices that do
> not have comparable speeds.
> 
> So I'm not sure I understand the relationship to an app-group model.

Sorry for lacking the inforamtion. I should have written more clear.
In fact, what we need is *per-memcg-swap-device*.

What I want is to avoid kill background application although memory
is overflow because cold launcing of app takes a very long time
compared to resume(ie, just switching). I also want to keep a mount
of free pages in the memory so that new application startup cannot
be stuck by reclaim activities.

To get free memory, I want to reclaim less important app rather than
killing. In this time, we can support two swap devices.

A one is zram, other is slow storage but much bigger than zram size.
Then, we can use storage swap to reclaim pages for not-important app
while we can use zram swap for for important app(e.g., forground app,
system services, daemon and so on).

IOW, we want to support mutiple swap device with one-cgroup-per-app
and the storage speed is totally different.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
