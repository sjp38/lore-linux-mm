Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB9F6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 09:46:03 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pn19so773053lab.15
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 06:46:02 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o1si3407316lah.115.2014.06.25.06.46.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jun 2014 06:46:01 -0700 (PDT)
Date: Wed, 25 Jun 2014 17:45:45 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
Message-ID: <20140625134545.GB22340@esperanza>
References: <cover.1402602126.git.vdavydov@parallels.com>
 <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com>
 <20140624073840.GC4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140624073840.GC4836@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 24, 2014 at 04:38:41PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 13, 2014 at 12:38:22AM +0400, Vladimir Davydov wrote:
> And, you said that this way of implementation would be slow because
> there could be many object in dead caches and this implementation
> needs node spin_lock on each object freeing. Is it no problem now?
> 
> If you have any performance data about this implementation and
> alternative one, could you share it?

I ran some tests on a 2 CPU x 6 core x 2 HT box. The kernel was compiled
with a config taken from a popular distro, so it had most of debug
options turned off.

---

TEST #1: Each logical CPU executes a task that frees 1M objects
         allocated from the same cache. All frees are node-local.

RESULTS:

objsize (bytes) | cache is dead? | objects free time (ms)
----------------+----------------+-----------------------
          64    |       -        |       373 +- 5
           -    |       +        |      1300 +- 6
                |                |
         128    |       -        |       387 +- 6
           -    |       +        |      1337 +- 6
                |                |
         256    |       -        |       484 +- 4
           -    |       +        |      1407 +- 6
                |                |
         512    |       -        |       686 +-  5
           -    |       +        |      1561 +- 18
                |                |
        1024    |       -        |      1073 +- 11
           -    |       +        |      1897 +- 12

TEST #2: Each logical CPU executes a task that removes 1M empty files
         from its own RAMFS mount. All frees are node-local.

RESULTS:

 cache is dead? | files removal time (s)
----------------+----------------------------------
      -         |       15.57 +- 0.55   (base)
      +         |       16.80 +- 0.62   (base + 8%)

---

So, according to TEST #1 the relative slowdown introduced by zapping per
cpu arrays is really dreadful - it can be up to 4x! However, the
absolute numbers aren't that huge - ~1 second for 24 million objects.
If we do something else except kfree the slowdown shouldn't be that
visible IMO.

TEST #2 is an attempt to estimate how zapping of per cpu arrays will
affect FS objects destruction, which is the most common case of dead
caches usage. To avoid disk-bound operations it uses RAMFS. From the
test results it follows that the relative slowdown of massive file
deletion is within 2 stdev, which looks decent.

Anyway, the alternative approach (reaping dead caches periodically)
won't have this kfree slowdown at all. However, periodic reaping can
become a real disaster as the system evolves and the number of dead
caches grows. Currently I don't know how we can estimate real life
effects of this. If you have any ideas, please let me know.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
