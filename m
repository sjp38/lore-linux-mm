Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D0BC76B006E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:12:31 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1301224dak.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 10:12:31 -0800 (PST)
Date: Tue, 20 Nov 2012 10:12:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 3/3] man-pages: Add man page for vmpressure_fd(2)
In-Reply-To: <20121120062400.GA9468@lizard>
Message-ID: <alpine.DEB.2.00.1211201004390.4200@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107110152.GC30462@lizard> <20121119215211.6370ac3b.akpm@linux-foundation.org> <20121120062400.GA9468@lizard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Mon, 19 Nov 2012, Anton Vorontsov wrote:

> We try to make userland freeing resources when the system becomes low on
> memory. Once we're short on memory, sometimes it's better to discard
> (free) data, rather than let the kernel to drain file caches or even start
> swapping.
> 

To add another usecase: its possible to modify our version of malloc (or 
any malloc) so that memory that is free()'d can be released back to the 
kernel only when necessary, i.e. when keeping the extra memory around 
starts to have a detremental effect on the system, memcg, or cpuset.  When 
there is an abundance of memory available such that allocations need not 
defragment or reclaim memory to be allocated, it can improve performance 
to keep a memory arena from which to allocate from immediately without 
calling the kernel.

Our version of malloc frees memory back to the kernel with 
madvise(MADV_DONTNEED) which ends up zaping the mapped ptes.  With 
pressure events, we only need to do this when faced with memory pressure; 
to keep our rss low, we require that thp's max_ptes_none tunable be set to 
0; we don't want our applications to use any additional memory.  This 
requires splitting a hugepage anytime memory is free()'d back to the 
kernel.

I'd like to use this as a hook into malloc() for applications that do not 
have strict memory footprint requirements to be able to increase 
performance by keeping around a memory arena from which to allocate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
