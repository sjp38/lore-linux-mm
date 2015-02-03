Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 203CA6B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 05:50:14 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id x12so43765089wgg.7
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 02:50:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wl1si42090146wjb.94.2015.02.03.02.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 02:50:12 -0800 (PST)
Date: Tue, 3 Feb 2015 10:50:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-ID: <20150203105007.GP2395@suse.de>
References: <20150202165525.GM2395@suse.de>
 <20150202140506.392ff6920743f19ea44cff59@linux-foundation.org>
 <20150202221824.GN2395@suse.de>
 <20150202143541.1efdd2b571413200cb9a4698@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150202143541.1efdd2b571413200cb9a4698@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Mon, Feb 02, 2015 at 02:35:41PM -0800, Andrew Morton wrote:
> On Mon, 2 Feb 2015 22:18:24 +0000 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > Is there something
> > > preventing this from being addressed within glibc?
> >  
> > I doubt it other than I expect they'll punt it back and blame either the
> > application for being stupid or the kernel for being slow.
> 
> *Is* the application being stupid?  What is it actually doing? 

Only a little. There is little simulated think time between the allocation
and the subsequent free. It means the cost of alloc/free dominates where
in "real" applications they would either be reusing buffers if they were
constantly needed or the think time would mask the cost of the free.

> Something like
> 
> pthread_routine()
> {
> 	p = malloc(X);
> 	do_some(work);
> 	free(p);
> 	return;
> }
> 

Pretty much. There is a search_mem() function that

alloc(copy_size)
memcpy
search
free(copy)

A real application might try and avoid the copy or reuse buffers if they
encountered this particular problem.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
