Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 988898D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 21:49:30 -0500 (EST)
Date: Fri, 28 Dec 2012 11:49:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix null pointer dereference in wait_iff_congested()
Message-ID: <20121228024928.GA19720@blaptop>
References: <50D24AF3.1050809@iskon.hr>
 <20121220111208.GD10819@suse.de>
 <20121220125802.23e9b22d.akpm@linux-foundation.org>
 <50D601C9.9060803@iskon.hr>
 <50D71166.6030608@iskon.hr>
 <50DB129E.7010000@iskon.hr>
 <50DD0106.7040001@iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50DD0106.7040001@iskon.hr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhouping Liu <zliu@redhat.com>, Sedat Dilek <sedat.dilek@gmail.com>

Hello Zlatko,

On Fri, Dec 28, 2012 at 03:16:38AM +0100, Zlatko Calusic wrote:
> From: Zlatko Calusic <zlatko.calusic@iskon.hr>
> 
> The unintended consequence of commit 4ae0a48b is that
> wait_iff_congested() can now be called with NULL struct zone*
> producing kernel oops like this:

For good description, it would be better to write simple pseudo code
flow to show how NULL-zone pass into wait_iff_congested because
kswapd code flow is too complex.

As I see the code, we have following line above wait_iff_congested.

if (!unbalanced_zone || blah blah)
        break;

How can NULL unbalanced_zone reach wait_iff_congested?

> 
> BUG: unable to handle kernel NULL pointer dereference
> IP: [<ffffffff811542d9>] wait_iff_congested+0x59/0x140
> 
> This trivial patch fixes it.
> 
> Reported-by: Zhouping Liu <zliu@redhat.com>
> Reported-and-tested-by: Sedat Dilek <sedat.dilek@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 02bcfa3..e55ce55 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2782,7 +2782,7 @@ loop_again:
>  		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
>  			if (has_under_min_watermark_zone)
>  				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
> -			else
> +			else if (unbalanced_zone)
>  				wait_iff_congested(unbalanced_zone, BLK_RW_ASYNC, HZ/10);
>  		}
>  
> -- 
> 1.8.1.rc3
> 
> -- 
> Zlatko
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
