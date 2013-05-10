Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 797926B0033
	for <linux-mm@kvack.org>; Fri, 10 May 2013 06:28:13 -0400 (EDT)
Date: Fri, 10 May 2013 11:28:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH RFC] mm: lru milestones, timestamps and ages
Message-ID: <20130510102809.GA31738@suse.de>
References: <20130430110214.22179.26139.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130430110214.22179.26139.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org

On Tue, Apr 30, 2013 at 03:02:14PM +0400, Konstantin Khlebnikov wrote:
> +static inline bool
> +is_lru_milestone(struct lruvec *lruvec, struct list_head *list)
> +{
> +	return unlikely(list >= &lruvec->milestones[0][0].lru &&
> +			list <  &lruvec->milestones[NR_EVICTABLE_LRU_LISTS]
> +						   [NR_LRU_MILESTONES].lru);
> +}
> +

Not reviewing properly yet, just taking a quick look out of interest but
this check may be delicate.  32-bit x86 machines start the kernel direct
mapping at 0xC0000000 so milestones[0][0].lru will have some value betewen
0xC0000000 and 0xFFFFFFFF. HZ=250 on my distro config so after 0xC0000000
jiffies or a bit over 149 days of uptime, it looks like there will be a
window where LRU entries look like milestones. If I'm right, that is
bound to cause problems.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
