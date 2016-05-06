Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 290DC6B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 05:32:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so217699449pfz.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 02:32:10 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id fk7si17343199pab.97.2016.05.06.02.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 02:32:09 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id 77so47888042pfv.2
        for <linux-mm@kvack.org>; Fri, 06 May 2016 02:32:09 -0700 (PDT)
Date: Fri, 6 May 2016 18:33:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160506093342.GB488@swordfish>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
 <20160505100329.GA497@swordfish>
 <20160506030935.GA18573@bbox>
 <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
 <20160506090801.GA488@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160506090801.GA488@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On (05/06/16 18:08), Sergey Senozhatsky wrote:
[..]
> and it's not 45 iterations that we are getting rid of, but around 31:
> not every class reaches it's ideal 100% ratio on the first iteration.
> so, no, sorry, I don't think the patch really does what we want.


to be clear, what I meant was:

  495 `cmp' + 15 `cmp je'                         IN
  31 `mov cltd idiv mov sub imul cltd idiv cmp'   OUT

IN > OUT.


CORRECTION here:

> * by the way, we don't even need `cltd' in those calculations. the
> reason why gcc puts cltd is because ZS_MAX_PAGES_PER_ZSPAGE has the
> 'wrong' data type. the patch to correct it is below (not a formal
> patch).

no, we need cltd there. but ZS_MAX_PAGES_PER_ZSPAGE also affects
ZS_MIN_ALLOC_SIZE, which is used in several places, like
get_size_class_index(). that's why ZS_MAX_PAGES_PER_ZSPAGE data
type change `improves' zs_malloc().

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
