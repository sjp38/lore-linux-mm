Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C57E36B007E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:44:01 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id tt10so151944325pab.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:44:01 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u11si9115768pas.102.2016.03.14.00.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:44:01 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id u190so9246690pfb.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:44:01 -0700 (PDT)
Date: Mon, 14 Mar 2016 16:45:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 2/5] mm/zsmalloc: remove shrinker compaction
 callbacks
Message-ID: <20160314074523.GB542@swordfish>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314063207.GD10675@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314063207.GD10675@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (03/14/16 15:32), Minchan Kim wrote:
> On Thu, Mar 03, 2016 at 11:46:00PM +0900, Sergey Senozhatsky wrote:
> > Do not register shrinker compaction callbacks anymore, since
> > now we shedule class compaction work each time its fragmentation
> > value goes above the watermark.
> 
> I suggested to remove shrinker compaction but while I review your
> first patch in this thread, I thought we need upper-bound to
> compact zspage so background work can bail out for latency easily.
> IOW, the work could give up the job. In such case, we might need
> fall-back scheme to continue the job. And I think that could be
> a shrinker.
> 
> What do you think?

wouldn't this unnecessarily complicate the whole thing? we would
have
 a) a compaction that can be triggered by used space
 b) a compaction from zs_free() that can bail out
 c) a compaction triggered by the shrinker.

all 3 three can run simultaneously.


_if_ we can keep every class below its watermark, we can reduce the
need of "c)".

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
