Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id A7BA26B0080
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 12:38:43 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id x13so1818762ief.10
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 09:38:43 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id nh2si20225836icc.52.2013.12.06.09.38.42
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 09:38:42 -0800 (PST)
Date: Fri, 6 Dec 2013 11:38:43 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
Message-ID: <20131206173843.GD3080@sgi.com>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-15-git-send-email-mgorman@suse.de>
 <529E641A.7040804@redhat.com>
 <20131203234637.GS11295@suse.de>
 <529F3D51.1090203@redhat.com>
 <20131204160741.GC11295@suse.de>
 <20131205104015.716ed0fe@annuminas.surriel.com>
 <20131205195446.GI11295@suse.de>
 <52A0DC7F.7050403@redhat.com>
 <20131206092400.GJ11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131206092400.GJ11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, t@sgi.com
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com

On Fri, Dec 06, 2013 at 09:24:00AM +0000, Mel Gorman wrote:
> Good. So far I have not been seeing any problems with it at least.

I went through and tested all the different iterations of this patchset
last night, and have hit a few problems, but I *think* this has solved
the segfault problem.  I'm now hitting some rcu_sched stalls when
running my tests.

Initially things were getting hung up on a lock in change_huge_pmd, so
I applied Kirill's patches to split up the PTL, which did manage to ease
the contention on that lock, but, now it appears that I'm hitting stalls
somewhere else.

I'll play around with this a bit tonight/tomorrow and see if I can track
down exactly where things are getting stuck.  Unfortunately, on these
large systems, when we hit a stall, the system often completely locks up
before the NMI backtrace can complete on all cpus, so, as of right now,
I've not been able to get a backtrace for the cpu that's initially
causing the stall.  I'm going to see if I can slim down the code for the
stall detection to just give the backtrace for the cpu that's initially
stalling out.  In the meantime, let me know if you guys have any ideas
that could keep things moving.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
