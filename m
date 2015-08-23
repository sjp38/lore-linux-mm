Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id AB90B6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 02:04:49 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so45198511wic.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 23:04:49 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id p11si14386428wik.60.2015.08.22.23.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 23:04:47 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so45320411wic.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 23:04:47 -0700 (PDT)
Date: Sun, 23 Aug 2015 08:04:43 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] mm/vmalloc: Cache the /proc/meminfo vmalloc
 statistics
Message-ID: <20150823060443.GA9882@gmail.com>
References: <20150823044839.5727.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150823044839.5727.qmail@ns.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>


* George Spelvin <linux@horizon.com> wrote:

> Linus wrote:
> > I don't think any of this can be called "correct", in that the
> > unlocked accesses to the cached state are clearly racy, but I think
> > it's very much "acceptable".
> 
> I'd think you could easily fix that with a seqlock-like system.
> 
> What makes it so simple is that you can always fall back to
> calc_vmalloc_info if there's any problem, rather than looping or blocking.
> 
> The basic idea is that you have a seqlock counter, but if either of
> the two lsbits are set, the cached information is stale.
> 
> Basically, you need a seqlock and a spinlock.  The seqlock does
> most of the work, and the spinlock ensures that there's only one
> updater of the cache.
> 
> vmap_unlock() does set_bit(0, &seq->sequence).  This marks the information
> as stale.
> 
> get_vmalloc_info reads the seqlock.  There are two case:
> - If the two lsbits are 10, the cached information is valid.
>   Copy it out, re-check the seqlock, and loop if the sequence
>   number changes.
> - In any other case, the cached information is
>   not valid.
>   - Try to obtain the spinlock.  Do not block if it's unavailable.
>     - If unavailable, do not block.
>     - If the lock is acquired:
>       - Set the sequence to (sequence | 3) + 1 (we're the only writer)
>       - This bumps the sequence number and leaves the lsbits at 00 (invalid)
>       - Memory barrier TBD.  Do the RCU ops in calc_vmalloc_info do it for us?
>   - Call calc_vmalloc_info
>   - If we obtained the spinlock earlier:
>     - Copy our vmi to cached_info
>     - smp_wmb()
>     - set_bit(1, &seq->sequence).  This marks the information as valid,
>       as long as bit 0 is still clear.
>     - Release the spinlock.
> 
> Basically, bit 0 says "vmalloc info has changed", and bit 1 says
> "vmalloc cache has been updated".  This clears bit 0 before
> starting the update so that an update during calc_vmalloc_info
> will force a new update.
> 
> So the three case are basically:
> 00 - calc_vmalloc_info() in progress
> 01 - vmap_unlock() during calc_vmalloc_info()
> 10 - cached_info is valid
> 11 - vmap_unlock has invalidated cached_info, awaiting refresh
> 
> Logically, the sequence number should be initialized to ...01,
> but the code above handles 00 okay.

I think this is too complex.

How about something simple like the patch below (on top of the third patch)?

It makes the vmalloc info transactional - /proc/meminfo will always print a 
consistent set of numbers. (Not that we really care about races there, but it 
looks really simple to solve so why not.)

( I also moved the function-static cache next to the flag and seqlock - this
  should further compress the cache footprint. )

Have I missed anything? Very lightly tested: booted in a VM.

Thanks,

	Ingo

=========================>

 mm/vmalloc.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ef48e557df5a..66726f41e726 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -278,7 +278,15 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 
 static __cacheline_aligned_in_smp DEFINE_SPINLOCK(vmap_area_lock);
 
+/*
+ * Seqlock and flag for the vmalloc info cache printed in /proc/meminfo.
+ *
+ * The assumption of the optimization is that it's read frequently, but
+ * modified infrequently.
+ */
+static DEFINE_SEQLOCK(vmap_info_lock);
 static int vmap_info_changed;
+static struct vmalloc_info vmap_info_cache;
 
 static inline void vmap_lock(void)
 {
@@ -2752,10 +2760,14 @@ static void calc_vmalloc_info(struct vmalloc_info *vmi)
 
 void get_vmalloc_info(struct vmalloc_info *vmi)
 {
-	static struct vmalloc_info cached_info;
+	if (!READ_ONCE(vmap_info_changed)) {
+		unsigned int seq;
+
+		do {
+			seq = read_seqbegin(&vmap_info_lock);
+			*vmi = vmap_info_cache;
+		} while (read_seqretry(&vmap_info_lock, seq));
 
-	if (!vmap_info_changed) {
-		*vmi = cached_info;
 		return;
 	}
 
@@ -2764,8 +2776,9 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 
 	calc_vmalloc_info(vmi);
 
-	barrier();
-	cached_info = *vmi;
+	write_seqlock(&vmap_info_lock);
+	vmap_info_cache = *vmi;
+	write_sequnlock(&vmap_info_lock);
 }
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
