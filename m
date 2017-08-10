Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 826CC6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:38:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so82952639pfj.11
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 21:38:36 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v198si3419632pgb.311.2017.08.09.21.38.34
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 21:38:35 -0700 (PDT)
Date: Thu, 10 Aug 2017 13:38:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Message-ID: <20170810043831.GB2249@bbox>
References: <20170808132554.141143-1-dancol@google.com>
 <20170810001557.147285-1-dancol@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810001557.147285-1-dancol@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, timmurray@google.com, joelaf@google.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, sonnyrao@chromium.org, robert.foss@collabora.com

On Wed, Aug 09, 2017 at 05:15:57PM -0700, Daniel Colascione wrote:
> /proc/pid/smaps_rollup is a new proc file that improves the
> performance of user programs that determine aggregate memory
> statistics (e.g., total PSS) of a process.
> 
> Android regularly "samples" the memory usage of various processes in
> order to balance its memory pool sizes. This sampling process involves
> opening /proc/pid/smaps and summing certain fields. For very large
> processes, sampling memory use this way can take several hundred
> milliseconds, due mostly to the overhead of the seq_printf calls in
> task_mmu.c.
> 
> smaps_rollup improves the situation. It contains most of the fields of
> /proc/pid/smaps, but instead of a set of fields for each VMA,
> smaps_rollup instead contains one synthetic smaps-format entry
> representing the whole process. In the single smaps_rollup synthetic
> entry, each field is the summation of the corresponding field in all
> of the real-smaps VMAs. Using a common format for smaps_rollup and
> smaps allows userspace parsers to repurpose parsers meant for use with
> non-rollup smaps for smaps_rollup, and it allows userspace to switch
> between smaps_rollup and smaps at runtime (say, based on the
> availability of smaps_rollup in a given kernel) with minimal fuss.
> 
> By using smaps_rollup instead of smaps, a caller can avoid the
> significant overhead of formatting, reading, and parsing each of a
> large process's potentially very numerous memory mappings. For
> sampling system_server's PSS in Android, we measured a 12x speedup,
> representing a savings of several hundred milliseconds.
> 
> One alternative to a new per-process proc file would have been
> including PSS information in /proc/pid/status. We considered this
> option but thought that PSS would be too expensive (by a few orders of
> magnitude) to collect relative to what's already emitted as part of
> /proc/pid/status, and slowing every user of /proc/pid/status for the
> sake of readers that happen to want PSS feels wrong.
> 
> The code itself works by reusing the existing VMA-walking framework we
> use for regular smaps generation and keeping the mem_size_stats
> structure around between VMA walks instead of using a fresh one for
> each VMA.  In this way, summation happens automatically.  We let
> seq_file walk over the VMAs just as it does for regular smaps and just
> emit nothing to the seq_file until we hit the last VMA.
> 
> Patch changelog:
> 
> v2: Fix typo in commit message
>     Add ABI documentation as requested by gregkh
> 
> Signed-off-by: Daniel Colascione <dancol@google.com>

I love this.

FYI, there was trial but got failed at that time so in this time,
https://marc.info/?l=linux-kernel&m=147310650003277&w=2
http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1229163.html

I really hope we merge this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
