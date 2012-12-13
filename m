Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 404B26B006C
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 06:08:10 -0500 (EST)
Date: Thu, 13 Dec 2012 11:07:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 6/8] mm: vmscan: clean up get_scan_count()
Message-ID: <20121213110759.GA1009@suse.de>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1355348620-9382-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 12, 2012 at 04:43:38PM -0500, Johannes Weiner wrote:
> Reclaim pressure balance between anon and file pages is calculated
> through a tuple of numerators and a shared denominator.
> 
> Exceptional cases that want to force-scan anon or file pages configure
> the numerators and denominator such that one list is preferred, which
> is not necessarily the most obvious way:
> 
>     fraction[0] = 1;
>     fraction[1] = 0;
>     denominator = 1;
>     goto out;
> 
> Make this easier by making the force-scan cases explicit and use the
> fractionals only in case they are calculated from reclaim history.
> 
> And bring the variable declarations/definitions in order.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

The if at the end looks like it should have been a switch maybe?

switch(scan_balance) {
case SCAN_EQUAL:
	/* Scan relative to size */
	break;
case SCAN_FRACT:
	/* Scan proportional to swappiness */
	scan = div64_u64(scan * fraction[file], denominator);
case SCAN_FILE:
case SCAN_ANON:
	/* Scan only file or only anon LRU */
	if ((scan_balance == SCAN_FILE) != file)
		scan = 0;
	break;
default:
	/* Look ma, no brain */
	BUG();
}

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
