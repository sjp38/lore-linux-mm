Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id D75B06B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:54:04 -0400 (EDT)
Received: by ykfw73 with SMTP id w73so133276244ykf.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:54:04 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id j189si10131863ykj.32.2015.08.24.05.54.03
        for <linux-mm@kvack.org>;
        Mon, 24 Aug 2015 05:54:03 -0700 (PDT)
Date: 24 Aug 2015 08:54:02 -0400
Message-ID: <20150824125402.28806.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 3/3 v5] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <20150824075018.GB20106@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mingo@kernel.org
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

(I hope I'm not annoying you by bikeshedding this too much, although I
think this is improving.)

You've sort of re-invented spinlocks, but after thinking a bit,
it all works.

Rather than using a single word, which is incremented to an odd number
at the start of an update and an even number at the end, there are
two.  An update is in progress when they're unequal.

vmap_info_gen is incremented early, when the cache needs updating, and
read late (after the cache is copied).

vmap_info_cache_gen is incremented after the cache is updated, and read
early (before the cache is copied).


This is logically equivalent to my complicated scheme with atomic updates
to various bits in a single generation word, but greatly simplified by
having two separate words.  In particular, there's no longer a need to
distinguish "vmap has updated list" from "calc_vmalloc_info in progress".

I particularly like the "gen - vmap_info_cache_gen > 0" test.
You *must* test for inequality to prevent tearing of a valid cache
(...grr...English heteronyms...), and given that, might as well
require it be fresher.


Anyway, suggested changes for v6 (sigh...):

First: you do a second read of vmap_info_gen to optimize out the copy
of vmalloc_info if it's easily seen as pointless, but given how small
vmalloc_info is (two words!), i'd be inclined to omit that optimization.

Copy always, *then* see if it's worth keeping.  Smaller code, faster
fast path, and is barely noticeable on the slow path.


Second, and this is up to you, I'd be inclined to go fully non-blocking and
only spin_trylock().  If that fails, just skip the cache update.


Third, ANSI C rules allow a compiler to assume that signed integer
overflow does not occur.  That means that gcc is allowed to optimize
"if (x - y > 0)" to "if (x > y)".

Given that gcc has annoyed us by using this optimization in other
contexts, It might be safer to make them unsigned (which is required to
wrap properly) and cast to integer after subtraction.


Basically, the following (untested, but pretty damn simple):

+/*
+ * Return a consistent snapshot of the current vmalloc allocation
+ * statistics, for /proc/meminfo:
+ */
+void get_vmalloc_info(struct vmalloc_info *vmi)
+{
+	unsigned gen, cache_gen = READ_ONCE(vmap_info_cache_gen);
+
+	/*
+	 * The two read barriers make sure that we read
+	 * 'cache_gen', 'vmap_info_cache' and 'gen' in
+	 * precisely that order:
+	 */
+	smp_rmb();
+	*vmi = vmap_info_cache;
+
+	smp_rmb();
+	gen = READ_ONCE(vmap_info_gen);
+
+	/*
+	 * If the generation counter of the cache matches that of
+	 * the vmalloc generation counter then return the cache:
+	 */
+	if (gen == cache_gen)
+		return;
+
+	/* Make sure 'gen' is read before the vmalloc info */
+	smp_rmb();
+	calc_vmalloc_info(vmi);
+
+	/*
+	 * All updates to vmap_info_cache_gen go through this spinlock,
+	 * so when the cache got invalidated, we'll only mark it valid
+	 * again if we first fully write the new vmap_info_cache.
+	 *
+	 * This ensures that partial results won't be used.
+	 */
+	if (spin_trylock(&vmap_info_lock)) {
+		if ((int)(gen - vmap_info_cache_gen) > 0) {
+			vmap_info_cache = *vmi;
+			/*
+			 * Make sure the new cached data is visible before
+			 * the generation counter update:
+			 */
+			smp_wmb();
+			WRITE_ONCE(vmap_info_cache_gen, gen);
+		}
+		spin_unlock(&vmap_info_lock);
+	}
+}
+
+#endif /* CONFIG_PROC_FS */

The only remaining *very small* nit is that this function is a mix of
"return early" and "wrap it in an if()" style.  If you want to make that
"if (!spin_trylock(...)) return;", I leave that you your esthetic judgement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
