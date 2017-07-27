Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0187A6B04B7
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 20:02:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v31so36835742wrc.7
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:02:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e13si4123457wmc.10.2017.07.27.16.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 16:53:51 -0700 (PDT)
Date: Thu, 27 Jul 2017 16:53:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: use sc->priority for slab shrink targets
Message-Id: <20170727165348.0e23487a9f98c359fbd5bfea@linux-foundation.org>
In-Reply-To: <1500576331-31214-2-git-send-email-jbacik@fb.com>
References: <1500576331-31214-1-git-send-email-jbacik@fb.com>
	<1500576331-31214-2-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On Thu, 20 Jul 2017 14:45:30 -0400 josef@toxicpanda.com wrote:

> From: Josef Bacik <jbacik@fb.com>
> 
> Previously we were using the ratio of the number of lru pages scanned to
> the number of eligible lru pages to determine the number of slab objects
> to scan.  The problem with this is that these two things have nothing to
> do with each other,

"nothing"?

> so in slab heavy work loads where there is little to
> no page cache we can end up with the pages scanned being a very low
> number.

In this case the "number of eligible lru pages" will also be low, so
these things do have something to do with each other?

>  This means that we reclaim next to no slab pages and waste a
> lot of time reclaiming small amounts of space.
> 
> Instead use sc->priority in the same way we use it to determine scan
> amounts for the lru's.

That sounds like a good idea.

Alternatively did you consider hooking into the vmpressure code (or
hannes's new memdelay code) to determine how hard to scan slab?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
