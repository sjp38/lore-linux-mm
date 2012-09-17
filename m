Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 56A516B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 09:50:17 -0400 (EDT)
Message-ID: <50572A90.1030109@redhat.com>
Date: Mon, 17 Sep 2012 09:50:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
References: <5034F8F4.3080301@redhat.com> <20120825174550.GA8619@alpha.arachsys.com> <50391564.30401@redhat.com> <20120826105803.GA377@alpha.arachsys.com> <20120906092039.GA19234@alpha.arachsys.com> <20120912105659.GA23818@alpha.arachsys.com> <20120912122541.GO11266@suse.de> <20120912164615.GA14173@alpha.arachsys.com> <20120913154824.44cc0e28@cuia.bos.redhat.com> <20120913155450.7634148f@cuia.bos.redhat.com> <20120915155524.GA24182@alpha.arachsys.com>
In-Reply-To: <20120915155524.GA24182@alpha.arachsys.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Mel Gorman <mgorman@suse.de>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

On 09/15/2012 11:55 AM, Richard Davies wrote:
> Hi Rik, Mel and Shaohua,
>
> Thank you for your latest patches. I attach my latest perf report for a slow
> boot with all of these applied.
>
> Mel asked for timings of the slow boots. It's very hard to give anything
> useful here! A normal boot would be a minute or so, and many are like that,
> but the slowest that I have seen (on 3.5.x) was several hours. Basically, I
> just test many times until I get one which is noticeably slow than normal
> and then run perf record on that one.
>
> The latest perf report for a slow boot is below. For the fast boots, most of
> the time is in clean_page_c in do_huge_pmd_anonymous_page, but for this slow
> one there is a lot of lock contention above that.

How often do you run into slow boots, vs. fast ones?

> # Overhead          Command         Shared Object                                          Symbol
> # ........  ...............  ....................  ..............................................
> #
>      58.49%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave
>                     |
>                     --- _raw_spin_lock_irqsave
>                        |
>                        |--95.07%-- compact_checklock_irqsave
>                        |          |
>                        |          |--70.03%-- isolate_migratepages_range
>                        |          |          compact_zone
>                        |          |          compact_zone_order
>                        |          |          try_to_compact_pages
>                        |          |          __alloc_pages_direct_compact
>                        |          |          __alloc_pages_nodemask

Looks like it moved from isolate_freepages_block in your last
trace, to isolate_migratepages_range?

Mel, I wonder if we have any quadratic complexity problems
in this part of the code, too?

The isolate_freepages_block CPU use can be fixed by simply
restarting where the last invocation left off, instead of
always starting at the end of the zone.  Could we need
something similar for isolate_migratepages_range?

After all, Richard has a 128GB system, and runs 108GB worth
of KVM guests on it...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
