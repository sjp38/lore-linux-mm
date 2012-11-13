Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 464636B005A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 17:13:35 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so252708eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 14:13:33 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 13 Nov 2012 14:13:13 -0800
Message-ID: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
Subject: [3.6 regression?] THP + migration/compaction livelock (I think)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

I've seen an odd problem three times in the past two weeks.  I suspect
a Linux 3.6 regression.  I"m on 3.6.3-1.fc17.x86_64.  I run a parallel
compilation, and no progress is made.  All cpus are pegged at 100%
system time by the respective cc1plus processes.  Reading
/proc/<pid>/stack shows either

[<ffffffff8108e01a>] __cond_resched+0x2a/0x40
[<ffffffff8114e432>] isolate_migratepages_range+0xb2/0x620
[<ffffffff8114eba4>] compact_zone+0x144/0x410
[<ffffffff8114f152>] compact_zone_order+0x82/0xc0
[<ffffffff8114f271>] try_to_compact_pages+0xe1/0x130
[<ffffffff816143db>] __alloc_pages_direct_compact+0xaa/0x190
[<ffffffff81133d26>] __alloc_pages_nodemask+0x526/0x990
[<ffffffff81171496>] alloc_pages_vma+0xb6/0x190
[<ffffffff81182683>] do_huge_pmd_anonymous_page+0x143/0x340
[<ffffffff811549fd>] handle_mm_fault+0x27d/0x320
[<ffffffff81620adc>] do_page_fault+0x15c/0x4b0
[<ffffffff8161d625>] page_fault+0x25/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

or

[<ffffffffffffffff>] 0xffffffffffffffff

seemingly at random (i.e. if I read that file twice in a row, I might
see different results).  If I had to guess, I'd say that

perf shows no 'faults'.  The livelock resolved after several minutes
(and before I got far enough with perf to get more useful results).
Every time this happens, firefox hangs but everything else keeps
working.

If I trigger it again, I'll try to grab /proc/zoneinfo and /proc/meminfo.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
