Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 618396B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 21:52:16 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so960499pbb.23
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 18:52:16 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id wm3si60001728pab.252.2014.01.07.18.52.13
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 18:52:14 -0800 (PST)
Date: Wed, 8 Jan 2014 11:52:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCHv3 00/11] Intermix Lowmem and vmalloc
Message-ID: <20140108025233.GA1992@bbox>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
 <52C70024.1060605@sr71.net>
 <52C734F4.5020602@codeaurora.org>
 <20140104073143.GA5594@gmail.com>
 <52CAFF2A.5060407@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52CAFF2A.5060407@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org

Hello,

On Mon, Jan 06, 2014 at 11:08:26AM -0800, Laura Abbott wrote:
> On 1/3/2014 11:31 PM, Minchan Kim wrote:
> >Hello,
> >
> >On Fri, Jan 03, 2014 at 02:08:52PM -0800, Laura Abbott wrote:
> >>On 1/3/2014 10:23 AM, Dave Hansen wrote:
> >>>On 01/02/2014 01:53 PM, Laura Abbott wrote:
> >>>>The goal here is to allow as much lowmem to be mapped as if the block of memory
> >>>>was not reserved from the physical lowmem region. Previously, we had been
> >>>>hacking up the direct virt <-> phys translation to ignore a large region of
> >>>>memory. This did not scale for multiple holes of memory however.
> >>>
> >>>How much lowmem do these holes end up eating up in practice, ballpark?
> >>>I'm curious how painful this is going to get.
> >>>
> >>
> >>In total, the worst case can be close to 100M with an average case
> >>around 70M-80M. The split and number of holes vary with the layout
> >>but end up with 60M-80M one hole and the rest in the other.
> >
> >One more thing I'd like to know is how bad direct virt <->phys tranlsation
> >in scale POV and how often virt<->phys tranlsation is called in your worload
> >so what's the gain from this patch?
> >
> >Thanks.
> >
> 
> With one hole we did
> 
> #define __phys_to_virt(phys)
> 	phys >= mem_hole_end ? mem_hole : normal
> 
> We had a single global variable to check for the bounds and to do
> something similar with multiple holes the worst case would be
> O(number of holes). This would also all need to be macroized.
> Detection and accounting for these holes in other data structures
> (e.g. ARM meminfo) would be increasingly complex and lead to delays
> in bootup. The error/sanity checking for bad memory configurations
> would also be messier. Non-linear lowmem mappings also make
> debugging more difficult.
> 
> virt <-> phys translation is used on hot paths in IOMMU mapping so
> we want to keep virt <-> phys as fast as possible and not have to
> walk an array of addresses every time.

When you send formal patch, please include things you mentioned
in the description rather than simple "This did not scale for multiple
holes of memory however" to justify your motivation and please include
number you got from this patch because it's mainly performance enhance
patch but doesn't include any number(yeb, you sent it as RFC so
I don't care now) so that it could make easy to judge that we need
this patch or not compared to adding complexity.

Thanks.


> 
> Thanks,
> Laura
> 
> -- 
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> hosted by The Linux Foundation
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
