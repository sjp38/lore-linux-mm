Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 528466B0264
	for <linux-mm@kvack.org>; Wed, 25 May 2016 01:14:23 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p81so28980155itd.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 22:14:23 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id ck4si8346017igc.72.2016.05.24.22.14.21
        for <linux-mm@kvack.org>;
        Tue, 24 May 2016 22:14:22 -0700 (PDT)
Date: Wed, 25 May 2016 14:14:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160525051438.GA14786@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
 <20160524062801.GB29094@bbox>
MIME-Version: 1.0
In-Reply-To: <20160524062801.GB29094@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello Sergey,

On Tue, May 24, 2016 at 03:28:01PM +0900, Minchan Kim wrote:
<snip>

> > hm... zsmalloc is getting sooo complex now.
> > 
> > `system_wq' -- can we have problems here when the system is getting
> > low on memory and workers are getting increasingly busy trying to
> > allocate the memory for some other purposes?
> > 
> > _theoretically_ zsmalloc can stack a number of ready-to-release zspages,
> > which won't be accessible to zsmalloc, nor will they be released. how likely
> > is this? hm, can zsmalloc take zspages from that deferred release list when
> > it wants to allocate a new zspage?
> 
> Done.
> 
> > 
> > do you also want to kick the deferred page release from the shrinker
> > callback, for example?
> 
> Yeb, it can be. I will do it at next revision. :)
> Thanks!
> 

I tried it now but I feel strongly we want to fix shrinker first.
Now, shrinker doesn't consider VM's request(i.e., sc->nr_to_scan) but
shrink all objects which could make latency huge.

I want to fix it as another issue and then adding ZS_EMPTY pool pages
purging logic based on it because many works for zsmalloc stucked
with this patchset now which churns old code heavily. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
