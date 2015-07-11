Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id F25436B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 22:53:45 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so1693925pac.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 19:53:45 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id dk4si16403593pbb.219.2015.07.10.19.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 19:53:44 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so61444387pdr.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 19:53:43 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Date: Sat, 11 Jul 2015 11:51:53 +0900
Message-Id: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

Shrinker API does not handle nicely unregister_shrinker() on a not-registered
->shrinker. Looking at shrinker users, they all have to
(a) carry on some sort of a flag to make sure that "unregister_shrinker()"
will not blow up later
(b) be fishy (potentially can Oops)
(c) access private members `struct shrinker' (e.g. `shrink.list.next')

Change unregister_shrinker() to consider all-zeroes shrinker as
'initialized, but not registered' shrinker, so we can avoid NULL
dereference when unregister_shrinker() accidentally receives such
a struct.

Introduce init_shrinker() function to init `critical' shrinkers members
when the entire shrinker cannot be, for some reason, zeroed out. This
also helps to avoid Oops in unregister_shrinker() in some cases (when
unregister_shrinker() receives not initialized and not registered shrinker).

Sergey Senozhatsky (2):
  mm/shrinker: do not NULL dereference uninitialized shrinker
  mm/shrinker: add init_shrinker() function

 include/linux/shrinker.h |  1 +
 mm/vmscan.c              | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
