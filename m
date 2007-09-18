Date: Tue, 18 Sep 2007 13:47:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 6/4] oom: pass null to kfree if zonelist is not cleared
In-Reply-To: <Pine.LNX.4.64.0709181314160.3953@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709181340060.27785@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709181306140.22984@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181314160.3953@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Christoph Lameter wrote:

> > I thought about doing that as well as statically allocating
> > 
> > 	#define MAX_OOM_THREADS		4
> > 	static struct zonelist *zonelists[MAX_OOM_THREADS];
> > 
> > and using semaphores.  But in my testing of this patchset and experience 
> > in working with the watermarks used in __alloc_pages(), we should never 
> > actually encounter a condition where we can't find
> > sizeof(struct oom_zonelist) of memory.  That's on the order of how many 
> > invocations of the OOM killer you have, but I don't actually think you'll 
> > have many that have a completely exclusive set of zones in the zonelist.  
> > Watermarks usually do the trick (and is the only reason TIF_MEMDIE works, 
> > by the way).
> 
> You are playing with fire here. The slab queues *may* have enough memory 
> to satisfy that requests but if not then we may recursively call into the 
> page allocator to get a page/pages. Sounds dangerous to me.
>  

Wrong.  Notice what the newly-named try_set_zone_oom() function returns if 
the kzalloc() fails; this was a specific design decision.  It returns 1, 
so the conditional in __alloc_pages() fails and the OOM killer progresses 
as normal.

Thanks for reminding me about that, though, because the following will be 
needed if that indeed happens.



oom: pass null to kfree if zonelist is not cleared

If a zonelist pointer cannot be found in the linked list, kfree() must be
called with NULL instead.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -438,7 +438,7 @@ out:
  */
 void clear_zonelist_oom(const struct zonelist *zonelist)
 {
-	struct oom_zonelist *oom_zl;
+	struct oom_zonelist *oom_zl = NULL;
 
 	mutex_lock(&oom_zonelist_mutex);
 	list_for_each_entry(oom_zl, &zonelists, list)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
