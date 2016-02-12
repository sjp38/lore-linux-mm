Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id DB3F66B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 07:56:11 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so18404596wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 04:56:11 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id ew3si19084090wjd.140.2016.02.12.04.56.10
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 04:56:11 -0800 (PST)
Date: Fri, 12 Feb 2016 13:56:09 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160212125609.7pa35n4wudjp7y36@alap3.anarazel.de>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211153404.42055b27@cuia.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hi,

On 2016-02-11 15:34:04 -0500, Rik van Riel wrote:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eb3dd37ccd7c..0a316c41bf80 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1928,13 +1928,14 @@ static inline bool inactive_anon_is_low(struct lruvec *lruvec)
>   */
>  static bool inactive_file_is_low(struct lruvec *lruvec)
>  {
> +	struct zone *zone = lruvec_zone(lruvec);
>  	unsigned long inactive;
>  	unsigned long active;
>  
>  	inactive = get_lru_size(lruvec, LRU_INACTIVE_FILE);
>  	active = get_lru_size(lruvec, LRU_ACTIVE_FILE);
>  
> -	return active > inactive;
> +	return inactive * zone->inactive_ratio < active;
>  }

Oh, it looks to me like pat of inactive_file_is_low()'s description:
 *
 * When the system is doing streaming IO, memory pressure here
 * ensures that active file pages get deactivated, until more
 * than half of the file pages are on the inactive list.
 *
Would need updating with this patch.

Regards,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
