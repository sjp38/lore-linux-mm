Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D25DA6B007E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 20:59:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so89212764pac.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 17:59:36 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id f72si203830pfd.211.2016.05.25.17.59.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 17:59:35 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id g64so25101614pfb.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 17:59:35 -0700 (PDT)
Date: Thu, 26 May 2016 09:59:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160526005926.GA532@swordfish>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
 <20160524062801.GB29094@bbox>
 <20160525051438.GA14786@bbox>
 <20160525152345.GA515@swordfish>
 <20160526003241.GA9661@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160526003241.GA9661@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Minchan,

On (05/26/16 09:32), Minchan Kim wrote:
[..]
> Unfortunately, I don't have now. However, I don't feel we need a data for
> that because *unbounded work* within VM interaction context is bad. ;-)

fair enough, even though the shrinker doesn't put any constraints here.

> > hm, probably it makes sense to change it. but if the change will
> > replace "1 full pool scan" to "2 scans of 1/2 of pool's classes",
> > then I'm less sure.
> 
> Other shrinker is on same page. They have *cache* which is helpful for
> performance but if it's not hot, it can lose performance if memory
> pressure is severe. For the balance, comprimise approach is shrinker.
> 
> We can see fragement space in zspage as wasted memory which is bad
> on the other hand we can see it as cache to store upcoming compressed
> page. So, too much freeing can hurt the performance so, let's obey
> VM's rule. If memory pressure goes severe, they want to reclaim more
> pages with proportional of memory pressure.

I agree that the unused memory has a dual nature here. we don't really
do the "compact too much" thing, in a sense that we very rarely compact
classes to be ZS_FULL. ~2-3% of the cases (if I recall the testing
results correctly). but reducing the class ->lock pressure is a nice
thing on its own. so yeah, let's do it!

btw, I've uploaded zram-fio test script to
 https://github.com/sergey-senozhatsky/zram-perf-test

it's very minimalistic and half baked, but can be used
to some degree. open to patches, improvements, etc.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
