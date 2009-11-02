Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9FED16B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 23:59:19 -0500 (EST)
Received: by gxk21 with SMTP id 21so2339871gxk.10
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 20:59:18 -0800 (PST)
Date: Mon, 2 Nov 2009 13:56:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: OOM killer, page fault
Message-Id: <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
In-Reply-To: <20091102005218.8352.A69D9226@jp.fujitsu.com>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
	<20091102005218.8352.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Norbert Preining <preining@logic.at>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon,  2 Nov 2009 13:24:06 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi,
> 
> (Cc to linux-mm)
> 
> Wow, this is very strange log.
> 
> > Dear all,
> > 
> > (please Cc)
> > 
> > With 2.6.32-rc5 I got that one:
> > [13832.210068] Xorg invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0
> 
> order = 0

I think this problem results from 'gfp_mask = 0x0'.
Is it possible?

If it isn't H/W problem, Who passes gfp_mask with 0x0?
It's culpit. 

Could you add BUG_ON(gfp_mask == 0x0) in __alloc_pages_nodemask's head?

---

/*
 * This is the 'heart' of the zoned buddy allocator.
 */
struct page *
__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
                        struct zonelist *zonelist, nodemask_t *nodemask)
{
        enum zone_type high_zoneidx = gfp_zone(gfp_mask);
        struct zone *preferred_zone;
        struct page *page;
        int migratetype = allocflags_to_migratetype(gfp_mask);

+	BUG_ON(gfp_mask == 0x0);
        gfp_mask &= gfp_allowed_mask;

        lockdep_trace_alloc(gfp_mask);

        might_sleep_if(gfp_mask & __GFP_WAIT);

        if (should_fail_alloc_page(gfp_mask, order))
                return NULL;


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
