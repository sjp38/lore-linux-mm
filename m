Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EA38E6B006E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 04:57:18 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so101955445pac.3
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 01:57:18 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id cg2si63271628pbb.101.2015.06.29.01.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 01:57:18 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so102385831pab.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 01:57:17 -0700 (PDT)
Date: Mon, 29 Jun 2015 17:57:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv3 7/7] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150629085744.GA549@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150629070711.GD13179@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150629070711.GD13179@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

thanks for review.

On (06/29/15 16:07), Minchan Kim wrote:
[..]
> >  			if (!migrate_zspage(pool, class, &cc))
> > -				break;
> > +				goto out;
> 
> It should retry with another target_page instead of going out.

yep.

[..]
> > +static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
> > +		struct shrink_control *sc)
> > +{
[..]
> 
> Returns migrated object count.
> 
[..]
> > +static unsigned long zs_shrinker_count(struct shrinker *shrinker,
> > +		struct shrink_control *sc)
> > +{
[..]
> 
> But it returns wasted_obj / max_obj_per_zspage?
> 

Good catch.
So,  __zs_compact() and zs_shrinker_count() are ok. Returning
"wasted_obj / max_obj_per_zspage" from zs_can_compact() makes
sense there. The only place is zs_shrinker_scan()->zs_compact().

Hm, I can think of:

(a) We can change zs_compact() to return the total number of
freed zspages. That will not really change a user visible
interface. We export (fwiw) the number of compacted objects
in mm_stat. Basically, this is internal zsmalloc() counter and
no user space program can ever do anything with that data. From
that prospective we will just replace one senseless number with
another (equally meaningless) one.


(b) replace zs_compact() call in zs_shrinker_scan() with a class loop

1764         int i;
1765         unsigned long nr_migrated = 0;
1766         struct size_class *class;
1767
1768         for (i = zs_size_classes - 1; i >= 0; i--) {
1769                 class = pool->size_class[i];
1770                 if (!class)
1771                         continue;
1772                 if (class->index != i)
1773                         continue;
1774                 nr_migrated += __zs_compact(pool, class);
1775         }
1776
1777         return nr_migrated;

But on every iteration increment nr_migrated with
		"nr_migrated += just_migrated / max_obj_per_zspage"

(which will be unnecessary if zs_compact() will return the number of freed
zspages).

So, (b) is mostly fine, except that we already have several pool->size_class
loops, with same `if (!class)' and `if (class->index...)' checks; and it
asks for some sort of refactoring or... a tricky for_each_class() define.


In both cases, however, we don't tell anything valuable to user space.
Thus,

(c) Return from zs_compact() the number of pages (PAGE_SIZE) freed.
And change compaction to operate in terms of pages (PAGE_SIZE). At
least mm_stat::compacted will turn into something useful for user
space.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
