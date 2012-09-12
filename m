Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 385736B010B
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 19:48:12 -0400 (EDT)
Date: Thu, 13 Sep 2012 01:48:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120912234808.GC3404@redhat.com>
References: <20120910011830.GC3715@kernel.org>
 <20120911163455.bb249a3c.akpm@linux-foundation.org>
 <20120912004840.GI27078@redhat.com>
 <20120912142019.0e06bf52.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912142019.0e06bf52.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, mgorman@suse.de

On Wed, Sep 12, 2012 at 02:20:19PM -0700, Andrew Morton wrote:
> OK, I'll slip this in there:
> 
> --- a/mm/compaction.c~mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix
> +++ a/mm/compaction.c
> @@ -909,8 +909,7 @@ static unsigned long compact_zone_order(
>  	INIT_LIST_HEAD(&cc.migratepages);
>  
>  	ret = compact_zone(zone, &cc);
> -	if (contended)
> -		*contended = cc.contended;
> +	*contended = cc.contended;
>  	return ret;
>  }

Ack the above, thanks.

One more thing, today a bug tripped while building cyanogenmod10 (it
swaps despite so much ram) after I added the cc->contended loop break
patch. The original version of the fix from Shaohua didn't have this
problem because it would only abort compaction if the low_pfn didn't
advance and in turn the list would be guaranteed empty.

Verifying the list is empty before aborting compaction (which takes a
path that ignores the cc->migratelist) should be enough to fix it and
it makes it really equivalent to the previous fix. Both cachelines
should be cache hot so it should be practically zero cost to check it.

Only lightly tested so far.

===
