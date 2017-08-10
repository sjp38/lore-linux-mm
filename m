Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF2EE6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:23:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so2822922pge.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:23:27 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id d5si3677069pgk.320.2017.08.10.03.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 03:23:26 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id t86so1352305pfe.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:23:26 -0700 (PDT)
From: Daniel Colascione <dancol@google.com>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
References: <20170808132554.141143-1-dancol@google.com>
	<20170810001557.147285-1-dancol@google.com>
	<20170810043831.GB2249@bbox> <20170810084617.GI23863@dhcp22.suse.cz>
Date: Thu, 10 Aug 2017 03:23:23 -0700
In-Reply-To: <20170810084617.GI23863@dhcp22.suse.cz> (Michal Hocko's message
	of "Thu, 10 Aug 2017 10:46:17 +0200")
Message-ID: <r0251soju3fo.fsf@dancol.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, timmurray@google.com, joelaf@google.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, sonnyrao@chromium.org, robert.foss@collabora.com, linux-api@vger.kernel.org

Thanks for taking a look at the patch!

On Thu, Aug 10 2017, Michal Hocko wrote:
> [CC linux-api - the patch was posted here
> http://lkml.kernel.org/r/20170810001557.147285-1-dancol@google.com]
>
> On Thu 10-08-17 13:38:31, Minchan Kim wrote:
>> On Wed, Aug 09, 2017 at 05:15:57PM -0700, Daniel Colascione wrote:
>> > /proc/pid/smaps_rollup is a new proc file that improves the
>> > performance of user programs that determine aggregate memory
>> > statistics (e.g., total PSS) of a process.
>> > 
>> > Android regularly "samples" the memory usage of various processes in
>> > order to balance its memory pool sizes. This sampling process involves
>> > opening /proc/pid/smaps and summing certain fields. For very large
>> > processes, sampling memory use this way can take several hundred
>> > milliseconds, due mostly to the overhead of the seq_printf calls in
>> > task_mmu.c.
>
> Have you tried to reduce that overhead? E.g. by replacing seq_printf by
> something more simple
> http://lkml.kernel.org/r/20160817130320.GC20703@dhcp22.suse.cz?

I haven't tried that yet, but if I'm reading that thread correctly, it
looks like using more efficient printing primitives gives us a 7%
speedup. The smaps_rollup patch gives us a much bigger speedup while
reusing almost all the smaps code, so it seems easier and simpler than a
bunch of incremental improvements to smaps. And even an efficient smaps
would have to push 2MB through seq_file for the 3000-VMA process case.

> How often you you need to read this information?

It varies depending on how often processes change state.  We sample a
short time (tens of seconds) after processes change state (e.g., enters
foreground) and every few minutes thereafter. We're particularly
concerned from an energy perspective about needlessly burning CPU on
background samples.

>> > smaps_rollup improves the situation. It contains most of the fields of
>> > /proc/pid/smaps, but instead of a set of fields for each VMA,
>> > smaps_rollup instead contains one synthetic smaps-format entry
>> > representing the whole process. In the single smaps_rollup synthetic
>> > entry, each field is the summation of the corresponding field in all
>> > of the real-smaps VMAs. Using a common format for smaps_rollup and
>> > smaps allows userspace parsers to repurpose parsers meant for use with
>> > non-rollup smaps for smaps_rollup, and it allows userspace to switch
>> > between smaps_rollup and smaps at runtime (say, based on the
>> > availability of smaps_rollup in a given kernel) with minimal fuss.
>> > 
>> > By using smaps_rollup instead of smaps, a caller can avoid the
>> > significant overhead of formatting, reading, and parsing each of a
>> > large process's potentially very numerous memory mappings. For
>> > sampling system_server's PSS in Android, we measured a 12x speedup,
>> > representing a savings of several hundred milliseconds.
>
> By a large process you mean a process with many VMAs right? How many
> vmas are we talking about?

Yes: ~3000 VMAs is one I'd consider large in this context.

>> > One alternative to a new per-process proc file would have been
>> > including PSS information in /proc/pid/status. We considered this
>> > option but thought that PSS would be too expensive (by a few orders of
>> > magnitude) to collect relative to what's already emitted as part of
>> > /proc/pid/status, and slowing every user of /proc/pid/status for the
>> > sake of readers that happen to want PSS feels wrong.
>> > 
>> > The code itself works by reusing the existing VMA-walking framework we
>> > use for regular smaps generation and keeping the mem_size_stats
>> > structure around between VMA walks instead of using a fresh one for
>> > each VMA.  In this way, summation happens automatically.  We let
>> > seq_file walk over the VMAs just as it does for regular smaps and just
>> > emit nothing to the seq_file until we hit the last VMA.
>> > 
>> > Patch changelog:
>> > 
>> > v2: Fix typo in commit message
>> >     Add ABI documentation as requested by gregkh
>> > 
>> > Signed-off-by: Daniel Colascione <dancol@google.com>
>> 
>> I love this.
>> 
>> FYI, there was trial but got failed at that time so in this time,
>> https://marc.info/?l=linux-kernel&m=147310650003277&w=2
>> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1229163.html
>
> Yes I really disliked the previous attempt and this one is not all that
> better. The primary unanswered question back then was a relevant
> usecase. Back then it was argued [1] that PSS was useful for userspace
> OOM handling but arguments were rather dubious. Follow up questions [2]
> shown that the useage of PSS was very workload specific. Minchan has
> noted some usecase as well but not very specific either.

Anyway, I see what you mean about PSS being iffy for user-space OOM
processing (because PSS doesn't tell you how much memory you get back in
exchange for killing a given process at a particular moment). We're not
using it like that.

Instead, we're using the PSS samples we collect asynchronously for
system-management tasks like fine-tuning oom_adj_score, memory use
tracking for debugging, application-level memory-use attribution, and
deciding whether we want to kill large processes during system idle
maintenance windows. Android has been using PSS for these purposes for a
long time; as the average process VMA count has increased and and
devices become more efficiency-conscious, PSS-collection inefficiency
has started to matter more. IMHO, it'd be a lot safer to optimize the
existing PSS-collection model, which has been fine-tuned over the years,
instead of changing the memory tracking approach entirely to work around
smaps-generation inefficiency.

The existence of an independent attempt to add this functionality
suggests that it might be generally useful too.

> So let's start with a clear use case description. Then let's make it
> clear that even optimizing the current implementation is not sufficient
> to meat goals and only then try to add one more user visible API which
> we will have to maintain for ever.

Adding a new API shouldn't be anyone's first choice, but the efficiency
wins are hard to ignore. We can cut ~2MB of smaps data to a few KB this
way. I'm definitely open to other ideas for getting similar wins, but
right now, I'd like to explore approaches that let us keep using the
existing PSS metric.

Thanks again!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
