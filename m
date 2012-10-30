Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 593638D0004
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 14:54:53 -0400 (EDT)
Date: Tue, 30 Oct 2012 11:54:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm,vmscan: only evict file pages when we have
 plenty
Message-Id: <20121030115451.f4c097f0.akpm@linux-foundation.org>
In-Reply-To: <20121030144204.0aa14d92@dull>
References: <20121030144204.0aa14d92@dull>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, klamm@yandex-team.ru, mgorman@suse.de, hannes@cmpxchg.org

On Tue, 30 Oct 2012 14:42:04 -0400
Rik van Riel <riel@redhat.com> wrote:

> If we have more inactive file pages than active file pages, we
> skip scanning the active file pages alltogether, with the idea
> that we do not want to evict the working set when there is
> plenty of streaming IO in the cache.

Yes, I've never liked that.  The "(active > inactive)" thing is a magic
number.  And suddenly causing a complete cessation of vm scanning at a
particular magic threshold seems rather crude, compared to some complex
graduated thing which will also always do the wrong thing, only more
obscurely ;)

Ho hum, in the absence of observed problems, I guess we don't muck with
it.

> However, the code forgot to also skip scanning anonymous pages
> in that situation.  That lead to the curious situation of keeping
> the active file pages protected from being paged out when there
> are lots of inactive file pages, while still scanning and evicting
> anonymous pages.
> 
> This patch fixes that situation, by only evicting file pages
> when we have plenty of them and most are inactive.
> 

Any observed runtime effects from this?  If so, were they good?

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1686,6 +1686,15 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  			fraction[1] = 0;
>  			denominator = 1;
>  			goto out;
> +		} else if (!inactive_file_is_low_global(zone)) {
> +			/*
> +			 * There is enough inactive page cache, do not
> +			 * reclaim anything from the working set right now.
> +			 */
> +			fraction[0] = 0;
> +			fraction[1] = 1;
> +			denominator = 1;
> +			goto out;
>  		}
>  	}

Let's make the commenting look logical:

--- a/mm/vmscan.c~mmvmscan-only-evict-file-pages-when-we-have-plenty-fix
+++ a/mm/vmscan.c
@@ -1679,9 +1679,11 @@ static void get_scan_count(struct lruvec
 
 	if (global_reclaim(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
-		/* If we have very few page cache pages,
-		   force-scan anon pages. */
 		if (unlikely(file + free <= high_wmark_pages(zone))) {
+			/*
+			 * If we have very few page cache pages, force-scan
+			 * anon pages.
+			 */
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
