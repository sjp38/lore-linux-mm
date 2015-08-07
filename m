Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DB5766B0257
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 21:50:51 -0400 (EDT)
Received: by pawu10 with SMTP id u10so76022343paw.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 18:50:51 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rr7si14752335pab.86.2015.08.06.18.50.49
        for <linux-mm@kvack.org>;
        Thu, 06 Aug 2015 18:50:51 -0700 (PDT)
Date: Fri, 7 Aug 2015 10:56:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: slab:Fix the unexpected index mapping result of
 kmalloc_size(INDEX_NODE + 1)
Message-ID: <20150807015609.GB15802@js1304-P5Q-DELUXE>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn>
 <20150729152803.67f593847050419a8696fe28@linux-foundation.org>
 <20150731001827.GA15029@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

On Fri, Jul 31, 2015 at 08:57:35AM -0500, Christoph Lameter wrote:
> On Fri, 31 Jul 2015, Joonsoo Kim wrote:
> 
> > I don't think that this fix is right.
> > Just "kmalloc_size(INDEX_NODE) * 2" looks insane because it means 192 * 2
> > = 384 on his platform. Why we need to check size is larger than 384?
> 
> Its an arbitrary boundary. Making it large ensures that the smaller caches
> stay operational and do not fall back to page sized allocations.

If it is an arbitrary boundary, it would be better to use static value
such as "256" rather than kmalloc_size(INDEX_NODE) * 2.
Value of kmalloc_size(INDEX_NODE) * 2 can be different in some archs
and it is difficult to manage such variation. It would cause this kinds of
bug again. I recommand following change. How about it?

-       if (size >= kmalloc_size(INDEX_NODE + 1)
+       if (!slab_early_init &&
+               size >= kmalloc_size(INDEX_NODE) &&
+               size >= 256

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
