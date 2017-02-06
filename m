Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF706B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 17:05:33 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so21876613wmt.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 14:05:33 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id t202si9652447wmd.108.2017.02.06.14.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 14:05:31 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 779F01C2213
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 22:05:31 +0000 (GMT)
Date: Mon, 6 Feb 2017 22:05:30 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Feb 06, 2017 at 08:13:35PM +0100, Dmitry Vyukov wrote:
> On Mon, Jan 30, 2017 at 4:48 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > On Sun, Jan 29, 2017 at 6:22 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> >> On 29.1.2017 13:44, Dmitry Vyukov wrote:
> >>> Hello,
> >>>
> >>> I've got the following deadlock report while running syzkaller fuzzer
> >>> on f37208bc3c9c2f811460ef264909dfbc7f605a60:
> >>>
> >>> [ INFO: possible circular locking dependency detected ]
> >>> 4.10.0-rc5-next-20170125 #1 Not tainted
> >>> -------------------------------------------------------
> >>> syz-executor3/14255 is trying to acquire lock:
> >>>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff814271c7>]
> >>> get_online_cpus+0x37/0x90 kernel/cpu.c:239
> >>>
> >>> but task is already holding lock:
> >>>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
> >>> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
> >>>
> >>> which lock already depends on the new lock.
> >>
> >> I suspect the dependency comes from recent changes in drain_all_pages(). They
> >> were later redone (for other reasons, but nice to have another validation) in
> >> the mmots patch [1], which AFAICS is not yet in mmotm and thus linux-next. Could
> >> you try if it helps?
> >
> > It happened only once on linux-next, so I can't verify the fix. But I
> > will watch out for other occurrences.
> 
> Unfortunately it does not seem to help.

I'm a little stuck on how to best handle this. get_online_cpus() can
halt forever if the hotplug operation is holding the mutex when calling
pcpu_alloc. One option would be to add a try_get_online_cpus() helper which
trylocks the mutex. However, given that drain is so unlikely to actually
make that make a difference when racing against parallel allocations,
I think this should be acceptable.

Any objections?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b93879990fd..a3192447e906 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3432,7 +3432,17 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (!page && !drained) {
 		unreserve_highatomic_pageblock(ac, false);
-		drain_all_pages(NULL);
+
+		/*
+		 * Only drain from contexts allocating for user allocations.
+		 * Kernel allocations could be holding a CPU hotplug-related
+		 * mutex, particularly hot-add allocating per-cpu structures
+		 * while hotplug-related mutex's are held which would prevent
+		 * get_online_cpus ever returning.
+		 */
+		if (gfp_mask & __GFP_HARDWALL)
+			drain_all_pages(NULL);
+
 		drained = true;
 		goto retry;
 	}

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
