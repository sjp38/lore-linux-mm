Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 14F326B00C5
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 08:25:47 -0400 (EDT)
Date: Wed, 12 Sep 2012 13:25:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Windows VM slow boot
Message-ID: <20120912122541.GO11266@suse.de>
References: <5034A18B.5040408@redhat.com>
 <20120822124032.GA12647@alpha.arachsys.com>
 <5034D437.8070106@redhat.com>
 <20120822144150.GA1400@alpha.arachsys.com>
 <5034F8F4.3080301@redhat.com>
 <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120912105659.GA23818@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 12, 2012 at 11:56:59AM +0100, Richard Davies wrote:
> [ adding linux-mm - previously at http://marc.info/?t=134511509400003 ]
> 
> Hi Rik,
> 

I'm not Rik but hi anyway.

> Since qemu-kvm 1.2.0 and Linux 3.6.0-rc5 came out, I thought that I would
> retest with these.
> 

Ok. 3.6.0-rc5 contains [c67fe375: mm: compaction: Abort async compaction
if locks are contended or taking too long] that should have helped mitigate
some of the lock contention problem but not all of it as we'll see later.

> The typical symptom now appears to be that the Windows VMs boot reasonably
> fast,

I see that this is an old-ish bug but I did not read the full history.
Is it now booting faster than 3.5.0 was? I'm asking because I'm
interested to see if commit c67fe375 helped your particular case.

> but then there is high CPU use and load for many minutes afterwards -
> the high CPU use is both for the qemu-kvm processes themselves and also for
> % sys.
> 

Ok, I cannot comment on the userspace portion of things but the kernel
portion still indicates that there is a high percentage of time on what
appears to be lock contention.

> I attach a perf report which seems to show that the high CPU use is in the
> memory manager.
> 

A follow-on from commit c67fe375 was the following patch (author cc'd)
which addresses lock contention in isolate_migratepages_range where your
perf report indicates that we're spending 95% of the time. Would you be
willing to test it please?

---8<---
From: Shaohua Li <shli@kernel.org>
Subject: mm: compaction: check lock contention first before taking lock

isolate_migratepages_range will take zone->lru_lock first and check if the
lock is contented, if yes, it will release the lock.  This isn't
efficient.  If the lock is truly contented, a lock/unlock pair will
increase the lock contention.  We'd better check if the lock is contended
first.  compact_trylock_irqsave perfectly meets the requirement.

Signed-off-by: Shaohua Li <shli@fusionio.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/compaction.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN mm/compaction.c~mm-compaction-check-lock-contention-first-before-taking-lock mm/compaction.c
--- a/mm/compaction.c~mm-compaction-check-lock-contention-first-before-taking-lock
+++ a/mm/compaction.c
@@ -349,8 +349,9 @@ isolate_migratepages_range(struct zone *
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	locked = true;
+	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
+	if (!locked)
+		return 0;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
