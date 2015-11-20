Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 23A4C6B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 16:43:15 -0500 (EST)
Received: by wmdw130 with SMTP id w130so35137899wmd.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 13:43:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o124si2159847wmg.25.2015.11.20.13.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 13:43:13 -0800 (PST)
Date: Fri, 20 Nov 2015 13:43:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: do not force-scan file lru if its absolute size
 is small
Message-Id: <20151120134311.8ff0947215fc522f72f791fe@linux-foundation.org>
In-Reply-To: <20151120183707.GA5623@cmpxchg.org>
References: <1448038976-28796-1-git-send-email-vdavydov@virtuozzo.com>
	<20151120183707.GA5623@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Nov 2015 13:37:07 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Nov 20, 2015 at 08:02:56PM +0300, Vladimir Davydov wrote:
> > We assume there is enough inactive page cache if the size of inactive
> > file lru is greater than the size of active file lru, in which case we
> > force-scan file lru ignoring anonymous pages. While this logic works
> > fine when there are plenty of page cache pages, it fails if the size of
> > file lru is small (several MB): in this case (lru_size >> prio) will be
> > 0 for normal scan priorities, as a result, if inactive file lru happens
> > to be larger than active file lru, anonymous pages of a cgroup will
> > never get evicted unless the system experiences severe memory pressure,
> > even if there are gigabytes of unused anonymous memory there, which is
> > unfair in respect to other cgroups, whose workloads might be page cache
> > oriented.
> > 
> > This patch attempts to fix this by elaborating the "enough inactive page
> > cache" check: it makes it not only check that inactive lru size > active
> > lru size, but also that we will scan something from the cgroup at the
> > current scan priority. If these conditions do not hold, we proceed to
> > SCAN_FRACT as usual.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> This makes sense, the inactive:active ratio of the file list alone
> does not give the full picture to decide whether to skip anonymous.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> > @@ -2046,7 +2046,8 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
> >  	 * There is enough inactive page cache, do not reclaim
> >  	 * anything from the anonymous working set right now.
> >  	 */
> > -	if (!inactive_file_is_low(lruvec)) {
> > +	if (!inactive_file_is_low(lruvec) &&
> > +	    get_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority > 0) {
> 
> The > 0 seems unnecessary, no? There are too many > in this line :-)

And an update to the code comment would be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
