Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4789A6B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 18:11:49 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1815185pbc.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 15:11:48 -0800 (PST)
Date: Tue, 13 Nov 2012 15:11:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I
 think)
In-Reply-To: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Marc Duponcheel <marc@offline.be>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Nov 2012, Andy Lutomirski wrote:

> I've seen an odd problem three times in the past two weeks.  I suspect
> a Linux 3.6 regression.  I"m on 3.6.3-1.fc17.x86_64.  I run a parallel
> compilation, and no progress is made.  All cpus are pegged at 100%
> system time by the respective cc1plus processes.  Reading
> /proc/<pid>/stack shows either
> 
> [<ffffffff8108e01a>] __cond_resched+0x2a/0x40
> [<ffffffff8114e432>] isolate_migratepages_range+0xb2/0x620
> [<ffffffff8114eba4>] compact_zone+0x144/0x410
> [<ffffffff8114f152>] compact_zone_order+0x82/0xc0
> [<ffffffff8114f271>] try_to_compact_pages+0xe1/0x130
> [<ffffffff816143db>] __alloc_pages_direct_compact+0xaa/0x190
> [<ffffffff81133d26>] __alloc_pages_nodemask+0x526/0x990
> [<ffffffff81171496>] alloc_pages_vma+0xb6/0x190
> [<ffffffff81182683>] do_huge_pmd_anonymous_page+0x143/0x340
> [<ffffffff811549fd>] handle_mm_fault+0x27d/0x320
> [<ffffffff81620adc>] do_page_fault+0x15c/0x4b0
> [<ffffffff8161d625>] page_fault+0x25/0x30
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> or
> 
> [<ffffffffffffffff>] 0xffffffffffffffff
> 

This reminds me of the thread at http://marc.info/?t=135102111800004 which 
caused Marc's system to reportedly go unresponsive like your report but in 
his case it also caused a reboot.  If your system is still running (or, 
even better, if you're able to capture this happening in realtime), could 
you try to capture

	grep -E "compact_|thp_" /proc/vmstat

as well while it is in progress?  (Even if it's not happening right now, 
the data might still be useful if you have knowledge that it has occurred 
since the last reboot.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
