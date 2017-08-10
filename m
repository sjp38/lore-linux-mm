Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26DD16B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:58:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k71so534917wrc.15
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:58:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si4648169wmi.139.2017.08.10.03.58.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 03:58:54 -0700 (PDT)
Date: Thu, 10 Aug 2017 12:58:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Message-ID: <20170810105852.GM23863@dhcp22.suse.cz>
References: <20170808132554.141143-1-dancol@google.com>
 <20170810001557.147285-1-dancol@google.com>
 <20170810043831.GB2249@bbox>
 <20170810084617.GI23863@dhcp22.suse.cz>
 <r0251soju3fo.fsf@dancol.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <r0251soju3fo.fsf@dancol.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, timmurray@google.com, joelaf@google.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, sonnyrao@chromium.org, robert.foss@collabora.com, linux-api@vger.kernel.org

On Thu 10-08-17 03:23:23, Daniel Colascione wrote:
> Thanks for taking a look at the patch!
> 
> On Thu, Aug 10 2017, Michal Hocko wrote:
> > [CC linux-api - the patch was posted here
> > http://lkml.kernel.org/r/20170810001557.147285-1-dancol@google.com]
> >
> > On Thu 10-08-17 13:38:31, Minchan Kim wrote:
> >> On Wed, Aug 09, 2017 at 05:15:57PM -0700, Daniel Colascione wrote:
> >> > /proc/pid/smaps_rollup is a new proc file that improves the
> >> > performance of user programs that determine aggregate memory
> >> > statistics (e.g., total PSS) of a process.
> >> > 
> >> > Android regularly "samples" the memory usage of various processes in
> >> > order to balance its memory pool sizes. This sampling process involves
> >> > opening /proc/pid/smaps and summing certain fields. For very large
> >> > processes, sampling memory use this way can take several hundred
> >> > milliseconds, due mostly to the overhead of the seq_printf calls in
> >> > task_mmu.c.
> >
> > Have you tried to reduce that overhead? E.g. by replacing seq_printf by
> > something more simple
> > http://lkml.kernel.org/r/20160817130320.GC20703@dhcp22.suse.cz?
> 
> I haven't tried that yet, but if I'm reading that thread correctly, it
> looks like using more efficient printing primitives gives us a 7%
> speedup. The smaps_rollup patch gives us a much bigger speedup while
> reusing almost all the smaps code, so it seems easier and simpler than a
> bunch of incremental improvements to smaps. And even an efficient smaps
> would have to push 2MB through seq_file for the 3000-VMA process case.

The thing is that more users would benefit from a more efficient
/proc/pid/smaps call. Maybe we can use some caching tricks etc...  We
should make sure that existing options should be attempted before a new
user visible interface is added. It is kind of sad that the real work
(pte walk) is less expensive than formating the output and copying it to
the userspace...

> > How often you you need to read this information?
> 
> It varies depending on how often processes change state.  We sample a
> short time (tens of seconds) after processes change state (e.g., enters
> foreground) and every few minutes thereafter. We're particularly
> concerned from an energy perspective about needlessly burning CPU on
> background samples.

Please make sure this is documented in the patch along with some numbers
ideally.

[...]

> >> FYI, there was trial but got failed at that time so in this time,
> >> https://marc.info/?l=linux-kernel&m=147310650003277&w=2
> >> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1229163.html
> >
> > Yes I really disliked the previous attempt and this one is not all that
> > better. The primary unanswered question back then was a relevant
> > usecase. Back then it was argued [1] that PSS was useful for userspace
> > OOM handling but arguments were rather dubious. Follow up questions [2]
> > shown that the useage of PSS was very workload specific. Minchan has
> > noted some usecase as well but not very specific either.
> 
> Anyway, I see what you mean about PSS being iffy for user-space OOM
> processing (because PSS doesn't tell you how much memory you get back in
> exchange for killing a given process at a particular moment). We're not
> using it like that.
> 
> Instead, we're using the PSS samples we collect asynchronously for
> system-management tasks like fine-tuning oom_adj_score, memory use
> tracking for debugging, application-level memory-use attribution, and
> deciding whether we want to kill large processes during system idle
> maintenance windows. Android has been using PSS for these purposes for a
> long time; as the average process VMA count has increased and and
> devices become more efficiency-conscious, PSS-collection inefficiency
> has started to matter more. IMHO, it'd be a lot safer to optimize the
> existing PSS-collection model, which has been fine-tuned over the years,
> instead of changing the memory tracking approach entirely to work around
> smaps-generation inefficiency.

This is really vague. Please be more specific.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
