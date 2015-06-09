Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFFC6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 19:36:06 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so24296967pdb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 16:36:06 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ro7si10833167pab.171.2015.06.09.16.36.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 16:36:05 -0700 (PDT)
Received: by padev16 with SMTP id ev16so22395850pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 16:36:05 -0700 (PDT)
Date: Wed, 10 Jun 2015 08:36:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: show proportional swap share of the mapping
Message-ID: <20150609233611.GA12689@bgram>
References: <1433861031-13233-1-git-send-email-minchan@kernel.org>
 <20150609143548.870150b59d78752680c172db@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150609143548.870150b59d78752680c172db@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bongkyu Kim <bongkyu.kim@lge.com>

Hello Andrew,

On Tue, Jun 09, 2015 at 02:35:48PM -0700, Andrew Morton wrote:
> On Tue,  9 Jun 2015 23:43:51 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > For system uses swap heavily and has lots of shared anonymous page,
> > it's very trouble to find swap set size per process because currently
> > smaps doesn't report proportional set size of swap.
> > It ends up that sum of the number of swap for all processes is greater
> > than swap device size.
> > 
> > This patch introduces SwapPss field on /proc/<pid>/smaps.
> > 
> 
> We should be told quite a bit more about the value of this change,
> please.  Use cases, what problems it solves, etc.  Enough to justify
> adding new code to the kernel, enough to justify adding yet another
> userspace interface which must be maintained for ever.

The goal is same with present pages's PSS.

We want to know per-process workingset size for smart memory
management by userland platform memory manager. Our products
use swap(ex, zram) heavily to maximize memory efficiency.
IOW, workingset includes rss + swap.

However, without this feature, it's really hard to figure out
how many each process consumes availabe memory(rss + zram-swap)
if the system has lots of shared anonymous memory(e.g, android).

> 
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> >
> > ...
> >
> > @@ -441,7 +442,7 @@ indicates the amount of memory currently marked as referenced or accessed.
> >  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
> >  and a page is modified, the file page is replaced by a private anonymous copy.
> >  "Swap" shows how much would-be-anonymous memory is also used, but out on
> > -swap.
> > +swap. "SwapPss" shows process' proportional swap share of this mapping.
> >  
> >  "VmFlags" field deserves a separate description. This member represents the kernel
> >  flags associated with the particular virtual memory area in two letter encoded
> 
> Documentation/filesystems/proc.txt doesn't actually explain what
> "proportional share" means.  A patient reader will hopefully find the
> comment over PSS_SHIFT in fs/proc/task_mmu.c, but that isn't very
> user-friendly.

Okay, I will try to add more comment about PSS in proc.txt
on next spin if you are not against this feature.

Thanks.

> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
