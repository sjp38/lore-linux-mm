Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D84118E00F6
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 20:57:20 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id h85so5407180oib.9
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 17:57:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i203si2011993oih.81.2019.01.25.17.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 17:57:19 -0800 (PST)
Subject: Re: possible deadlock in __do_page_fault
References: <201901230201.x0N214eq043832@www262.sakura.ne.jp>
 <20190123155751.GA168927@google.com>
 <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
 <20190124134646.GA53008@google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <06b4806c-6b53-85a5-84db-fa432ea4ccd0@i-love.sakura.ne.jp>
Date: Sat, 26 Jan 2019 10:57:03 +0900
MIME-Version: 1.0
In-Reply-To: <20190124134646.GA53008@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 2019/01/24 22:46, Joel Fernandes wrote:
> On Thu, Jan 24, 2019 at 10:52:30AM +0900, Tetsuo Handa wrote:
>> Then, I'm tempted to eliminate shrinker and LRU list (like a draft patch shown
>> below). I think this is not equivalent to current code because this shrinks
>> upon only range_alloc() time and I don't know whether it is OK to temporarily
>> release ashmem_mutex during range_alloc() at "Case #4" of ashmem_pin(), but
>> can't we go this direction? 
> 
> No, the point of the shrinker is to do a lazy free. We cannot free things
> during unpin since it can be pinned again and we need to find that range by
> going through the list. We also cannot get rid of any lists. Since if
> something is re-pinned, we need to find it and find out if it was purged. We
> also need the list for knowing what was unpinned so the shrinker works.
> 
> By the way, all this may be going away quite soon (the whole driver) as I
> said, so just give it a little bit of time.
> 
> I am happy to fix it soon if that's not the case (which I should know soon -
> like a couple of weeks) but I'd like to hold off till then.
> 
>> By the way, why not to check range_alloc() failure before calling range_shrink() ?
> 
> That would be a nice thing to do. Send a patch?

OK. Here is a patch. I chose __GFP_NOFAIL rather than adding error handling,
for small GFP_KERNEL allocation won't fail unless current thread was killed by
the OOM killer or memory allocation fault injection forces it fail, and
range_alloc() will not be called for multiple times from one syscall.

But note that doing GFP_KERNEL allocation with ashmem_mutex held has a risk of
needlessly invoking the OOM killer because "the point of the shrinker is to do
a lazy free" counts on ashmem_mutex not held by GFP_KERNEL allocating thread.
Although other shrinkers likely make forward progress by releasing memory,
technically you should avoid doing GFP_KERNEL allocation with ashmem_mutex held
if shrinker depends on ashmem_mutex not held.



>From e1c4a9b53b0bb11a0743a8f861915c043deb616d Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 26 Jan 2019 10:52:39 +0900
Subject: [PATCH] staging: android: ashmem: Don't allow range_alloc() to fail.

ashmem_pin() is calling range_shrink() without checking whether
range_alloc() succeeded. Since memory allocation fault injection might
force range_alloc() to fail while range_alloc() is called for only once
for one ioctl() request, make range_alloc() not to fail.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/staging/android/ashmem.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index d40c1d2..a8070a2 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -171,18 +171,14 @@ static inline void lru_del(struct ashmem_range *range)
  * @end:	   The ending page (inclusive)
  *
  * This function is protected by ashmem_mutex.
- *
- * Return: 0 if successful, or -ENOMEM if there is an error
  */
-static int range_alloc(struct ashmem_area *asma,
-		       struct ashmem_range *prev_range, unsigned int purged,
-		       size_t start, size_t end)
+static void range_alloc(struct ashmem_area *asma,
+			struct ashmem_range *prev_range, unsigned int purged,
+			size_t start, size_t end)
 {
 	struct ashmem_range *range;
 
-	range = kmem_cache_zalloc(ashmem_range_cachep, GFP_KERNEL);
-	if (!range)
-		return -ENOMEM;
+	range = kmem_cache_zalloc(ashmem_range_cachep, GFP_KERNEL | __GFP_NOFAIL);
 
 	range->asma = asma;
 	range->pgstart = start;
@@ -193,8 +189,6 @@ static int range_alloc(struct ashmem_area *asma,
 
 	if (range_on_lru(range))
 		lru_add(range);
-
-	return 0;
 }
 
 /**
@@ -687,7 +681,8 @@ static int ashmem_unpin(struct ashmem_area *asma, size_t pgstart, size_t pgend)
 		}
 	}
 
-	return range_alloc(asma, range, purged, pgstart, pgend);
+	range_alloc(asma, range, purged, pgstart, pgend);
+	return 0;
 }
 
 /*
-- 
1.8.3.1
