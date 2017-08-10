Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C15B6B02C3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:46:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so145601wrz.10
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:46:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u138si4430070wmu.1.2017.08.10.01.46.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 01:46:19 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:46:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Message-ID: <20170810084617.GI23863@dhcp22.suse.cz>
References: <20170808132554.141143-1-dancol@google.com>
 <20170810001557.147285-1-dancol@google.com>
 <20170810043831.GB2249@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810043831.GB2249@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, timmurray@google.com, joelaf@google.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, sonnyrao@chromium.org, robert.foss@collabora.com, linux-api@vger.kernel.org

[CC linux-api - the patch was posted here
http://lkml.kernel.org/r/20170810001557.147285-1-dancol@google.com]

On Thu 10-08-17 13:38:31, Minchan Kim wrote:
> On Wed, Aug 09, 2017 at 05:15:57PM -0700, Daniel Colascione wrote:
> > /proc/pid/smaps_rollup is a new proc file that improves the
> > performance of user programs that determine aggregate memory
> > statistics (e.g., total PSS) of a process.
> > 
> > Android regularly "samples" the memory usage of various processes in
> > order to balance its memory pool sizes. This sampling process involves
> > opening /proc/pid/smaps and summing certain fields. For very large
> > processes, sampling memory use this way can take several hundred
> > milliseconds, due mostly to the overhead of the seq_printf calls in
> > task_mmu.c.

Have you tried to reduce that overhead? E.g. by replacing seq_printf by
something more simple
http://lkml.kernel.org/r/20160817130320.GC20703@dhcp22.suse.cz?
How often you you need to read this information?

> > smaps_rollup improves the situation. It contains most of the fields of
> > /proc/pid/smaps, but instead of a set of fields for each VMA,
> > smaps_rollup instead contains one synthetic smaps-format entry
> > representing the whole process. In the single smaps_rollup synthetic
> > entry, each field is the summation of the corresponding field in all
> > of the real-smaps VMAs. Using a common format for smaps_rollup and
> > smaps allows userspace parsers to repurpose parsers meant for use with
> > non-rollup smaps for smaps_rollup, and it allows userspace to switch
> > between smaps_rollup and smaps at runtime (say, based on the
> > availability of smaps_rollup in a given kernel) with minimal fuss.
> > 
> > By using smaps_rollup instead of smaps, a caller can avoid the
> > significant overhead of formatting, reading, and parsing each of a
> > large process's potentially very numerous memory mappings. For
> > sampling system_server's PSS in Android, we measured a 12x speedup,
> > representing a savings of several hundred milliseconds.

By a large process you mean a process with many VMAs right? How many
vmas are we talking about?

> > One alternative to a new per-process proc file would have been
> > including PSS information in /proc/pid/status. We considered this
> > option but thought that PSS would be too expensive (by a few orders of
> > magnitude) to collect relative to what's already emitted as part of
> > /proc/pid/status, and slowing every user of /proc/pid/status for the
> > sake of readers that happen to want PSS feels wrong.
> > 
> > The code itself works by reusing the existing VMA-walking framework we
> > use for regular smaps generation and keeping the mem_size_stats
> > structure around between VMA walks instead of using a fresh one for
> > each VMA.  In this way, summation happens automatically.  We let
> > seq_file walk over the VMAs just as it does for regular smaps and just
> > emit nothing to the seq_file until we hit the last VMA.
> > 
> > Patch changelog:
> > 
> > v2: Fix typo in commit message
> >     Add ABI documentation as requested by gregkh
> > 
> > Signed-off-by: Daniel Colascione <dancol@google.com>
> 
> I love this.
> 
> FYI, there was trial but got failed at that time so in this time,
> https://marc.info/?l=linux-kernel&m=147310650003277&w=2
> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1229163.html

Yes I really disliked the previous attempt and this one is not all that
better. The primary unanswered question back then was a relevant
usecase. Back then it was argued [1] that PSS was useful for userspace
OOM handling but arguments were rather dubious. Follow up questions [2]
shown that the useage of PSS was very workload specific. Minchan has
noted some usecase as well but not very specific either.

So let's start with a clear use case description. Then let's make it
clear that even optimizing the current implementation is not sufficient
to meat goals and only then try to add one more user visible API which
we will have to maintain for ever.

[1] http://lkml.kernel.org/r/CAPz6YkW3Ph4mi++qY4cJiQ1PwhnxLr5=E4oCHjf5nYJHMhRcew@mail.gmail.com
[2] http://lkml.kernel.org/r/20160819075910.GB32619@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
