Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id DC0BB6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:49:51 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering pages under writeback
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-8-git-send-email-mgorman@suse.de>
Date: Sun, 17 Mar 2013 07:49:50 -0700
In-Reply-To: <1363525456-10448-8-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Sun, 17 Mar 2013 13:04:13 +0000")
Message-ID: <m21ubejd2p.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:


> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 493728b..7d5a932 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -725,6 +725,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		if (PageWriteback(page)) {
>  			/*
> +			 * If reclaim is encountering an excessive number of
> +			 * pages under writeback and this page is both under
> +			 * writeback and PageReclaim then it indicates that
> +			 * pages are being queued for IO but are being
> +			 * recycled through the LRU before the IO can complete.
> +			 * is useless CPU work so wait on the IO to complete.
> +			 */
> +			if (current_is_kswapd() &&
> +			    zone_is_reclaim_writeback(zone)) {
> +				wait_on_page_writeback(page);
> +				zone_clear_flag(zone, ZONE_WRITEBACK);
> +
> +			/*

Something is wrong with the indentation here. Comment should be indented
or is the code in the wrong block?

It's not fully clair to me how you decide here that the writeback
situation has cleared. There must be some kind of threshold for it,
but I don't see it. Or do you clear already when the first page
finished? That would seem too early.

BTW longer term the code would probably be a lot clearer with a
real explicit state machine instead of all these custom state bits.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
