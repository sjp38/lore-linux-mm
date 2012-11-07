Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B879A6B005A
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 16:34:53 -0500 (EST)
Date: Wed, 7 Nov 2012 19:34:28 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 3/7] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20121107213427.GA10444@optiplex.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <4ea10ef1eb1544e12524c8ca7df20cf621395463.1352256087.git.aquini@redhat.com>
 <20121107130207.214f16ea.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121107130207.214f16ea.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Nov 07, 2012 at 01:02:07PM -0800, Andrew Morton wrote:
> On Wed,  7 Nov 2012 01:05:50 -0200
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > Memory fragmentation introduced by ballooning might reduce significantly
> > the number of 2MB contiguous memory blocks that can be used within a guest,
> > thus imposing performance penalties associated with the reduced number of
> > transparent huge pages that could be used by the guest workload.
> > 
> > This patch introduces a common interface to help a balloon driver on
> > making its page set movable to compaction, and thus allowing the system
> > to better leverage the compation efforts on memory defragmentation.
> 
> 
> mm/migrate.c: In function 'unmap_and_move':
> mm/migrate.c:899: error: 'COMPACTBALLOONRELEASED' undeclared (first use in this function)
> mm/migrate.c:899: error: (Each undeclared identifier is reported only once
> mm/migrate.c:899: error: for each function it appears in.)
> 
> You've been bad - you didn't test with your feature disabled. 
> Please do that.  And not just compilation testing.
>

Gasp... Shame on me, indeed. balloon_event_count() was a macro and I had it
tested a couple of review rounds earlier. You requested me to get rid of
preprocessor pirotech, and I did but I miserably failed on re-testing it.
 
I'm pretty sure Santa is not going to visit me this year.

Do you want me to resubmit this?

> 
> We can fix this one with a sucky macro.  I think that's better than
> unconditionally defining the enums.
> 
> --- a/include/linux/balloon_compaction.h~mm-introduce-a-common-interface-for-balloon-pages-mobility-fix
> +++ a/include/linux/balloon_compaction.h
> @@ -207,10 +207,8 @@ static inline gfp_t balloon_mapping_gfp_
>  	return GFP_HIGHUSER;
>  }
>  
> -static inline void balloon_event_count(enum vm_event_item item)
> -{
> -	return;
> -}
> +/* A macro, to avoid generating references to the undefined COMPACTBALLOON* */
> +#define balloon_event_count(item) do { } while (0)
>  
>  static inline bool balloon_compaction_check(void)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
