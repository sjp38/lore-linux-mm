Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D85CF6B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 10:26:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so89921452pfz.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 07:26:24 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id d25si18022578pfj.149.2016.05.25.07.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 07:26:23 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id y69so18995708pfb.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 07:26:23 -0700 (PDT)
Date: Thu, 26 May 2016 00:23:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160525152345.GA515@swordfish>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
 <20160524062801.GB29094@bbox>
 <20160525051438.GA14786@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160525051438.GA14786@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello Minchan,

On (05/25/16 14:14), Minchan Kim wrote:
[..]
> > > do you also want to kick the deferred page release from the shrinker
> > > callback, for example?
> > 
> > Yeb, it can be. I will do it at next revision. :)
> > Thanks!
> > 
> 
> I tried it now but I feel strongly we want to fix shrinker first.
> Now, shrinker doesn't consider VM's request(i.e., sc->nr_to_scan) but
> shrink all objects which could make latency huge.

hm... may be.

I only briefly thought about it a while ago; and have no real data on
hands. it was something as follows:
between zs_shrinker_count() and zs_shrinker_scan() a lot can change;
and _theoretically_ attempting to zs_shrinker_scan() even a smaller
sc->nr_to_scan still may result in a "full" pool scan, taking all of
the classes ->locks one by one just because classes are not the same
as a moment ago. which is even more probable, I think, once the system
is getting low on memory and begins to swap out, for instance. because
in the latter case we increase the number of writes to zspool and,
thus, reduce its chances to be compacted. if the system would still
demand free memory, then it'd keep calling zs_shrinker_count() and
zs_shrinker_scan() on us; at some point, I think, zs_shrinker_count()
would start returning 0. ...if some of the classes would have huge
fragmentation then we'd keep these class' ->locks for some time,
moving objects. other than that we probably would just iterate the
classes.

purely theoretical.

do you have any numbers?

hm, probably it makes sense to change it. but if the change will
replace "1 full pool scan" to "2 scans of 1/2 of pool's classes",
then I'm less sure.

> I want to fix it as another issue and then adding ZS_EMPTY pool pages
> purging logic based on it because many works for zsmalloc stucked
> with this patchset now which churns old code heavily. :(

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
