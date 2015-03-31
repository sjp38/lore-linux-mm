Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B05AF6B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:31:29 -0400 (EDT)
Received: by pdmh5 with SMTP id h5so21900473pdm.3
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 15:31:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fy14si6128pdb.11.2015.03.31.15.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 15:31:28 -0700 (PDT)
Date: Tue, 31 Mar 2015 15:31:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: free large amount of 0-order pages in workqueue
Message-Id: <20150331153127.2eb8cc2f04c742dde7a8c96c@linux-foundation.org>
In-Reply-To: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
References: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, mhocko@suse.cz, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, 31 Mar 2015 18:11:32 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> Freeing pages became a rather costly operation, specially when multiple debug
> options are enabled. This causes hangs when an attempt to free a large amount
> of 0-order is made. Two examples are vfree()ing large block of memory, and
> punching a hole in a shmem filesystem.
> 
> To avoid that, move any free operations that involve batching pages into a
> list to a workqueue handler where they could be freed later.

eek.

__free_pages() is going to be a hot path for someone - it has 500+
callsites.

And this patch might cause problems for rt_prio() tasks which run for a
long time, starving out the workqueue thread.  And probably other stuff
I didn't think of...

What whacky debug option is actually causing this?  Full-page poisoning?



Stick a cond_resched() in __vunmap() ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
